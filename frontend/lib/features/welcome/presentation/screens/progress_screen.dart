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
              if (_selectedDay != null) ...[
                const SizedBox(height: 16),
                _buildSelectedDayInfo(),
              ],
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
        final selected = _selectedDay;
        final isSelected = selected != null &&
            selected.year == date.year &&
            selected.month == date.month &&
            selected.day == date.day;
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
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasCompleted)
                  Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: isSelected ? Colors.white : Colors.greenAccent,
                  )
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
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    final day = _selectedDay;
    if (day == null) return const SizedBox.shrink();
    final monthName = LocaleManager.strings.monthNames[day.month - 1];
    final label = LocaleManager.current == AppLocale.es
        ? '${day.day} de $monthName de ${day.year}'
        : '$monthName ${day.day}, ${day.year}';
    final daySessions = _sessionsForDay(day);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
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
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
          else
            ...daySessions.map((s) => _buildSessionRow(s)),
        ],
      ),
    );
  }

  Widget _buildSessionRow(CalendarSessionModel session) {
    final dotColor = session.completed ? Colors.greenAccent : AppColors.secondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              session.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${session.time}  ·  ${session.durationMinutes} min',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
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
