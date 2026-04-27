import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../models/routine_detail_model.dart';
import '../../widgets/countdown_ring_widget.dart';
import 'workout_preparation_screen.dart';

class WorkoutRestScreen extends StatefulWidget {
  /// Lista completa de ejercicios de la sesión.
  final List<ExerciseModel> exercises;

  /// Índice del ejercicio que acaba de completarse (base 0).
  final int completedIndex;

  /// Segundos de descanso por defecto cuando el backend no especifica uno.
  final int defaultRestSeconds;

  const WorkoutRestScreen({
    super.key,
    required this.exercises,
    required this.completedIndex,
    this.defaultRestSeconds = 15,
  });

  @override
  State<WorkoutRestScreen> createState() => _WorkoutRestScreenState();
}

class _WorkoutRestScreenState extends State<WorkoutRestScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  late int _secondsRemaining;
  late int _totalSeconds;
  Timer? _timer;

  int get _nextIndex => widget.completedIndex + 1;
  ExerciseModel get _nextExercise => widget.exercises[_nextIndex];

  @override
  void initState() {
    super.initState();
    final completedExercise = widget.exercises[widget.completedIndex];
    _totalSeconds =
        completedExercise.restAfterSeconds ?? widget.defaultRestSeconds;
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
        _goToNextExercise();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _addTime() {
    setState(() => _secondsRemaining += 20);
  }

  void _skipRest() {
    _timer?.cancel();
    _goToNextExercise();
  }

  void _stopSession() {
    _timer?.cancel();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goToNextExercise() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutPreparationScreen(
          exercises: widget.exercises,
          currentIndex: _nextIndex,
        ),
      ),
    );
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
            horizontal: isWide ? 80 : 24,
            vertical: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 520.0 : double.infinity),
              child: Column(
                children: [
                  _buildTitle(isWide),
                  SizedBox(height: isWide ? 40 : 28),
                  _buildRing(progress, isWide),
                  const SizedBox(height: 20),
                  _buildAddTimeButton(),
                  const SizedBox(height: 28),
                  _buildNextExerciseCard(),
                  const SizedBox(height: 28),
                  _buildSkipButton(),
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
        icon: const Icon(Icons.flag_rounded,
            color: AppColors.secondary, size: 24),
        tooltip: 'Detener sesión',
        onPressed: _stopSession,
      ),
      centerTitle: true,
      title: const Text(
        'RECOVERY PHASE',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surface,
            child: const Icon(Icons.person_rounded,
                color: AppColors.textSecondary, size: 18),
          ),
        ),
      ],
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────

  Widget _buildTitle(bool isWide) {
    return Column(
      children: [
        const Text(
          'RETRAINEX SESSION',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'TIEMPO DE\nDESCANSO',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 42 : 34,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Anillo de cuenta atrás ────────────────────────────────────────────────

  Widget _buildRing(double progress, bool isWide) {
    final double ringSize = isWide ? 220 : 180;
    final double countFontSize = isWide ? 72 : 58;

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CountdownRingWidget(
            progress: progress,
            size: ringSize,
            color: AppColors.secondary,
          ),
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

  // ── Botón +20s ────────────────────────────────────────────────────────────

  Widget _buildAddTimeButton() {
    return OutlinedButton.icon(
      onPressed: _addTime,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text(
        '+20 SEGUNDOS',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Tarjeta siguiente ejercicio ───────────────────────────────────────────

  Widget _buildNextExerciseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRÓXIMO EJERCICIO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _nextExercise.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                if (_nextExercise.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _nextExercise.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  // ── Botón omitir descanso ─────────────────────────────────────────────────

  Widget _buildSkipButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _skipRest,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'OMITIR DESCANSO',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
