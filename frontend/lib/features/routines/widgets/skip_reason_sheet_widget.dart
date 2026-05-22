import 'package:flutter/material.dart';
import '../../../core/strings/locale_manager.dart';
import '../../../core/theme/app_colors.dart';

enum SkipReason { dontKnow, cantNow, pain }

String get _kQuestion => LocaleManager.strings.skipQuestion;

List<({String label, IconData icon, Color color, SkipReason reason})>
    get _kOptions => [
  (
    label: LocaleManager.strings.skipDontKnow,
    icon: Icons.help_outline_rounded,
    color: AppColors.textSecondary,
    reason: SkipReason.dontKnow,
  ),
  (
    label: LocaleManager.strings.skipCantNow,
    icon: Icons.schedule_rounded,
    color: AppColors.textSecondary,
    reason: SkipReason.cantNow,
  ),
  (
    label: LocaleManager.strings.skipPain,
    icon: Icons.medical_services_outlined,
    color: Colors.redAccent,
    reason: SkipReason.pain,
  ),
];

class SkipReasonSheet extends StatelessWidget {
  const SkipReasonSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _kQuestion,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ..._kOptions.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SkipOption(
                  label: o.label,
                  icon: o.icon,
                  color: o.color,
                  onTap: () => Navigator.of(context).pop(o.reason),
                ),
              )),
        ],
      ),
    );
  }
}

class _SkipOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SkipOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
