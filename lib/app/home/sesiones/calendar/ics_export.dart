import 'package:enreda_app/app/home/models/sesion.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:intl/intl.dart';

/// Builds an iCalendar (RFC 5545) string from a list of [Sesion]s.
///
/// Ported from `enredaEntidadSocial` so the participant app produces an
/// identical `.ics` payload. The file can be imported into any standards
/// compliant calendar app — Google Calendar, Apple Calendar, Outlook, etc.
///
/// Rules applied:
///   * Lines are CRLF-terminated (`\r\n`), per RFC 5545.
///   * TEXT property values escape `\\`, `;`, `,`, and embedded newlines.
///   * Timed events serialise [Sesion.scheduledAt] as UTC (`Z` suffix).
///   * All-day events use the DATE form with an exclusive end one day later.
///   * `UID` is `sesion-<sesionId>@enreda` so re-importing updates events.
String buildIcsCalendar(
  List<Sesion> sesiones, {
  Map<String, String>? participantNames,
  String productId = '-//Enreda//Sesiones//ES',
  DateTime? generatedAt,
}) {
  final dtstamp = _utc(generatedAt ?? DateTime.now().toUtc());
  final buf = StringBuffer()
    ..write('BEGIN:VCALENDAR\r\n')
    ..write('VERSION:2.0\r\n')
    ..write('PRODID:$productId\r\n')
    ..write('CALSCALE:GREGORIAN\r\n')
    ..write('METHOD:PUBLISH\r\n');

  for (final s in sesiones) {
    _writeEvent(buf, s, dtstamp, participantNames);
  }

  buf.write('END:VCALENDAR\r\n');
  return buf.toString();
}

void _writeEvent(
  StringBuffer buf,
  Sesion s,
  String dtstamp,
  Map<String, String>? participantNames,
) {
  final uid = 'sesion-${s.sesionId ?? _fallbackUid(s)}@enreda';
  buf
    ..write('BEGIN:VEVENT\r\n')
    ..write('UID:$uid\r\n')
    ..write('DTSTAMP:$dtstamp\r\n');

  if (s.isAllDay) {
    final start = s.scheduledAt;
    final end = s.fechaFin ?? start.add(const Duration(days: 1));
    buf
      ..write('DTSTART;VALUE=DATE:${_date(start)}\r\n')
      ..write('DTEND;VALUE=DATE:${_date(end)}\r\n');
  } else {
    final start = s.scheduledAt.toUtc();
    final end = s.fechaFin?.toUtc() ?? start.add(_parseDuration(s.duracion));
    buf
      ..write('DTSTART:${_utc(start)}\r\n')
      ..write('DTEND:${_utc(end)}\r\n');
  }

  buf.write('SUMMARY:${_text(_summaryFor(s))}\r\n');

  final desc = _descriptionFor(s, participantNames);
  if (desc.isNotEmpty) {
    buf.write('DESCRIPTION:${_text(desc)}\r\n');
  }

  final lugar = s.lugar?.trim();
  if (lugar != null && lugar.isNotEmpty) {
    buf.write('LOCATION:${_text(lugar)}\r\n');
  }

  buf.write('CATEGORIES:${_text(s.sessionType.toUpperCase())}\r\n');

  buf.write('END:VEVENT\r\n');
}

// ── Field mappers ─────────────────────────────────────────────────────────

String _summaryFor(Sesion s) {
  final title = s.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  return s.sessionType == SesionType.grupal
      ? StringConst.SESION_GRUPAL
      : StringConst.SESION_INDIVIDUAL;
}

String _descriptionFor(Sesion s, Map<String, String>? participantNames) {
  final parts = <String>[_timingFor(s)];

  final people = _participantsFor(s, participantNames);
  if (people.isNotEmpty) parts.add(people);

  final desc = s.description?.trim() ?? '';
  if (desc.isNotEmpty) {
    parts.add('${StringConst.SESION_DETAIL_DESARROLLO}\n$desc');
  }
  final obs = s.observations?.trim() ?? '';
  if (obs.isNotEmpty) {
    parts.add('${StringConst.SESION_DETAIL_OBSERVACIONES}\n$obs');
  }
  return parts.join('\n\n');
}

String _timingFor(Sesion s) {
  if (s.isAllDay) {
    return '${StringConst.SESION_TODO_EL_DIA_BADGE} — ${_formatDateLong(s.scheduledAt)}';
  }
  final start = s.scheduledAt;
  final end = s.fechaFin ?? start.add(_parseDuration(s.duracion));
  return '${StringConst.CALENDARIO_EVENT_INICIO_LABEL}: ${_formatDateTimeLong(start)}\n'
      '${StringConst.CALENDARIO_EVENT_FIN_LABEL}: ${_formatDateTimeLong(end)}';
}

String _participantsFor(Sesion s, Map<String, String>? names) {
  final ids = s.invitedParticipants;
  if (ids.isEmpty) return '';
  final header = '${StringConst.CALENDARIO_EVENT_PARTICIPANTES_LABEL}:';

  if (names == null || names.isEmpty) {
    return '$header\n${_countLabel(ids.length)}';
  }
  final resolved = <String>[];
  for (final id in ids) {
    final n = names[id];
    if (n != null && n.isNotEmpty) resolved.add(n);
  }
  if (resolved.isEmpty) {
    return '$header\n${_countLabel(ids.length)}';
  }
  return '$header\n${resolved.map((n) => '• $n').join('\n')}';
}

String _countLabel(int n) {
  final word = n == 1
      ? StringConst.SESION_PARTICIPANTE_SINGULAR
      : StringConst.SESION_PARTICIPANTES_PLURAL;
  return '$n $word';
}

String _formatDateLong(DateTime d) {
  try {
    return DateFormat("d 'de' MMMM yyyy", 'es_ES').format(d);
  } catch (_) {
    return DateFormat('d MMMM yyyy').format(d);
  }
}

String _formatDateTimeLong(DateTime d) {
  final hhmm = DateFormat('HH:mm').format(d);
  return '${_formatDateLong(d)}, $hhmm';
}

String _fallbackUid(Sesion s) =>
    '${s.tecnicoId}-${s.scheduledAt.millisecondsSinceEpoch}';

// ── Duration parsing ──────────────────────────────────────────────────────

Duration _parseDuration(String? raw) {
  if (raw == null) return const Duration(minutes: 60);
  final text = raw.toLowerCase();

  final combo = RegExp(r'(\d+)\s*h\D*?(\d+)\s*m').firstMatch(text);
  if (combo != null) {
    final h = int.tryParse(combo.group(1) ?? '') ?? 0;
    final m = int.tryParse(combo.group(2) ?? '') ?? 0;
    return _clamp(Duration(hours: h, minutes: m));
  }

  final hours = RegExp(r'(\d+)\s*h(ora)?s?').firstMatch(text);
  if (hours != null) {
    final h = int.tryParse(hours.group(1) ?? '') ?? 0;
    return _clamp(Duration(hours: h));
  }

  final minutes = RegExp(r'(\d+)\s*m(in(uto)?s?)?').firstMatch(text);
  if (minutes != null) {
    final m = int.tryParse(minutes.group(1) ?? '') ?? 0;
    return _clamp(Duration(minutes: m));
  }

  return const Duration(minutes: 60);
}

Duration _clamp(Duration d) {
  if (d.inMinutes <= 0) return const Duration(minutes: 60);
  if (d.inMinutes > 24 * 60) return const Duration(hours: 24);
  return d;
}

// ── Escaping + formatting ─────────────────────────────────────────────────

String _text(String input) => input
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', '');

String _utc(DateTime dt) {
  final d = dt.toUtc();
  return '${_pad(d.year, 4)}${_pad(d.month, 2)}${_pad(d.day, 2)}'
      'T${_pad(d.hour, 2)}${_pad(d.minute, 2)}${_pad(d.second, 2)}Z';
}

String _date(DateTime dt) =>
    '${_pad(dt.year, 4)}${_pad(dt.month, 2)}${_pad(dt.day, 2)}';

String _pad(int value, int width) => value.toString().padLeft(width, '0');
