import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button_widget.dart';
import '../../../../shared/widgets/video_area_widget.dart';
import '../../models/routine_detail_model.dart';
import 'workout_preparation_screen.dart';
import '../../services/workout_session_service.dart';

class SessionPausedScreen extends StatelessWidget {
  final ExerciseModel exercise;
  final List<ExerciseModel> exercises;
  final int currentIndex;
  final bool fromWorkout;

  const SessionPausedScreen({
    super.key,
    required this.exercise,
    required this.exercises,
    required this.currentIndex,
    this.fromWorkout = false,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    if (s == 0) return '${m}min';
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _startExercise(BuildContext context) {
    WorkoutSessionService.markStart();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutPreparationScreen(
          exercises: exercises,
          currentIndex: currentIndex,
        ),
      ),
    );
  }

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
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 520.0 : double.infinity),
              child: Column(
                children: [
                  _buildVideoArea(isWide),
                  const SizedBox(height: 20),
                  _buildTitle(isWide),
                  const SizedBox(height: 28),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),
                  const SizedBox(height: 12),
                  _buildTipsCard(),
                  const SizedBox(height: 32),
                  AppGradientButton(
                    label: fromWorkout
                        ? 'VOLVER AL EJERCICIO'
                        : 'INICIAR EJERCICIO',
                    onPressed: fromWorkout
                        ? () => Navigator.of(context).pop()
                        : () => _startExercise(context),
                    icon: fromWorkout
                        ? Icons.arrow_back_rounded
                        : Icons.play_arrow_rounded,
                    height: 56,
                  ),
                  const SizedBox(height: 8),
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
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'DETALLE DEL EJERCICIO',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Text(
              '${currentIndex + 1} / ${exercises.length}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Área de vídeo ────────────────────────────────────────────────────────

  Widget _buildVideoArea(bool isWide) {
    return VideoAreaWidget(videoUrl: exercise.videoUrl, isWide: isWide);
  }

  // ── Título ────────────────────────────────────────────────────────────────

  Widget _buildTitle(bool isWide) {
    return Column(
      children: [
        Text(
          exercise.name.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 32 : 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1.1,
          ),
        ),
        if (exercise.rhythm != null) ...[
          const SizedBox(height: 8),
          Text(
            'RITMO ${exercise.rhythm!.toUpperCase()}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: Colors.orangeAccent,
            label: 'DURACIÓN',
            value: _formatDuration(exercise.effectiveDurationSeconds),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.repeat_rounded,
            iconColor: AppColors.primary,
            label: 'SERIES',
            value: exercise.series != null ? '${exercise.series}' : '—',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.format_list_numbered_rounded,
            iconColor: AppColors.secondary,
            label: 'REPS',
            value: exercise.reps != null ? '${exercise.reps}' : '—',
          ),
        ),
      ],
    );
  }

  // ── Info cards ────────────────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.description_rounded,
            color: AppColors.primary, size: 22),
      ),
      title: 'DESCRIPCIÓN',
      content: const Text(
        'Realiza el movimiento de forma lenta y controlada. Mantén la postura correcta durante toda la ejecución para maximizar los beneficios y evitar lesiones.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.tips_and_updates_rounded,
            color: AppColors.secondary, size: 22),
      ),
      title: 'CONSEJOS',
      content: const Text(
        'Si notas dolor agudo, detente de inmediato. Respira de forma continua durante el ejercicio y consulta con tu fisioterapeuta ante cualquier duda.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }
}

// ── Widgets locales ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget content;

  const _InfoCard({
    required this.leading,
    required this.title,
    required this.content,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
