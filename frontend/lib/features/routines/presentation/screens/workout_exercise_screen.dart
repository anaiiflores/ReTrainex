import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/video_area_widget.dart';
import '../../../../shared/widgets/workout_controls_widget.dart';
import '../../models/routine_detail_model.dart';
import '../../services/workout_session_service.dart';
import '../../widgets/countdown_ring_widget.dart';
import '../../widgets/skip_reason_sheet.dart';
import 'clinical_evaluation_screen.dart';
import 'session_paused.dart';
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
  bool _isStopped =
      false; // evita que el timer complete la navegación si el usuario paró
  Timer? _timer;

  final WorkoutSessionService _sessionService = WorkoutSessionService();

  ExerciseModel get _exercise => widget.exercises[widget.currentIndex];
  int get _totalExercises => widget.exercises.length;
  bool get _isTimeless => _totalSeconds == 0;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _exercise.effectiveDurationSeconds;
    _secondsRemaining = _totalSeconds;
    if (!_isTimeless) _startTimer();
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
    if (_isTimeless) {
      _onExerciseComplete();
      return;
    }
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

  Future<void> _openDetails() async {
    final wasRunning = !_isTimeless && !_isPaused;
    if (wasRunning) {
      _timer?.cancel();
      setState(() => _isPaused = true);
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionPausedScreen(
          exercise: _exercise,
          exercises: widget.exercises,
          currentIndex: widget.currentIndex,
        ),
      ),
    );
    if (!mounted) return;
    if (wasRunning) {
      setState(() => _isPaused = false);
      _startTimer();
    }
  }

  Future<void> _onSkipPressed() async {
    _timer?.cancel();
    setState(() => _isPaused = true);

    final reason = await showModalBottomSheet<SkipReason>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SkipReasonSheet(),
    );

    if (!mounted) return;

    if (reason == null) {
      setState(() => _isPaused = false);
      if (!_isTimeless) _startTimer();
      return;
    }

    if (reason == SkipReason.pain) {
      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              ClinicalEvaluationScreen(exerciseName: _exercise.name),
        ),
      );
      if (!mounted) return;
      if (submitted == true) {
        _skipExercise();
      } else {
        setState(() => _isPaused = false);
        if (!_isTimeless) _startTimer();
      }
      return;
    }

    _skipExercise();
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
                  WorkoutControlsWidget(
                    isPaused: _isPaused,
                    nextMode: _isTimeless,
                    onPause: _togglePause,
                    onStop: _stopSession,
                    onSkip: () {
                      _onSkipPressed();
                    },
                  ),
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
    return VideoAreaWidget(videoUrl: _exercise.videoUrl, isWide: isWide);
  }

  Widget _buildVideoTags() {
    return Row(
      children: [
        _Tag(label: 'VIDEO HD', color: const Color.fromARGB(139, 149, 88, 203)),
        const SizedBox(width: 8),
        _Tag(label: _exercise.angle ?? 'FRONTAL', color: AppColors.secondary),
        const SizedBox(width: 8),
        _Tag(label: 'DETALLES', color: AppColors.primary, onTap: _openDetails),
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
          CountdownRingWidget(
              progress: _isTimeless ? 1.0 : progress, size: ringSize),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isTimeless ? '∞' : '$_secondsRemaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _isTimeless ? countFontSize * 1.1 : countFontSize,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isTimeless ? 'SIN LÍMITE' : 'SEGUNDOS',
                style: const TextStyle(
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
    final progressLabel = '${widget.currentIndex + 1} / $_totalExercises';

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
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _Tag({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final container = Container(
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
    if (onTap == null) return container;
    return GestureDetector(onTap: onTap, child: container);
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
