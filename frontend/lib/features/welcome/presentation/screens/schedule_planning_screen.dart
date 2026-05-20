import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/time_picker_field.dart';

class SchedulePlanningScreen extends StatefulWidget {
  const SchedulePlanningScreen({super.key});

  @override
  State<SchedulePlanningScreen> createState() => _SchedulePlanningScreenState();
}

class _SchedulePlanningScreenState extends State<SchedulePlanningScreen> {
  final Set<int> _selectedDays = {0, 2, 4}; // LUN, MIÉ, VIE por defecto
  String _time = '10:30 AM';

  void _toggleDay(int index) {
    setState(() {
      if (_selectedDays.contains(index)) {
        if (_selectedDays.length > 1) _selectedDays.remove(index);
      } else {
        _selectedDays.add(index);
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 24,
            vertical: 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 480.0 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(isWide),
                  const SizedBox(height: 32),
                  _buildDaySection(),
                  const SizedBox(height: 32),
                  _buildTimeSection(),
                  const SizedBox(height: 40),
                  _buildStartButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        LocaleManager.strings.appName,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────

  Widget _buildTitle(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.formPlanTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 38 : 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleManager.strings.formPlanSubtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ── Selección de días ─────────────────────────────────────────────────────

  Widget _buildDaySection() {
    final labels = LocaleManager.strings.weekDayMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.formSelectDays,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            labels.length,
            (i) => _DayBubble(
              label: labels[i],
              isSelected: _selectedDays.contains(i),
              onTap: () => _toggleDay(i),
            ),
          ),
        ),
      ],
    );
  }

  // ── Selector de hora ──────────────────────────────────────────────────────

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.formActivityTime,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        TimePickerField(
          time: _time,
          onChanged: (value) => setState(() => _time = value),
        ),
      ],
    );
  }

  // ── Botón empezar ─────────────────────────────────────────────────────────

  Widget _buildStartButton(BuildContext context) {
    return AppGradientButton(
      label: LocaleManager.strings.formStart,
      onPressed: () => Navigator.of(context).pop(),
      icon: Icons.rocket_launch_rounded,
      height: 58,
      borderRadius: 30,
    );
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

class _DayBubble extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayBubble({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.transparent : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}