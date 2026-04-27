import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../services/workout_session_service.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  /// Número total de ejercicios completados en la sesión.
  final int exerciseCount;

  const WorkoutCompleteScreen({super.key, required this.exerciseCount});

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  // Fijamos la duración en initState para que no cambie con los rebuilds.
  late final int _elapsedSeconds;

  // Mock hasta que la API devuelva estos datos.
  static const int _streakDays = 5;
  static const String _achievementName = 'Madrugador de Acero';

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = WorkoutSessionService.elapsedSeconds;
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 24,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 520.0 : double.infinity),
              child: Column(
                children: [
                  _buildTrophy(isWide),
                  const SizedBox(height: 20),
                  _buildTitle(isWide),
                  const SizedBox(height: 28),
                  _buildStatsRow(isWide),
                  const SizedBox(height: 16),
                  _buildCongratulationsCard(),
                  const SizedBox(height: 12),
                  _buildStreakCard(),
                  const SizedBox(height: 12),
                  _buildAchievementCard(),
                  const SizedBox(height: 32),
                  _buildHomeButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) _goHome();
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.flag_rounded, color: AppColors.secondary, size: 24),
      ),
      title: const Text(
        'SESSION COMPLETE',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: _goHome,
        ),
      ],
    );
  }

  // ── Trofeo ────────────────────────────────────────────────────────────────

  Widget _buildTrophy(bool isWide) {
    final double size = isWide ? 110 : 90;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events_rounded,
        color: AppColors.primary,
        size: size * 0.48,
      ),
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────

  Widget _buildTitle(bool isWide) {
    return Column(
      children: [
        Text(
          '¡EXCELENTE!',
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 46 : 38,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'DÍA COMPLETADO',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Tarjetas de estadísticas ──────────────────────────────────────────────

  Widget _buildStatsRow(bool isWide) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.primary,
            value: '${widget.exerciseCount}',
            label: 'EJERCICIOS',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: Colors.orangeAccent,
            value: _formatDuration(_elapsedSeconds),
            label: 'DURACIÓN',
          ),
        ),
      ],
    );
  }

  // ── Tarjeta de felicitaciones ─────────────────────────────────────────────

  Widget _buildCongratulationsCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.celebration_rounded,
            color: AppColors.primary, size: 22),
      ),
      content: const Text(
        '¡Felicitaciones! Has completado tu sesión de hoy. Continúa así para alcanzar tus objetivos.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  // ── Tarjeta de racha ──────────────────────────────────────────────────────

  Widget _buildStreakCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.local_fire_department_rounded,
            color: Colors.orangeAccent, size: 22),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RACHA DE $_streakDays DÍAS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '¡Estás en llamas! No te detengas.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              _streakDays,
              (i) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: i < _streakDays
                      ? Colors.orangeAccent
                      : AppColors.border,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tarjeta de logro ──────────────────────────────────────────────────────

  Widget _buildAchievementCard() {
    return _InfoCard(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.surface,
        child: Icon(Icons.military_tech_rounded,
            color: Colors.amberAccent.shade400, size: 22),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary, size: 22),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NUEVO LOGRO',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _achievementName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón volver al inicio ────────────────────────────────────────────────

  Widget _buildHomeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _goHome,
        icon: const Icon(Icons.home_rounded, size: 22),
        label: const Text(
          'VOLVER AL INICIO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget leading;
  final Widget content;
  final Widget? trailing;

  const _InfoCard({
    required this.leading,
    required this.content,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(child: content),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
