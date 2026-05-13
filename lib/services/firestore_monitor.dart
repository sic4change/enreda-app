import 'dart:async';

import 'package:flutter/foundation.dart';

/// In-app Firestore activity monitor.
///
/// Two tiers of logging:
///
/// * **General monitor** (pre-existing): logs every read/write/delete that
///   flows through `FirestoreService`, gated only on [kDebugMode]. Useful for
///   broad debugging but noisy.
///
/// * **Resources audit (new, dev-localhost only)**: a focused channel that
///   counts reads, writes and deletes targeting the `resources` collection
///   (or any `resources/...` document) and groups them by call site via
///   `StackTrace.current`. Designed for validating the cursor-pagination
///   fix during `flutter run -d chrome` against localhost — produces
///   grep-friendly `[RES-AUDIT]` lines and a periodic summary tick.
///
/// All audit code paths are no-ops in release builds and on non-localhost
/// web hosts; production users pay zero overhead.
class FirestoreMonitor {
  // ===========================================================================
  // General counters (existing API — do not break callers)
  // ===========================================================================
  static int totalReads = 0;
  static int totalWrites = 0;
  static int totalDeletes = 0;

  // ===========================================================================
  // Resources-collection audit counters
  // ===========================================================================
  static int resourcesReads = 0;
  static int resourcesWrites = 0;
  static int resourcesDeletes = 0;

  /// Per-caller read counts, keyed by abbreviated stack frame
  /// (e.g. `_ResourcesPageState._loadFirstResourcesPage @ resources_page.dart:215:5`).
  static final Map<String, int> resourcesReadsByCaller = <String, int>{};
  static final Map<String, int> resourcesWritesByCaller = <String, int>{};

  /// Timestamp of the first observed event since the last reset. Used to
  /// compute a reads-per-minute rate in the periodic summary.
  static DateTime? _resourcesAuditStartedAt;
  static Timer? _summaryTimer;

  // ===========================================================================
  // Localhost / dev gating
  // ===========================================================================

  /// True when running under `flutter run` (debug mode) AND either a native
  /// device build or a web build served from `localhost` / `127.0.0.1`.
  ///
  /// Cached on first access to avoid re-parsing [Uri.base] on every log call.
  static bool? _cachedLocalhostDev;
  static bool get _isLocalhostDev {
    final cached = _cachedLocalhostDev;
    if (cached != null) return cached;
    bool result;
    if (!kDebugMode) {
      result = false;
    } else if (kIsWeb) {
      final host = Uri.base.host;
      result = host == 'localhost' || host == '127.0.0.1' || host.isEmpty;
    } else {
      // Native debug builds — always considered "dev".
      result = true;
    }
    _cachedLocalhostDev = result;
    return result;
  }

  static bool _isResourcesPath(String path) {
    if (path == 'resources') return true;
    return path.startsWith('resources/');
  }

  // ===========================================================================
  // Public logging API (called by FirestoreService)
  // ===========================================================================

  static void logRead(String path, {int count = 1}) {
    if (kDebugMode && count > 0) {
      totalReads += count;
      print(
          '🔥 [FIRESTORE MONITOR] READ ($count docs) -> $path | Total Session Reads: $totalReads');
      _auditResourcesRead(path, count);
    }
  }

  static void logWrite(String path) {
    if (kDebugMode) {
      totalWrites += 1;
      print(
          '🔥 [FIRESTORE MONITOR] WRITE -> $path | Total Session Writes: $totalWrites');
      _auditResourcesWrite(path);
    }
  }

  static void logDelete(String path) {
    if (kDebugMode) {
      totalDeletes += 1;
      print(
          '🔥 [FIRESTORE MONITOR] DELETE -> $path | Total Session Deletes: $totalDeletes');
      _auditResourcesDelete(path);
    }
  }

  // ===========================================================================
  // Resources audit — internals
  // ===========================================================================

  static void _auditResourcesRead(String path, int count) {
    if (!_isLocalhostDev) return;
    if (!_isResourcesPath(path)) return;
    _resourcesAuditStartedAt ??= DateTime.now();
    resourcesReads += count;
    final caller = _shortCaller();
    resourcesReadsByCaller.update(caller, (v) => v + count,
        ifAbsent: () => count);
    print(
        '📚 [RES-AUDIT] READ  +$count -> $path | caller=$caller | resourcesReads=$resourcesReads');
  }

  static void _auditResourcesWrite(String path) {
    if (!_isLocalhostDev) return;
    if (!_isResourcesPath(path)) return;
    _resourcesAuditStartedAt ??= DateTime.now();
    resourcesWrites += 1;
    final caller = _shortCaller();
    resourcesWritesByCaller.update(caller, (v) => v + 1, ifAbsent: () => 1);
    print(
        '✏️  [RES-AUDIT] WRITE -> $path | caller=$caller | resourcesWrites=$resourcesWrites');
  }

  static void _auditResourcesDelete(String path) {
    if (!_isLocalhostDev) return;
    if (!_isResourcesPath(path)) return;
    _resourcesAuditStartedAt ??= DateTime.now();
    resourcesDeletes += 1;
    final caller = _shortCaller();
    print(
        '🗑️  [RES-AUDIT] DELETE -> $path | caller=$caller | resourcesDeletes=$resourcesDeletes');
  }

  // ===========================================================================
  // Stack-trace parsing
  // ===========================================================================

  /// Returns an abbreviated description of the first stack frame outside the
  /// monitoring infrastructure. Tolerant of both Dart VM stack format
  /// (`#3  Foo.bar (package:.../file.dart:12:5)`) and Flutter web stack
  /// format (`packages/.../file.dart 12:5  Foo.bar`).
  static String _shortCaller() {
    final trace = StackTrace.current.toString();
    final lines = trace.split('\n');
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.contains('firestore_monitor.dart')) continue;
      if (line.contains('firestore_service.dart')) continue;
      if (line.contains('FirestoreMonitor')) continue;
      if (line.contains('FirestoreService')) continue;
      return _abbreviateFrame(line);
    }
    return '<unknown>';
  }

  static String _abbreviateFrame(String line) {
    // Dart VM format: "#3  Foo.bar (package:enreda_app/.../file.dart:12:5)"
    final vmMatch =
        RegExp(r'#\d+\s+([^\(]+)\s+\(([^\)]+)\)').firstMatch(line);
    if (vmMatch != null) {
      final method = vmMatch.group(1)!.trim();
      final location = vmMatch.group(2)!;
      final tail = location.split('/').last;
      return '$method @ $tail';
    }
    // Web format: "packages/enreda_app/.../file.dart 12:5  Foo.bar"
    final webMatch =
        RegExp(r'([\w./]+\.dart)\s+(\d+:\d+)\s+(.+)').firstMatch(line);
    if (webMatch != null) {
      final file = webMatch.group(1)!.split('/').last;
      final pos = webMatch.group(2)!;
      final method = webMatch.group(3)!.trim();
      return '$method @ $file:$pos';
    }
    return line.length > 120 ? '${line.substring(0, 120)}…' : line;
  }

  // ===========================================================================
  // Periodic summary + manual snapshot helpers
  // ===========================================================================

  /// Starts a recurring summary dump every [interval] (default 30s). Safe to
  /// call repeatedly — only the first call installs the timer. No-op in
  /// release builds or off-localhost.
  ///
  /// Typical use: call once from `main.dart` immediately after
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static void startPeriodicResourcesSummary({
    Duration interval = const Duration(seconds: 30),
  }) {
    if (!_isLocalhostDev) return;
    if (_summaryTimer != null) return;
    print(
        '📚 [RES-AUDIT] Periodic summary started — interval=${interval.inSeconds}s. Use FirestoreMonitor.dumpResourcesSummary() for an on-demand snapshot.');
    _summaryTimer = Timer.periodic(interval, (_) => dumpResourcesSummary());
  }

  /// Cancels the periodic summary timer (typically not needed — released on
  /// app exit). Useful if a test driver wants to flip auditing off mid-run.
  static void stopPeriodicResourcesSummary() {
    _summaryTimer?.cancel();
    _summaryTimer = null;
  }

  /// Prints a one-shot summary of resources-collection activity since the
  /// audit started. Safe to call anywhere; no-op outside dev/localhost.
  static void dumpResourcesSummary() {
    if (!_isLocalhostDev) return;
    final startedAt = _resourcesAuditStartedAt;
    final now = DateTime.now();
    final elapsedSeconds =
        startedAt == null ? 0 : now.difference(startedAt).inSeconds;

    // Diagnostic shortcut: if no events have been observed yet, print a
    // compact 'idle' summary instead of the verbose template — saves console
    // scroll and tells the developer how to make events happen.
    if (startedAt == null) {
      print(
          '📚 [RES-AUDIT] idle — no `resources` reads/writes observed yet. '
          'Audit is active; navigate to a page that touches the collection '
          '(e.g. Recursos / ResourceDetail) to see counters tick.');
      // Surface broader Firestore activity context so you can tell if the
      // app is reading anything at all vs. silently waiting on user input.
      print(
          '   Overall session so far — reads=$totalReads, writes=$totalWrites, deletes=$totalDeletes.');
      return;
    }

    final ratePerMinute = elapsedSeconds > 0
        ? (resourcesReads * 60 / elapsedSeconds).toStringAsFixed(1)
        : 'n/a';
    print('===================== [RES-AUDIT] summary =====================');
    print(
        '  Window: ${elapsedSeconds}s since first event @ ${startedAt.toIso8601String()}');
    print(
        '  Reads:  $resourcesReads   Writes: $resourcesWrites   Deletes: $resourcesDeletes');
    print('  Read rate: $ratePerMinute reads/min');
    if (resourcesReadsByCaller.isNotEmpty) {
      print('  Top read call sites:');
      final ranked = resourcesReadsByCaller.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in ranked.take(8)) {
        print('    ${entry.value.toString().padLeft(5)}  ${entry.key}');
      }
    }
    if (resourcesWritesByCaller.isNotEmpty) {
      print('  Top write call sites:');
      final ranked = resourcesWritesByCaller.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in ranked.take(5)) {
        print('    ${entry.value.toString().padLeft(5)}  ${entry.key}');
      }
    }
    print('===============================================================');
  }

  /// Zeroes resources counters and per-caller maps. The general monitor
  /// counters are NOT reset. Useful when starting a fresh test scenario.
  static void resetResourcesCounters() {
    resourcesReads = 0;
    resourcesWrites = 0;
    resourcesDeletes = 0;
    resourcesReadsByCaller.clear();
    resourcesWritesByCaller.clear();
    _resourcesAuditStartedAt = null;
    if (_isLocalhostDev) {
      print('📚 [RES-AUDIT] Counters reset.');
    }
  }
}
