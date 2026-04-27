import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../models/routine_detail_model.dart';
import '../../services/workout_session_service.dart';
import '../../widgets/countdown_ring_widget.dart';
import 'workout_complete_screen.dart';
import 'workout_rest_screen.dart';

class WorkoutExerciseScreen extends StatefulWidget {
  /// Lista completa de ejercicios de la sesión.
  final List<ExerciseModel> exercises;

  /// Índice del ejercicio activo (base 0).
  final int currentIndex;

  const WorkoutExerciseScreen({
    super.key,
    required this.exercises,
    required this.currentIndex,
  });

  @override
  State<WorkoutExerciseScreen> createState() => _WorkoutExerciseScreenState();
}

class _WorkoutExerciseScreenState extends State<WorkoutExerciseScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  late int _secondsRemaining;
  late int _totalSeconds;
  bool _isPaused = false;
  bool _isStopped = false; // evita que el timer complete la navegación si el usuario paró
  Timer? _timer;

  final WorkoutSessionService _sessionService = WorkoutSessionService();

  ExerciseModel get _exercise => widget.exercises[widget.currentIndex];
  int get _totalExercises => widget.exercises.length;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _exercise.effectiveDurationSeconds;
    _secondsRemaining = _totalSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Lógica del temporizador ───────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _onExerciseComplete();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  void _onExerciseComplete() {
    if (_isStopped) return;
    _sessionService.completeExercise(_exercise.id);
    if (!mounted) return;

    final nextIndex = widget.currentIndex + 1;
    final hasNext = nextIndex < widget.exercises.length;

    if (hasNext) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WorkoutRestScreen(
            exercises: widget.exercises,
            completedIndex: widget.currentIndex,
          ),
        ),
      );
    } else {
      _sessionService.completeSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WorkoutCompleteScreen(
            exerciseCount: widget.exercises.length,
          ),
        ),
      );
    }
  }

  void _stopSession() {
    _isStopped = true;
    _timer?.cancel();
    _sessionService.completeSession();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _skipExercise() {
    _timer?.cancel();
    _onExerciseComplete();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalSeconds > 0 ? _secondsRemaining / _totalSeconds : 0.0;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 20,
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 560.0 : double.infinity),
              child: Column(
                children: [
                  _buildExerciseHeader(),
                  const SizedBox(height: 16),
                  _buildVideoArea(isWide),
                  const SizedBox(height: 12),
                  _buildVideoTags(),
                  const SizedBox(height: 28),
                  _buildTimer(progress, isWide),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 28),
                  _buildControlButtons(),
                  const SizedBox(height: 12),
                  _buildSkipLink(),
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
          if (i != 1) _stopSession();
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () {
          _timer?.cancel();
          Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
      title: const Text(
        'RETRAINEX',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // ── Cabecera del ejercicio ────────────────────────────────────────────────

  Widget _buildExerciseHeader() {
    return Column(
      children: [
        const Text(
          'EJERCICIO ACTUAL',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _exercise.name.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Área de vídeo ─────────────────────────────────────────────────────────

  Widget _buildVideoArea(bool isWide) {
    final double height = isWide ? 240 : 180;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: _exercise.videoUrl != null
          ? const Center(
              child: Icon(Icons.play_circle_outline_rounded,
                  color: AppColors.primary, size: 64),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    size: 48),
                const SizedBox(height: 10),
                const Text(
                  'VÍDEO PRÓXIMAMENTE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVideoTags() {
    return Row(
      children: [
        _Tag(label: 'VIDEO HD', color: AppColors.primary),
        const SizedBox(width: 8),
        _Tag(
          label: _exercise.angle ?? 'FRONTAL',
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  // ── Temporizador circular ─────────────────────────────────────────────────

  Widget _buildTimer(double progress, bool isWide) {
    final double ringSize = isWide ? 220 : 180;
    final double countFontSize = isWide ? 72 : 58;

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CountdownRingWidget(progress: progress, size: ringSize),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_secondsRemaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: countFontSize,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'SEGUNDOS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tarjetas de stats ─────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final rhythm = _exercise.rhythm ?? 'NORMAL';
    final progressLabel =
        '${widget.currentIndex + 1} / $_totalExercises';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'RITMO',
            value: rhythm,
            valueColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'PROGRESO',
            value: progressLabel,
            valueColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Botones de control ────────────────────────────────────────────────────

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          color: AppColors.primary,
          onTap: _togglePause,
          tooltip: _isPaused ? 'Continuar' : 'Pausar',
        ),
        const SizedBox(width: 28),
        _ControlButton(
          icon: Icons.stop_rounded,
          color: Colors.redAccent,
          onTap: _stopSession,
          tooltip: 'Detener sesión',
        ),
      ],
    );
  }

  Widget _buildSkipLink() {
    return TextButton.icon(
      onPressed: _skipExercise,
      icon: const Icon(Icons.skip_next_rounded,
          color: AppColors.textSecondary, size: 18),
      label: const Text(
        'OMITIR EJERCICIO',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
