import 'package:enreda_app/app/home/models/sesion.dart';
import 'package:enreda_app/app/home/sesiones/calendar/gcal_link.dart';
import 'package:enreda_app/app/home/sesiones/calendar/gcal_open.dart';
import 'package:enreda_app/app/home/sesiones/calendar/ics_download.dart';
import 'package:enreda_app/app/home/sesiones/calendar/ics_export.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Participant-facing calendar: a monthly grid showing the sessions the logged
/// in participant was invited to (`invitedParticipants` contains their userId),
/// plus a per-day / per-month list and one-tap "add to calendar" actions.
///
/// Mirrors the técnico calendar UI in `enredaEntidadSocial` (custom month grid
/// + side-by-side sessions panel on desktop, stacked on mobile). Read-only:
/// participants cannot create or edit sessions.
///
/// Filtering is server-side via `database.mySesionesStream(uid)`
/// (`where('invitedParticipants', arrayContains: uid).limit(100)`), satisfying
/// the §4.5 read guard. The stream is created once per uid (not per rebuild).
class SesionCalendarPage extends StatefulWidget {
  const SesionCalendarPage({super.key});

  @override
  State<SesionCalendarPage> createState() => _SesionCalendarPageState();
}

/// Maximum width of the calendar card on desktop.
const double _kCalendarMaxWidth = 520;

/// Filter buttons above the calendar — pill bar mirroring the Próximas /
/// Pasadas tabs from the técnico-facing `sesiones_page.dart`, plus a third
/// "Todas las sesiones" option. Defaults to [proximas] so participants land
/// on upcoming sessions first.
enum _CalendarFilter { proximas, pasadas, todas }

class _SesionCalendarPageState extends State<SesionCalendarPage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;
  _CalendarFilter _filter = _CalendarFilter.proximas;

  Stream<List<Sesion>>? _stream;
  String? _uid;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final uid = auth.currentUser?.uid ?? '';
    // Memoize the stream so we don't re-subscribe on every rebuild.
    if (_uid != uid) {
      _uid = uid;
      _stream = database.mySesionesStream(uid);
    }

    final isMobile = Responsive.isMobile(context);
    final isDesktop = !isMobile;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_30,
        vertical: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_24,
      ),
      child: StreamBuilder<List<Sesion>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorView(message: snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allSesiones = snapshot.data ?? <Sesion>[];

          // Index sessions by calendar date for O(1) lookup; sort each bucket.
          final Map<String, List<Sesion>> byDay = {};
          for (final s in allSesiones) {
            byDay.putIfAbsent(_dayKey(s.scheduledAt), () => []).add(s);
          }
          for (final list in byDay.values) {
            list.sort(_compareSessions);
          }

          final calendarCard = _CalendarCard(
            focusedMonth: _focusedMonth,
            sessionDays: byDay,
            selectedDay: _selectedDay,
            isMobile: isMobile,
            onPrevMonth: () => setState(() => _focusedMonth =
                DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
            onNextMonth: () => setState(() => _focusedMonth =
                DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
            onDayTap: (day) => setState(() {
              _selectedDay =
                  _selectedDay != null && _isSameDay(_selectedDay!, day)
                      ? null
                      : day;
            }),
          );

          final sessionsPanel = _SessionsPanel(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            allSesiones: allSesiones,
            sessionsByDay: byDay,
            isMobile: isMobile,
            filter: _filter,
            onFilterChange: (f) => setState(() {
              _filter = f;
              _selectedDay = null;
            }),
          );

          final panelHeader = _PanelHeader(
            isMobile: isMobile,
            onExport: () => _handleExportIcs(context, allSesiones),
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _kCalendarMaxWidth),
                        // Mirror the right column's panel header as an
                        // invisible spacer so the calendar's top lines up
                        // with the sessions panel (below the title), not
                        // with the panel header itself.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: false,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: panelHeader,
                            ),
                            const SizedBox(height: Sizes.PADDING_16),
                            calendarCard,
                          ],
                        ),
                      ),
                      const SizedBox(width: Sizes.PADDING_24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            panelHeader,
                            const SizedBox(height: Sizes.PADDING_16),
                            sessionsPanel,
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  calendarCard,
                  const SizedBox(height: Sizes.PADDING_20),
                  panelHeader,
                  const SizedBox(height: Sizes.PADDING_12),
                  sessionsPanel,
                ],
                SizedBox(height: isMobile ? Sizes.PADDING_30 : Sizes.PADDING_20),
              ],
            ),
          );
        },
      ),
    );
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _compareSessions(Sesion a, Sesion b) {
    if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
    if (a.isAllDay && b.isAllDay) return a.scheduledAt.compareTo(b.scheduledAt);
    final at = a.scheduledAt.hour * 60 + a.scheduledAt.minute;
    final bt = b.scheduledAt.hour * 60 + b.scheduledAt.minute;
    return at.compareTo(bt);
  }

  Future<void> _handleExportIcs(
      BuildContext context, List<Sesion> allSesiones) async {
    final messenger = ScaffoldMessenger.of(context);
    final monthSesiones = allSesiones
        .where((s) =>
            s.scheduledAt.year == _focusedMonth.year &&
            s.scheduledAt.month == _focusedMonth.month)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (monthSesiones.isEmpty) {
      messenger.showSnackBar(const SnackBar(
          content: Text(StringConst.CALENDARIO_EXPORT_ICS_EMPTY)));
      return;
    }
    try {
      final content = buildIcsCalendar(monthSesiones);
      final yyyymm =
          '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}';
      await downloadIcs(content, 'enreda-sesiones-$yyyymm.ics');
      messenger.showSnackBar(const SnackBar(
          content: Text(StringConst.CALENDARIO_EXPORT_ICS_SUCCESS)));
    } on UnsupportedError {
      messenger.showSnackBar(const SnackBar(
          content: Text(StringConst.CALENDARIO_EXPORT_ICS_UNSUPPORTED)));
    }
  }
}

// ── Panel header ────────────────────────────────────────────────────────────

/// Header rendered immediately ABOVE the sessions panel (right rail on
/// desktop, full width on mobile). Shows the section title on the left and
/// the "Descargar .ics" export button flush to the right.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.isMobile, required this.onExport});

  final bool isMobile;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            StringConst.MI_CALENDARIO,
            style: (isMobile ? textTheme.titleMedium : textTheme.headlineSmall)
                ?.copyWith(color: AppColors.primary900),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Sizes.PADDING_12),
        _ExportIcsButton(isMobile: isMobile, onPressed: onExport),
      ],
    );
  }
}

/// Right-aligned "Descargar .ics" button. Rendered inside [_PanelHeader].
class _ExportIcsButton extends StatelessWidget {
  const _ExportIcsButton({required this.isMobile, required this.onPressed});

  final bool isMobile;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Tooltip(
      message: StringConst.CALENDARIO_EXPORT_ICS_TOOLTIP,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.file_download_outlined,
          size: Sizes.ICON_SIZE_20,
          color: AppColors.primary900,
        ),
        label: Text(
          StringConst.CALENDARIO_EXPORT_ICS_LABEL,
          style: (isMobile ? textTheme.bodySmall : textTheme.bodyMedium)
              ?.copyWith(
            color: AppColors.primary900,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.greyBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.RADIUS_24),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_16,
            vertical: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_12,
          ),
        ),
      ),
    );
  }
}

// ── Calendar card ─────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.sessionDays,
    required this.selectedDay,
    required this.isMobile,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDayTap,
  });

  final DateTime focusedMonth;
  final Map<String, List<Sesion>> sessionDays;
  final DateTime? selectedDay;
  final bool isMobile;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withOpacity(0.1),
            blurRadius: Sizes.PADDING_20,
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? Sizes.PADDING_12 : Sizes.PADDING_24),
      child: Column(
        children: [
          _MonthNavBar(
            focusedMonth: focusedMonth,
            isMobile: isMobile,
            onPrev: onPrevMonth,
            onNext: onNextMonth,
          ),
          SizedBox(height: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_12),
          _CalendarLegend(isMobile: isMobile),
          SizedBox(height: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_16),
          _CalendarGrid(
            focusedMonth: focusedMonth,
            sessionDays: sessionDays,
            selectedDay: selectedDay,
            isMobile: isMobile,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}

class _MonthNavBar extends StatelessWidget {
  const _MonthNavBar({
    required this.focusedMonth,
    required this.isMobile,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final bool isMobile;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String label;
    try {
      label = DateFormat('MMMM yyyy', 'es_ES').format(focusedMonth);
      label = label[0].toUpperCase() + label.substring(1);
    } catch (_) {
      label = DateFormat('MMMM yyyy').format(focusedMonth);
    }
    final iconSize = isMobile ? Sizes.ICON_SIZE_20 : Sizes.ICON_SIZE_24;
    final iconPadding = isMobile
        ? const EdgeInsets.all(Sizes.PADDING_4)
        : const EdgeInsets.all(Sizes.PADDING_8);
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          padding: iconPadding,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.chevron_left,
              color: AppColors.primary900, size: iconSize),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: (isMobile ? textTheme.bodyLarge : textTheme.titleMedium)
                ?.copyWith(
              color: AppColors.primary900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          padding: iconPadding,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.chevron_right,
              color: AppColors.primary900, size: iconSize),
        ),
      ],
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: isMobile ? Sizes.PADDING_12 : Sizes.PADDING_20,
      runSpacing: Sizes.PADDING_8,
      children: [
        _LegendChip(
          color: AppColors.primary050,
          borderColor: AppColors.primary100,
          label: StringConst.CALENDARIO_LEGEND_UPCOMING,
        ),
        _LegendChip(
          color: AppColors.altWhite,
          borderColor: AppColors.greyBorder,
          label: StringConst.CALENDARIO_LEGEND_PAST,
        ),
        _LegendChip(
          color: AppColors.primary100,
          borderColor: AppColors.primary500,
          label: StringConst.CALENDARIO_LEGEND_TODAY,
        ),
        _LegendChip(
          color: AppColors.yellowDark,
          borderColor: AppColors.yellowDark,
          label: StringConst.CALENDARIO_LEGEND_SELECTED,
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Sizes.WIDTH_12,
          height: Sizes.HEIGHT_12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Sizes.RADIUS_4),
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        const SizedBox(width: Sizes.PADDING_6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.greyTxtAlt,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedMonth,
    required this.sessionDays,
    required this.selectedDay,
    required this.isMobile,
    required this.onDayTap,
  });

  final DateTime focusedMonth;
  final Map<String, List<Sesion>> sessionDays;
  final DateTime? selectedDay;
  final bool isMobile;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startOffset = (firstOfMonth.weekday - 1) % 7;
    final daysInMonth =
        DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final today = DateTime.now();
    final cellSpacing = isMobile ? Sizes.PADDING_2 : Sizes.PADDING_4;

    return Column(
      children: [
        Row(
          children: StringConst.CALENDARIO_WEEKDAYS
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.primary900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: Sizes.PADDING_8),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: cellSpacing,
            crossAxisSpacing: cellSpacing,
            childAspectRatio: isMobile ? 0.9 : 1.0,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startOffset) return const SizedBox.shrink();
            final day = index - startOffset + 1;
            final date = DateTime(focusedMonth.year, focusedMonth.month, day);
            final key = '${date.year}-${date.month}-${date.day}';
            final daySessions = sessionDays[key] ?? const <Sesion>[];
            final isSelected = selectedDay != null &&
                selectedDay!.year == date.year &&
                selectedDay!.month == date.month &&
                selectedDay!.day == date.day;
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isPast =
                date.isBefore(DateTime(today.year, today.month, today.day));

            return _DayCell(
              day: day,
              date: date,
              sessions: daySessions,
              isSelected: isSelected,
              isToday: isToday,
              isPast: isPast,
              isMobile: isMobile,
              onTap: () => onDayTap(date),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.sessions,
    required this.isSelected,
    required this.isToday,
    required this.isPast,
    required this.isMobile,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final List<Sesion> sessions;
  final bool isSelected;
  final bool isToday;
  final bool isPast;
  final bool isMobile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSessions = sessions.isNotEmpty;

    Color bgColor = Colors.transparent;
    Color textColor = isPast ? AppColors.greyTxtAlt : AppColors.primary900;
    bool boldText = false;

    if (isSelected) {
      bgColor = AppColors.yellowDark;
      textColor = AppColors.primary900;
      boldText = true;
    } else if (isToday) {
      bgColor = AppColors.primary100;
      textColor = AppColors.primary900;
      boldText = true;
    } else if (hasSessions) {
      bgColor = isPast ? AppColors.altWhite : AppColors.primary050;
      boldText = true;
    }

    Border? border;
    if (isToday && !isSelected) {
      border = Border.all(color: AppColors.primary500, width: 1.5);
    } else if (hasSessions && !isSelected && !isToday) {
      border = Border.all(
        color: isPast ? AppColors.greyBorder : AppColors.primary100,
        width: 1,
      );
    }

    final indicatorColor = isPast ? AppColors.greyTxtAlt : AppColors.primary500;
    final dayTextStyle =
        (isMobile ? textTheme.bodySmall : textTheme.bodyMedium)?.copyWith(
      color: textColor,
      fontWeight: boldText ? FontWeight.w700 : FontWeight.w400,
    );
    final badgeMinSize = isMobile ? 14.0 : 16.0;

    final cellInterior = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
          border: border,
        ),
        child: Stack(
          children: [
            Center(child: Text('$day', style: dayTextStyle)),
            if (hasSessions)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: badgeMinSize,
                    minHeight: badgeMinSize,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(Sizes.RADIUS_10),
                  ),
                  child: Center(
                    child: Text(
                      '${sessions.length}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 9.0 : 10.0,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!hasSessions) return cellInterior;

    return Tooltip(
      waitDuration: const Duration(milliseconds: 250),
      preferBelow: false,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.PADDING_12,
        vertical: Sizes.PADDING_8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary900,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
      ),
      textStyle: textTheme.bodySmall!.copyWith(color: AppColors.white),
      richMessage: _buildTooltipMessage(textTheme),
      child: cellInterior,
    );
  }

  InlineSpan _buildTooltipMessage(TextTheme textTheme) {
    final headerStyle = textTheme.bodySmall!
        .copyWith(color: AppColors.white, fontWeight: FontWeight.w700);
    final lineStyle = textTheme.bodySmall!.copyWith(color: AppColors.white);

    String header;
    try {
      header = DateFormat("EEEE d 'de' MMM", 'es_ES').format(date);
      header = header[0].toUpperCase() + header.substring(1);
    } catch (_) {
      header = DateFormat('EEE d MMM').format(date);
    }
    final countLabel = sessions.length == 1
        ? '1 ${StringConst.CALENDARIO_HOVER_SESION_SINGULAR}'
        : '${sessions.length} ${StringConst.CALENDARIO_HOVER_SESION_PLURAL}';

    final preview = sessions.take(3).toList();
    final more = sessions.length - preview.length;

    final spans = <InlineSpan>[
      TextSpan(text: '$header · $countLabel\n', style: headerStyle),
    ];
    for (final s in preview) {
      spans.add(TextSpan(
        text: '${_formatSessionTimePrefix(s)} — ${_titleFor(s)}\n',
        style: lineStyle,
      ));
    }
    if (more > 0) {
      spans.add(TextSpan(
        text: StringConst.CALENDARIO_HOVER_AND_MORE
            .replaceAll('%COUNT%', more.toString()),
        style: lineStyle.copyWith(fontStyle: FontStyle.italic),
      ));
    }
    return TextSpan(children: spans);
  }
}

// ── Sessions panel ──────────────────────────────────────────────────────────

/// Right-rail panel. Two modes:
///   * **Selected day** → that day's sessions; header says "Próxima sesión"
///     or "Sesión pasada" depending on whether the day is in the future or
///     in the past relative to today.
///   * **No day selected** → driven by [filter]:
///       - `proximas` → upcoming sessions only (asc by scheduledAt)
///       - `pasadas`  → past sessions only (desc by scheduledAt)
///       - `todas`    → Próximas section first, Pasadas section below
class _SessionsPanel extends StatelessWidget {
  const _SessionsPanel({
    required this.focusedMonth,
    required this.selectedDay,
    required this.allSesiones,
    required this.sessionsByDay,
    required this.isMobile,
    required this.filter,
    required this.onFilterChange,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final List<Sesion> allSesiones;
  final Map<String, List<Sesion>> sessionsByDay;
  final bool isMobile;
  final _CalendarFilter filter;
  final ValueChanged<_CalendarFilter> onFilterChange;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      // Always fill the parent column. Without this the Container shrinks to
      // its content width — which on an empty "Próximas sesiones" state
      // (just a header + a one-line "No tienes ninguna sesión" message)
      // leaves the panel visibly narrower than the panel header above it.
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary900.withOpacity(0.06),
            blurRadius: Sizes.PADDING_16,
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? Sizes.PADDING_16 : Sizes.PADDING_24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter pills — Próximas / Pasadas / Todas. Mounted INSIDE the
          // panel container so they read as part of the same surface as the
          // sessions list they filter. Tapping a pill also clears any day
          // selection so the panel re-renders from the new filter rather
          // than the previously selected day.
          _CalendarFilterBar(
            activeFilter: filter,
            onSelect: onFilterChange,
          ),
          SizedBox(height: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_20),
          Text(
            _resolveHeader(),
            style: (isMobile ? textTheme.titleMedium : textTheme.headlineSmall)
                ?.copyWith(color: AppColors.primary900),
          ),
          SizedBox(height: isMobile ? Sizes.PADDING_8 : Sizes.PADDING_12),
          ..._buildBody(textTheme),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────

  List<Widget> _buildBody(TextTheme textTheme) {
    if (selectedDay != null) {
      final key =
          '${selectedDay!.year}-${selectedDay!.month}-${selectedDay!.day}';
      final daySessions =
          List<Sesion>.from(sessionsByDay[key] ?? const <Sesion>[]);
      if (daySessions.isEmpty) {
        return [_emptyText(textTheme, StringConst.CALENDARIO_EMPTY_DAY)];
      }
      return daySessions.map(_row).toList();
    }

    switch (filter) {
      case _CalendarFilter.proximas:
        return _renderFlatBody(
          textTheme,
          _futureSessions(),
          emptyLabel: StringConst.SESION_EMPTY_PROXIMAS,
        );
      case _CalendarFilter.pasadas:
        return _renderFlatBody(
          textTheme,
          _pastSessions(),
          emptyLabel: StringConst.SESION_EMPTY_PASADAS,
        );
      case _CalendarFilter.todas:
        return _renderTodasBody(textTheme);
    }
  }

  List<Widget> _renderFlatBody(
    TextTheme textTheme,
    List<Sesion> sessions, {
    required String emptyLabel,
  }) {
    if (sessions.isEmpty) {
      return [
        _emptyText(
          textTheme,
          allSesiones.isEmpty ? StringConst.CALENDARIO_EMPTY : emptyLabel,
        ),
      ];
    }
    return sessions.map(_row).toList();
  }

  /// "Todas las sesiones" view — Próximas section first, then Pasadas. Each
  /// section has its own subheader; sections are skipped when empty.
  List<Widget> _renderTodasBody(TextTheme textTheme) {
    final proximas = _futureSessions();
    final pasadas = _pastSessions();
    if (proximas.isEmpty && pasadas.isEmpty) {
      return [_emptyText(textTheme, StringConst.CALENDARIO_EMPTY)];
    }
    return [
      if (proximas.isNotEmpty) ...[
        _SectionHeader(
          label: StringConst.CALENDARIO_FILTER_PROXIMAS,
          isMobile: isMobile,
        ),
        ...proximas.map(_row),
      ],
      if (pasadas.isNotEmpty) ...[
        if (proximas.isNotEmpty) const SizedBox(height: Sizes.PADDING_20),
        _SectionHeader(
          label: StringConst.CALENDARIO_FILTER_PASADAS,
          isMobile: isMobile,
        ),
        ...pasadas.map(_row),
      ],
    ];
  }

  Widget _row(Sesion s) => _ParticipantSesionRow(sesion: s);

  Widget _emptyText(TextTheme textTheme, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.PADDING_16),
        child: Text(
          label,
          style:
              textTheme.bodyMedium?.copyWith(color: AppColors.greyTxtAlt),
        ),
      );

  // ── Header ──────────────────────────────────────────────────────────────

  String _resolveHeader() {
    if (selectedDay != null) {
      return _isPastDay(selectedDay!)
          ? StringConst.CALENDARIO_PANEL_SESION_PASADA
          : StringConst.CALENDARIO_PANEL_PROXIMA_SESION;
    }
    switch (filter) {
      case _CalendarFilter.proximas:
        return StringConst.CALENDARIO_FILTER_PROXIMAS;
      case _CalendarFilter.pasadas:
        return StringConst.CALENDARIO_FILTER_PASADAS;
      case _CalendarFilter.todas:
        return StringConst.CALENDARIO_FILTER_TODAS;
    }
  }

  // ── Session bucketing ───────────────────────────────────────────────────

  List<Sesion> _futureSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allSesiones
        .where((s) => !s.scheduledAt.isBefore(today))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<Sesion> _pastSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return allSesiones
        .where((s) => s.scheduledAt.isBefore(today))
        .toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  }

  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dm = DateTime(day.year, day.month, day.day);
    return dm.isBefore(today);
  }
}

// ── Filter pill bar ─────────────────────────────────────────────────────────

/// Three-pill filter bar shown above the calendar. Mirrors the
/// `_SesionTabPill` from `enredaEntidadSocial/sesiones_page.dart` — yellow
/// fill + bold primary900 text when active; white fill + violet border +
/// greyTxtAlt text when not.
class _CalendarFilterBar extends StatelessWidget {
  const _CalendarFilterBar({
    required this.activeFilter,
    required this.onSelect,
  });

  final _CalendarFilter activeFilter;
  final ValueChanged<_CalendarFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Sizes.PADDING_8,
      runSpacing: Sizes.PADDING_8,
      children: [
        _FilterPill(
          label: StringConst.CALENDARIO_FILTER_PROXIMAS,
          isActive: activeFilter == _CalendarFilter.proximas,
          onTap: () => onSelect(_CalendarFilter.proximas),
        ),
        _FilterPill(
          label: StringConst.CALENDARIO_FILTER_PASADAS,
          isActive: activeFilter == _CalendarFilter.pasadas,
          onTap: () => onSelect(_CalendarFilter.pasadas),
        ),
        _FilterPill(
          label: StringConst.CALENDARIO_FILTER_TODAS,
          isActive: activeFilter == _CalendarFilter.todas,
          onTap: () => onSelect(_CalendarFilter.todas),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.PADDING_16,
          vertical: Sizes.PADDING_6,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.yellowDark : AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
          border: Border.all(
            color: isActive ? AppColors.yellowDark : AppColors.violet,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color:
                isActive ? AppColors.primary900 : AppColors.greyTxtAlt,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Section subheader used in the "Todas las sesiones" view to label the
/// Próximas / Pasadas groupings.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isMobile});

  final String label;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: Sizes.PADDING_4,
        bottom: Sizes.PADDING_8,
      ),
      child: Text(
        label,
        style: (isMobile ? textTheme.bodyLarge : textTheme.titleMedium)
            ?.copyWith(
          color: AppColors.primary900,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Read-only session row in the panel: the gCal "add to calendar" icon sits
/// above the card; everything else — title, date, time range (start — end),
/// optional location and modality chip — lives INSIDE the session card so
/// the time stays visually paired with its session.
class _ParticipantSesionRow extends StatelessWidget {
  const _ParticipantSesionRow({required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.PADDING_12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // gCal action sits above the card; the time range moved inside.
          Padding(
            padding: const EdgeInsets.only(
              left: Sizes.PADDING_8,
              right: Sizes.PADDING_4,
              bottom: Sizes.PADDING_4,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: _GcalAddIconButton(sesion: sesion),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary900.withOpacity(0.08),
                  blurRadius: Sizes.PADDING_12,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.PADDING_16,
              horizontal: Sizes.PADDING_16,
            ),
            child: Row(
              children: [
                _LeadingIcon(sessionType: sesion.sessionType),
                const SizedBox(width: Sizes.PADDING_12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _titleFor(sesion),
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary900,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Sizes.PADDING_2),
                      Text(
                        _formatDateLong(sesion.scheduledAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.greyTxtAlt,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Sizes.PADDING_2),
                      // Same styling as the date line above (bodySmall +
                      // greyTxtAlt) so the date and the start-end range read
                      // as one paragraph rather than two competing emphasis
                      // levels.
                      Text(
                        _formatSessionTimeRange(sesion),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.greyTxtAlt,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sesion.lugar != null &&
                          sesion.lugar!.trim().isNotEmpty) ...[
                        const SizedBox(height: Sizes.PADDING_2),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: Sizes.ICON_SIZE_14,
                              color: AppColors.greyTxtAlt,
                            ),
                            const SizedBox(width: Sizes.PADDING_4),
                            Expanded(
                              child: Text(
                                sesion.lugar!,
                                style: textTheme.bodySmall
                                    ?.copyWith(color: AppColors.greyTxtAlt),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: Sizes.PADDING_8),
                _ModalityChip(modality: sesion.modality),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.sessionType});

  final String sessionType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Sizes.WIDTH_44,
      height: Sizes.HEIGHT_44,
      decoration: const BoxDecoration(
        color: AppColors.primary050,
        shape: BoxShape.circle,
      ),
      child: Icon(
        sessionType == SesionType.grupal
            ? Icons.groups_outlined
            : Icons.person_outline,
        color: AppColors.primary900,
        size: Sizes.ICON_SIZE_24,
      ),
    );
  }
}

/// Modality pill — ONLINE / PRESENCIAL / Mixta — rendered locally from
/// primitives so it reads pixel-for-pixel identical to the entidadSocial
/// `_ModalityChip` (which is itself a `CustomChip` in selected mode).
///
/// Why not the shared `CustomChip`? enreda-app's `CustomChip` injects a
/// Material check-icon next to the label whenever `selected: true`, while
/// entidadSocial's variant does not — so routing through the shared widget
/// would render an extra glyph that the técnico-side card never shows.
class _ModalityChip extends StatelessWidget {
  const _ModalityChip({required this.modality});

  final String modality;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.primary900,
        borderRadius: BorderRadius.circular(20),
      ),
      // Raw TextStyle (intentional §6 deviation, scoped to this widget) to
      // match entidadSocial's `CustomChip` byte-for-byte — that widget also
      // hardcodes its label TextStyle, so the only way to keep the two apps
      // visually in lockstep is to mirror it here.
      child: Text(
        _labelFor(modality),
        style: const TextStyle(
          color: AppColors.greyChip,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  String _labelFor(String modality) {
    switch (modality) {
      case SesionModality.online:
        return StringConst.SESION_ONLINE_LABEL;
      case SesionModality.blended:
        return StringConst.SESION_BLENDED_LABEL;
      case SesionModality.presencial:
      default:
        return StringConst.SESION_PRESENCIAL_LABEL;
    }
  }
}

/// "Añadir a Google Calendar" icon — opens the gCal compose URL pre-filled.
class _GcalAddIconButton extends StatelessWidget {
  const _GcalAddIconButton({required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: StringConst.SESION_BUTTON_GCAL,
      onPressed: () => _handleAdd(context),
      padding: const EdgeInsets.all(Sizes.PADDING_4),
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
      icon: const Icon(
        Icons.event_available_outlined,
        color: AppColors.primary400,
        size: Sizes.ICON_SIZE_20,
      ),
    );
  }

  Future<void> _handleAdd(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await openExternalUrl(buildGoogleCalendarUrl(sesion));
    } on UnsupportedError {
      messenger.showSnackBar(const SnackBar(
          content: Text(StringConst.SESION_GCAL_UNSUPPORTED)));
    }
  }
}

// ── Module-level helpers ────────────────────────────────────────────────────

String _formatSessionTimePrefix(Sesion s) {
  if (s.isAllDay) return StringConst.SESION_TODO_EL_DIA_BADGE;
  return _hhmm(s.scheduledAt);
}

/// "HH:mm — HH:mm" when [Sesion.fechaFin] is set; falls back to the start
/// time alone when no explicit end was recorded. Returns the "Todo el día"
/// badge for all-day sessions. Used only by the in-card time line; the
/// hover tooltip keeps the shorter [_formatSessionTimePrefix] for brevity.
String _formatSessionTimeRange(Sesion s) {
  if (s.isAllDay) return StringConst.SESION_TODO_EL_DIA_BADGE;
  final start = _hhmm(s.scheduledAt);
  final end = s.fechaFin;
  return end == null ? start : '$start — ${_hhmm(end)}';
}

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _titleFor(Sesion s) {
  if (s.title != null && s.title!.trim().isNotEmpty) return s.title!;
  return s.sessionType == SesionType.grupal
      ? StringConst.SESION_GRUPAL
      : StringConst.SESION_INDIVIDUAL;
}

String _formatDateLong(DateTime d) {
  try {
    return DateFormat("d 'de' MMMM yyyy", 'es_ES').format(d);
  } catch (_) {
    return DateFormat('d MMMM yyyy').format(d);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.PADDING_30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.red, size: Sizes.ICON_SIZE_60),
            const SizedBox(height: Sizes.PADDING_16),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  textTheme.bodyMedium?.copyWith(color: AppColors.greyTxtAlt),
            ),
          ],
        ),
      ),
    );
  }
}
