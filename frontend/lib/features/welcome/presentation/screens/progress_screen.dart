import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<CalendarSessionModel> _sessions = [];

  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _dashboardService.getCalendarSessions();
    if (mounted) setState(() => _sessions = sessions);
  }

  List<CalendarSessionModel> _sessionsForDay(DateTime day) {
    return _sessions.where((s) =>
      s.date.year == day.year &&
      s.date.month == day.month &&
      s.date.day == day.day,
    ).toList();
  }

  List<CalendarSessionModel> _completedSessionsForMonth({DateTime? exclude}) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return _sessions
        .where((s) {
          final d = DateTime(s.date.year, s.date.month, s.date.day);
          if (s.date.year != _focusedMonth.year) return false;
          if (s.date.month != _focusedMonth.month) return false;
          if (d.isAfter(todayDate)) return false;
          if (exclude != null &&
              d == DateTime(exclude.year, exclude.month, exclude.day)) {
            return false;
          }
          return true;
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(),
              const SizedBox(height: 16),
              if (_selectedDay != null) ...[
                _buildSelectedDayCard(_selectedDay!),
                const SizedBox(height: 10),
              ],
              _buildCompletedSessionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: _buildMonthHeader(),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWeekDayLabels(),
              const SizedBox(height: 4),
              _buildDaysGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return _MonthHeader(
      focusedMonth: _focusedMonth,
      onPrevious: _previousMonth,
      onNext: _nextMonth,
    );
  }

  Widget _buildWeekDayLabels() {
    final labels = LocaleManager.strings.weekDayShort;
    return Row(
      children: labels
          .map((l) => Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDaysGrid() {
    const totalCells = 5 * 7; // siempre 5 filas
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1;
    final today = DateTime.now();

    final cells = <Widget>[];

    for (int i = 0; i < totalCells; i++) {
      final day = i - startOffset + 1;
      if (i < startOffset || day > daysInMonth) {
        cells.add(const SizedBox.shrink());
      } else {
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final sel = _selectedDay;
        final isSelected = sel != null &&
            sel.year == date.year &&
            sel.month == date.month &&
            sel.day == date.day;
        final daySessions = _sessionsForDay(date);
        cells.add(_buildDayCell(date, day, isToday, isSelected, daySessions));
      }
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: cells,
    );
  }

  Widget _buildDayCell(DateTime date, int day, bool isToday, bool isSelected,
      List<CalendarSessionModel> daySessions) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.white;
    if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = AppColors.primary.withValues(alpha: 0.2);
      textColor = AppColors.primary;
    }

    final hasCompleted = daySessions.any((s) => s.completed);
    final hasUpcoming = daySessions.any((s) => !s.completed);

    return GestureDetector(
      onTap: () => setState(() {
        _selectedDay = isSelected ? null : date;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasCompleted)
              Icon(Icons.check_rounded,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.greenAccent)
            else
              Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            if (!hasCompleted && hasUpcoming)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayCard(DateTime day) {
    final monthName = LocaleManager.strings.monthNames[day.month - 1];
    final dateLabel = LocaleManager.current == AppLocale.es
        ? '${day.day} de $monthName de ${day.year}'
        : '$monthName ${day.day}, ${day.year}';
    final daySessions = _sessionsForDay(day);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          if (daySessions.isEmpty)
            Text(
              LocaleManager.strings.noSessionsScheduled,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            )
          else
            ...daySessions.map((s) => _buildSessionCard(s, showDate: false)),
        ],
      ),
    );
  }

  Widget _buildCompletedSessionsList() {
    final completed = _completedSessionsForMonth(exclude: _selectedDay);
    if (completed.isEmpty) return const SizedBox.shrink();
    return Column(
      children: completed.map((s) => _buildSessionCard(s)).toList(),
    );
  }

  Widget _buildSessionCard(CalendarSessionModel session, {bool showDate = true}) {
    final monthName = LocaleManager.strings.monthNames[session.date.month - 1];
    final dateLabel = LocaleManager.current == AppLocale.es
        ? '${session.date.day} de $monthName'
        : '$monthName ${session.date.day}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.greenAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  showDate
                      ? '${dateLabel.toUpperCase()}  ·  ${session.time}  ·  ${session.durationMinutes} min'
                      : '${session.time}  ·  ${session.durationMinutes} min',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${LocaleManager.strings.monthNames[focusedMonth.month - 1]} ${focusedMonth.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }
}
