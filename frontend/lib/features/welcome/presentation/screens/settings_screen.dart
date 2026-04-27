import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _remindersEnabled = true;
  String _notificationTime = '10:00 AM';

  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;
  late final List<Animation<Offset>> _slides;
  late final List<Animation<double>> _fades;

  static const int _tileCount = 7;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _slides = List.generate(_tileCount, (i) {
      final start = (i * 0.1).clamp(0.0, 0.65);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(-0.12, 0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _fades = List.generate(_tileCount, (i) {
      final start = (i * 0.1).clamp(0.0, 0.65);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Interval(start, end)),
      );
    });

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _tile(int i, Widget child) => SlideTransition(
        position: _slides[i],
        child: FadeTransition(opacity: _fades[i], child: child),
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 16,
        vertical: isWide ? 36 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isWide ? 560.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tile(0, const _SectionLabel(
                icon: Icons.notifications_rounded,
                label: 'Notificaciones',
              )),
              const SizedBox(height: 10),
              _tile(1, _buildNotifCard()),
              const SizedBox(height: 28),
              _tile(4, const _SectionLabel(
                icon: Icons.person_rounded,
                label: 'Perfil',
              )),
              const SizedBox(height: 10),
              _tile(5, _buildProfileCard()),
              const SizedBox(height: 36),
              _tile(6, _buildFooter()),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Notificaciones ─────────────────────────────────────────────────────────

  Widget _buildNotifCard() {
    return _Card(
      children: [
        _tile(2, _RemindersRow(
          value: _remindersEnabled,
          onChanged: (v) {
            setState(() => _remindersEnabled = v);
            if (v && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Text('⚡', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        '¡Recordatorios activados!',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        )),
        const _TileDivider(),
        _tile(3, _SettingsTile(
          icon: Icons.access_time_rounded,
          iconColor: AppColors.secondary,
          title: 'Horario',
          subtitle: _remindersEnabled ? _notificationTime : '—',
          enabled: _remindersEnabled,
          onTap: _remindersEnabled ? _pickTime : null,
        )),
        const _TileDivider(),
        _SettingsTile(
          icon: Icons.help_outline_rounded,
          iconColor: AppColors.textSecondary,
          title: 'Preguntas frecuentes',
          onTap: _showFaq,
        ),
      ],
    );
  }

  // ── Perfil ─────────────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    return _Card(
      children: [
        _SettingsTile(
          icon: Icons.account_circle_rounded,
          iconColor: AppColors.primary,
          iconBg: true,
          title: 'Datos personales',
          subtitle: 'Nombre, edad, peso',
          onTap: () {},
        ),
        const _TileDivider(),
        _SettingsTile(
          icon: Icons.visibility_rounded,
          iconColor: AppColors.textSecondary,
          title: 'Accesibilidad',
          subtitle: 'Tamaño de texto, contraste',
          onTap: () {},
        ),
        const _TileDivider(),
        _SettingsTile(
          icon: Icons.language_rounded,
          iconColor: AppColors.textSecondary,
          title: 'Idioma',
          subtitle: 'Español',
          onTap: () {},
        ),
      ],
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final glow = 0.3 + 0.7 * _pulseCtrl.value;
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.primary.withValues(alpha: glow * 0.65),
                      blurRadius: 18 + 14 * _pulseCtrl.value,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 36),
              );
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'ReTrainex',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Versión 1.0.0',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            '© 2026 ReTrainex. Todos los derechos reservados.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Acciones ───────────────────────────────────────────────────────────────

  Future<void> _pickTime() async {
    final parts = _notificationTime.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final isPm = parts.length > 1 && parts[1] == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: hour, minute: int.parse(hm[1])),
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
    if (!mounted || picked == null) return;
    final h = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final m = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    setState(() => _notificationTime = '$h:$m $period');
  }

  void _showFaq() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FaqSheet(),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Card container ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

// ── Tile divider ──────────────────────────────────────────────────────────────

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}

// ── Reminders toggle row ──────────────────────────────────────────────────────

class _RemindersRow extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _RemindersRow({required this.value, required this.onChanged});

  @override
  State<_RemindersRow> createState() => _RemindersRowState();
}

class _RemindersRowState extends State<_RemindersRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    await _bounceCtrl.reverse();
    widget.onChanged(!widget.value);
    _bounceCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recordatorios',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Recibe alertas para tus ejercicios',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ScaleTransition(
            scale: _bounceCtrl,
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOut,
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: widget.value
                      ? AppColors.primary
                      : AppColors.border,
                  boxShadow: widget.value
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                  alignment: widget.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final bool iconBg;
  final String title;
  final String? subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    this.iconBg = false,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.onTap == null || !widget.enabled) return;
    await _ctrl.reverse();
    _ctrl.forward();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                widget.iconBg
                    ? Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color:
                              widget.iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon,
                            color: widget.iconColor, size: 20),
                      )
                    : Icon(widget.icon,
                        color: widget.iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.onTap != null)
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── FAQ Bottom Sheet ──────────────────────────────────────────────────────────

class _FaqSheet extends StatelessWidget {
  const _FaqSheet();

  static const List<_FaqData> _faqs = [
    _FaqData(
      question: '¿Puedo saltar ejercicios?',
      answer:
          'Sí, puedes omitir cualquier ejercicio. Sin embargo, te recomendamos hablar con tu fisioterapeuta antes de hacerlo con frecuencia.',
    ),
    _FaqData(
      question: '¿Qué pasa si me duele?',
      answer:
          'Para inmediatamente el ejercicio y contacta con tu fisioterapeuta. Nunca fuerces un movimiento que cause dolor agudo.',
    ),
    _FaqData(
      question: '¿Con qué frecuencia debo hacer las sesiones?',
      answer:
          'Tu fisioterapeuta ha diseñado un plan específico para ti. Sigue los días asignados para mejores resultados.',
    ),
    _FaqData(
      question: '¿Cómo cambio mi horario de recordatorio?',
      answer:
          'Ve a Ajustes → Notificaciones → Horario y selecciona la hora que prefieras.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'PREGUNTAS FRECUENTES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                controller: ctrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: _faqs.length,
                itemBuilder: (_, i) => _FaqItem(data: _faqs[i]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FaqData {
  final String question;
  final String answer;
  const _FaqData({required this.question, required this.answer});
}

class _FaqItem extends StatefulWidget {
  final _FaqData data;
  const _FaqItem({required this.data});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _expanded
              ? AppColors.primary.withValues(alpha: 0.09)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 280),
                  turns: _expanded ? 0.5 : 0.0,
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary, size: 22),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.data.answer,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
            ),
          ],
        ),
      ),
    );
  }
}
