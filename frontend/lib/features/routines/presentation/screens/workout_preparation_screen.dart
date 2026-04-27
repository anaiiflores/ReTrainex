import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../models/routine_detail_model.dart';
import '../../services/workout_session_service.dart';
import '../../widgets/countdown_ring_widget.dart';
import 'workout_exercise_screen.dart';

class WorkoutPreparationScreen extends StatefulWidget {
  /// Lista completa de ejercicios de la sesión.
  final List<ExerciseModel> exercises;

  /// Índice del ejercicio para el que el paciente se prepara (base 0).
  final int currentIndex;

  /// Segundos de cuenta atrás antes de empezar (8 por defecto).
  final int preparationSeconds;

  const WorkoutPreparationScreen({
    super.key,
    required this.exercises,
    required this.currentIndex,
    this.preparationSeconds = 8,
  });

  @override
  State<WorkoutPreparationScreen> createState() =>
      _WorkoutPreparationScreenState();
}

class _WorkoutPreparationScreenState extends State<WorkoutPreparationScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  late int _secondsRemaining;
  Timer? _timer;

  final WorkoutSessionService _sessionService = WorkoutSessionService();

  ExerciseModel get _exercise => widget.exercises[widget.currentIndex];

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.preparationSeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Lógica del temporizador ───────────────────────────────────────────────

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _onCountdownComplete();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _onCountdownComplete() {
    _sessionService.onPreparationComplete(_exercise.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutExerciseScreen(
          exercises: widget.exercises,
          currentIndex: widget.currentIndex,
        ),
      ),
    );
  }

  void _skipPreparation() {
    _timer?.cancel();
    _onCountdownComplete();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final progress = _secondsRemaining / widget.preparationSeconds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(progress)),
            _buildSkipButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) {
            _timer?.cancel();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
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
        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
        tooltip: 'Salir',
        onPressed: () {
          _timer?.cancel();
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        'WORKOUT IN PROGRESS',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Contenido central ─────────────────────────────────────────────────────

  Widget _buildContent(double progress) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final double circleSize = isWide ? 260 : 200;
    final double countdownFontSize = isWide ? 84 : 64;
    final double titleFontSize = isWide ? 40 : 32;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWide ? 520.0 : double.infinity),
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'PRÓXIMO EJERCICIO',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _exercise.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: isWide ? 64 : 48),
        SizedBox(
          width: circleSize,
          height: circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CountdownRingWidget(progress: progress, size: circleSize),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_secondsRemaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: countdownFontSize,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PREPÁRATE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
        ),
      ),
    );
  }

  // ── Botón omitir ──────────────────────────────────────────────────────────

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: _skipPreparation,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            'OMITIR PREPARACIÓN',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
