import 'package:flutter/foundation.dart';

class FirestoreMonitor {
  static int totalReads = 0;
  static int totalWrites = 0;
  static int totalDeletes = 0;

  static void logRead(String path, {int count = 1}) {
    if (kDebugMode && count > 0) {
      totalReads += count;
      print('🔥 [FIRESTORE MONITOR] READ ($count docs) -> $path | Total Session Reads: $totalReads');
    }
  }

  static void logWrite(String path) {
    if (kDebugMode) {
      totalWrites += 1;
      print('🔥 [FIRESTORE MONITOR] WRITE -> $path | Total Session Writes: $totalWrites');
    }
  }

  static void logDelete(String path) {
    if (kDebugMode) {
      totalDeletes += 1;
      print('🔥 [FIRESTORE MONITOR] DELETE -> $path | Total Session Deletes: $totalDeletes');
    }
  }
}
