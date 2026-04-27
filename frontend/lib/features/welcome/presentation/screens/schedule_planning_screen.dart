import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SchedulePlanningScreen extends StatefulWidget {
  const SchedulePlanningScreen({super.key});

  @override
  State<SchedulePlanningScreen> createState() => _SchedulePlanningScreenState();
}

class _SchedulePlanningScreenState extends State<SchedulePlanningScreen> {
  // ── Estado local (no se envía al backend) ────────────────────────────────
  final Set<int> _selectedDays = {0, 2, 4}; // LUN, MIÉ, VIE por defecto
  int _hour = 10;
  int _minute = 30;
  bool _isAm = true;

  static const List<String> _dayLabels = [
    'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM',
  ];

  // ── Lógica de selección ───────────────────────────────────────────────────

  void _toggleDay(int index) {
    setState(() {
      if (_selectedDays.contains(index)) {
        if (_selectedDays.length > 1) _selectedDays.remove(index);
      } else {
        _selectedDays.add(index);
      }
    });
  }

  void _changeHour(int delta) {
    setState(() {
      _hour = ((_hour - 1 + delta) % 12 + 12) % 12 + 1;
    });
  }

  void _changeMinute(int delta) {
    setState(() {
      _minute = (_minute + delta * 5 + 60) % 60;
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
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: const Text(
        'RETRAINEX',
        style: TextStyle(
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
          'Planifica tu éxito',
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 38 : 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configura tu rutina de hoy',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ── Selección de días ─────────────────────────────────────────────────────

  Widget _buildDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECCIONA LOS DÍAS',
          style: TextStyle(
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
            _dayLabels.length,
            (i) => _DayBubble(
              label: _dayLabels[i],
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
        const Text(
          'HORA DE LA ACTIVIDAD',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimeSpinner(
                      value: _hour.toString().padLeft(2, '0'),
                      onUp: () => _changeHour(1),
                      onDown: () => _changeHour(-1),
                      fontSize: 64,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    _TimeSpinner(
                      value: _minute.toString().padLeft(2, '0'),
                      onUp: () => _changeMinute(1),
                      onDown: () => _changeMinute(-1),
                      fontSize: 64,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildAmPmToggle(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmPmToggle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AmPmButton(
          label: 'AM',
          isSelected: _isAm,
          onTap: () => setState(() => _isAm = true),
        ),
        const SizedBox(height: 8),
        _AmPmButton(
          label: 'PM',
          isSelected: !_isAm,
          onTap: () => setState(() => _isAm = false),
        ),
      ],
    );
  }

  // ── Botón empezar ─────────────────────────────────────────────────────────

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.rocket_launch_rounded, size: 22),
          label: const Text(
            'EMPEZAR',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
      ),
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
          color: isSelected
              ? Colors.transparent
              : AppColors.surface,
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

class _TimeSpinner extends StatelessWidget {
  final String value;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final double fontSize;

  const _TimeSpinner({
    required this.value,
    required this.onUp,
    required this.onDown,
    this.fontSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onUp,
          child: const Icon(Icons.keyboard_arrow_up_rounded,
              color: AppColors.textSecondary, size: 32),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        GestureDetector(
          onTap: onDown,
          child: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 32),
        ),
      ],
    );
  }
}

class _AmPmButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmPmButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
