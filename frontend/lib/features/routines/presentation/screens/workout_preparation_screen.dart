import 'dart:async'; // Timer — necesario para la cuenta atrás
import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_widget.dart';
import '../../../exercises/models/exercise_detail_model.dart';
import '../../services/workout_session_service.dart';
import '../../../../shared/widgets/countdown_ring_widget.dart';   // Anillo de cuenta atrás
import '../../../../shared/widgets/workout_control_button_widget.dart'; // WorkoutControlButton (botón de skip)
import 'workout_exercise_screen.dart'; // Destino cuando termina la preparación

/// Pantalla de preparación antes de iniciar un ejercicio.
/// Muestra el nombre del próximo ejercicio y una cuenta atrás de 8 segundos (configurable).
/// Cuando la cuenta llega a cero (o el usuario pulsa skip) navega al ejercicio.
class WorkoutPreparationScreen extends StatefulWidget {
  /// Lista completa de ejercicios de la sesión — se pasa íntegra al siguiente paso.
  final List<ExerciseModel> exercises;

  /// Índice del ejercicio para el que el paciente se prepara (base 0).
  final int currentIndex;

  /// Segundos de cuenta atrás antes de empezar (8 por defecto).
  final int preparationSeconds;

  const WorkoutPreparationScreen({
    super.key,
    required this.exercises,
    required this.currentIndex,
    this.preparationSeconds = 8, // 8 segundos es el tiempo estándar de preparación
  });

  @override
  State<WorkoutPreparationScreen> createState() =>
      _WorkoutPreparationScreenState();
}

class _WorkoutPreparationScreenState extends State<WorkoutPreparationScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  late int _secondsRemaining; // Segundos que quedan en la cuenta atrás
  Timer? _timer;              // Timer periódico — se cancela en dispose para evitar memory leaks

  final WorkoutSessionService _sessionService = WorkoutSessionService();

  /// El ejercicio para el que el usuario se está preparando.
  ExerciseModel get _exercise => widget.exercises[widget.currentIndex];

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.preparationSeconds; // Inicializa con el tiempo configurado
    _startCountdown(); // Arranca la cuenta atrás inmediatamente
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el timer al destruir el widget para evitar memory leaks
    super.dispose();
  }

  // ── Lógica del temporizador ───────────────────────────────────────────────

  /// Inicia el Timer periódico de 1 segundo.
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); // El widget se desmontó → cancela para no llamar a setState
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();          // Para el timer
        _onCountdownComplete();  // Navega al ejercicio
      } else {
        setState(() => _secondsRemaining--); // Decrementa y reconstruye el anillo
      }
    });
  }

  /// Llamado cuando la cuenta atrás llega a cero (o el usuario omite la preparación).
  void _onCountdownComplete() {
    _sessionService.onPreparationComplete(_exercise.id); // Notifica al servicio
    if (!mounted) return; // Verifica que el widget sigue montado antes de navegar
    // `pushReplacement` sustituye esta pantalla por la del ejercicio
    // (no se puede volver a la preparación con el botón de atrás)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutExerciseScreen(
          exercises: widget.exercises,  // Pasa la lista completa al ejercicio
          currentIndex: widget.currentIndex, // Mismo índice
        ),
      ),
    );
  }

  /// Salta la cuenta atrás y pasa directamente al ejercicio.
  void _skipPreparation() {
    _timer?.cancel(); // Para el timer antes de navegar
    _onCountdownComplete();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Fracción 0.0–1.0 para el anillo: empieza lleno (1.0) y se vacía hasta 0.0
    final progress = _secondsRemaining / widget.preparationSeconds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(progress)), // Nombre + anillo de cuenta atrás
            _buildSkipButton(),                        // Botón para saltar la preparación
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) {
            _timer?.cancel(); // Para el timer antes de abandonar la pantalla
            Navigator.of(context).popUntil((route) => route.isFirst); // Vuelve al inicio
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
        tooltip: LocaleManager.strings.prepExit, // "Salir de la sesión"
        onPressed: () {
          _timer?.cancel(); // Cancela el timer antes de volver
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        LocaleManager.strings.prepAppBar, // "PREPARACIÓN"
        style: const TextStyle(
          color: AppColors.secondary, // Verde — estado de preparación activa
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Contenido central ─────────────────────────────────────────────────────

  /// Nombre del próximo ejercicio + anillo de cuenta atrás con segundos.
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
            Text(
              LocaleManager.strings.restNextExercise, // "PRÓXIMO EJERCICIO"
              style: const TextStyle(
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
                _exercise.name.toUpperCase(), // Nombre en mayúsculas
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
            // Anillo con el número de segundos restantes en el centro
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
                        '$_secondsRemaining', // Número grande en el centro del anillo
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: countdownFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LocaleManager.strings.prepGetReady, // "PREPÁRATE"
                        style: const TextStyle(
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

  /// Botón de skip — pasa directamente al ejercicio sin esperar la cuenta atrás.
  Widget _buildSkipButton() {
    return Center(
      child: WorkoutControlButton(
        icon: Icons.skip_next_rounded,
        color: AppColors.textSecondary, // Gris — acción secundaria, no la principal
        onTap: _skipPreparation,
        tooltip: LocaleManager.strings.prepSkip, // "Saltar preparación"
      ),
    );
  }
}
