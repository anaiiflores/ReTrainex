import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TimePickerField extends StatelessWidget {
  final String time;
  final ValueChanged<String> onChanged;

  const TimePickerField({
    super.key,
    required this.time,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final parts = time.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final isPm = parts.length > 1 && parts[1] == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: int.parse(hm[1])),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.card,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final h = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final m = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    onChanged('$h:$m $period');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
