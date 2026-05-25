import 'dart:async'; // Timer
import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_widget.dart';
import '../../../../shared/widgets/video_area_widget.dart';         // Área de vídeo (o placeholder)
import '../../../../shared/widgets/workout_controls_widget.dart';  // Botones pausa/stop/skip
import '../../../exercises/models/exercise_detail_model.dart';
import '../../services/workout_session_service.dart';
import '../../../../shared/widgets/countdown_ring_widget.dart';    // Anillo circular
import '../../widgets/skip_reason_sheet_widget.dart';              // Bottom sheet de motivo de skip
import 'clinical_evaluation_screen.dart'; // Solo si el motivo de skip es "dolor"
import 'session_paused.dart';             // Pantalla de detalles del ejercicio (pausa)
import 'workout_complete_screen.dart';    // Destino al completar el último ejercicio
import 'workout_rest_screen.dart';        // Descanso entre ejercicios

/// Pantalla de ejecución de un ejercicio.
/// Muestra el vídeo (o placeholder), el temporizador circular y los controles.
/// Gestiona: pausa, stop, skip, modo sin tiempo (timeless) y transición al siguiente ejercicio.
class WorkoutExerciseScreen extends StatefulWidget {
  /// Lista completa de ejercicios de la sesión — necesaria para saber cuándo hay siguiente.
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
  late int _secondsRemaining; // Segundos restantes del ejercicio
  late int _totalSeconds;     // Duración total del ejercicio (0 si es timeless)
  bool _isPaused = false;     // true → el timer está en pausa
  /// Evita que el timer complete la navegación si el usuario ya pulsó stop.
  bool _isStopped = false;
  Timer? _timer;

  final WorkoutSessionService _sessionService = WorkoutSessionService();

  ExerciseModel get _exercise => widget.exercises[widget.currentIndex];
  int get _totalExercises => widget.exercises.length; // Total de ejercicios en la sesión
  /// true si el ejercicio no tiene duración (effectiveDurationSeconds == 0).
  /// En modo timeless el botón principal es "→ SIGUIENTE" en lugar de "⏸ PAUSA".
  bool get _isTimeless => _totalSeconds == 0;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _exercise.effectiveDurationSeconds; // Duración calculada del modelo
    _secondsRemaining = _totalSeconds;
    if (!_isTimeless) _startTimer(); // Solo arranca el timer si hay duración
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela siempre para evitar memory leaks
    super.dispose();
  }

  // ── Lógica del temporizador ───────────────────────────────────────────────

  /// Arranca el timer periódico de 1 segundo.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _onExerciseComplete(); // Tiempo agotado → completar ejercicio
      } else {
        setState(() => _secondsRemaining--); // Decrementa y repinta el anillo
      }
    });
  }

  /// Maneja el botón principal (pausa/play o "siguiente" en modo timeless).
  void _togglePause() {
    if (_isTimeless) {
      // En modo sin tiempo, el botón principal es "SIGUIENTE" → completa y avanza
      _onExerciseComplete();
      return;
    }
    // En modo con tiempo → abre la pantalla de detalles (que también pausa el timer)
    _openDetails();
  }

  /// Llamado cuando el ejercicio se completa (timer agotado, botón siguiente, o skip).
  void _onExerciseComplete() {
    if (_isStopped) return; // Si el usuario ya paró, ignorar completions tardías
    _sessionService.completeExercise(_exercise.id); // Notifica al backend
    if (!mounted) return;

    final nextIndex = widget.currentIndex + 1;
    final hasNext = nextIndex < widget.exercises.length; // ¿Hay más ejercicios?

    if (hasNext) {
      // Hay más ejercicios → pantalla de descanso antes del siguiente
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WorkoutRestScreen(
            exercises: widget.exercises,
            completedIndex: widget.currentIndex, // El ejercicio que acaba de completarse
          ),
        ),
      );
    } else {
      // Era el último ejercicio → cierra la sesión y muestra la pantalla de éxito
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

  /// Para la sesión completamente y vuelve al inicio del flujo de navegación.
  void _stopSession() {
    _isStopped = true; // Marca para ignorar cualquier _onExerciseComplete que llegue tarde
    _timer?.cancel();
    _sessionService.completeSession(); // Cierra la sesión aunque no haya terminado
    Navigator.of(context).popUntil((route) => route.isFirst); // Vuelve a WelcomeIniScreen
  }

  /// Omite el ejercicio actual (lo marca como completo sin esperar el tiempo).
  void _skipExercise() {
    _timer?.cancel();
    _onExerciseComplete(); // Mismo flujo que completar → descanso o pantalla final
  }

  /// Abre SessionPausedScreen con los detalles del ejercicio y pausa el timer.
  Future<void> _openDetails() async {
    final wasRunning = !_isTimeless && !_isPaused; // ¿Estaba el timer corriendo?
    if (wasRunning) {
      _timer?.cancel();
      setState(() => _isPaused = true); // Muestra el icono de "play" en el botón
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionPausedScreen(
          exercise: _exercise,
          exercises: widget.exercises,
          currentIndex: widget.currentIndex,
          fromWorkout: true, // Indica que viene de una sesión activa (muestra controles de vuelta)
        ),
      ),
    );
    if (!mounted) return;
    if (wasRunning) {
      setState(() => _isPaused = false); // Restaura el icono de "pausa"
      _startTimer();                     // Reanuda el timer desde donde se quedó
    }
  }

  /// Muestra el bottom sheet de motivo de skip y gestiona el flujo según la razón.
  Future<void> _onSkipPressed() async {
    _timer?.cancel();
    setState(() => _isPaused = true);

    // Espera la selección del usuario en el bottom sheet
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
      // Usuario cerró el sheet sin seleccionar → reanuda la sesión
      setState(() => _isPaused = false);
      if (!_isTimeless) _startTimer();
      return;
    }

    if (reason == SkipReason.pain) {
      // Si el motivo es dolor → navega al formulario de evaluación clínica
      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              ClinicalEvaluationScreen(exerciseName: _exercise.name),
        ),
      );
      if (!mounted) return;
      if (submitted == true) {
        _skipExercise(); // Formulario enviado → omite el ejercicio
      } else {
        // Usuario canceló el formulario → reanuda la sesión
        setState(() => _isPaused = false);
        if (!_isTimeless) _startTimer();
      }
      return;
    }

    // Motivo diferente al dolor → omite directamente sin formulario
    _skipExercise();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Fracción para el anillo: 1.0 cuando empieza, 0.0 cuando termina
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
                  _buildExerciseHeader(), // Etiqueta "EJERCICIO ACTUAL" + nombre
                  const SizedBox(height: 16),
                  _buildVideoArea(isWide), // Vídeo o placeholder
                  const SizedBox(height: 12),
                  _buildVideoTags(),       // Tags: HD · FRONTAL · DETALLES
                  const SizedBox(height: 28),
                  _buildTimer(progress, isWide), // Anillo + segundos/∞
                  const SizedBox(height: 24),
                  _buildStatsRow(),         // Ritmo + progreso (X/N)
                  const SizedBox(height: 28),
                  WorkoutControlsWidget(
                    isPaused: _isPaused,
                    nextMode: _isTimeless,    // Modo sin tiempo → botón "→"
                    onPause: _togglePause,    // Pausa o avanza según el modo
                    onStop: _stopSession,
                    onSkip: () { _onSkipPressed(); },
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
          if (i != 1) _stopSession(); // Cambiar de tab = detener la sesión
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
          _timer?.cancel(); // Cancela el timer antes de volver
          Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
      title: Text(
        LocaleManager.strings.appName, // "ReTrainex"
        style: const TextStyle(
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
        Text(
          LocaleManager.strings.exerciseCurrentLabel, // "EJERCICIO ACTUAL"
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _exercise.name.toUpperCase(), // Nombre del ejercicio en mayúsculas
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

  /// Muestra el vídeo del ejercicio si está disponible; si no, un placeholder.
  Widget _buildVideoArea(bool isWide) {
    return VideoAreaWidget(videoUrl: _exercise.videoUrl, isWide: isWide);
  }

  /// Fila de tags bajo el vídeo: resolución, ángulo de cámara y acceso a detalles.
  Widget _buildVideoTags() {
    return Row(
      children: [
        _Tag(label: LocaleManager.strings.exerciseVideoHd, color: const Color.fromARGB(139, 149, 88, 203)), // "HD"
        const SizedBox(width: 8),
        // Ángulo del vídeo (del modelo) o "FRONTAL" por defecto
        _Tag(label: _exercise.angle ?? LocaleManager.strings.exerciseFrontal, color: AppColors.secondary),
        const SizedBox(width: 8),
        // Tag interactivo que abre la pantalla de detalles/pausa
        _Tag(label: LocaleManager.strings.exerciseDetails, color: AppColors.primary, onTap: _openDetails),
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
          // Anillo lleno (1.0) en modo timeless; animado en modo con tiempo
          CountdownRingWidget(
              progress: _isTimeless ? 1.0 : progress, size: ringSize),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isTimeless ? '∞' : '$_secondsRemaining', // ∞ en modo sin tiempo
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _isTimeless ? countFontSize * 1.1 : countFontSize, // ∞ ligeramente más grande
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isTimeless
                    ? LocaleManager.strings.exerciseNoLimit // "SIN LÍMITE"
                    : LocaleManager.strings.restSeconds,    // "SEGUNDOS"
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

  /// Dos tarjetas: ritmo de ejecución y progreso en la sesión (ej. "2 / 4").
  Widget _buildStatsRow() {
    final rhythm = _exercise.rhythm ?? 'NORMAL'; // Ritmo del modelo o "NORMAL" por defecto
    final progressLabel = '${widget.currentIndex + 1} / $_totalExercises'; // "2 / 4"

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: LocaleManager.strings.exerciseRhythmLabel, // "RITMO"
            value: rhythm,
            valueColor: AppColors.secondary, // Verde para el ritmo
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: LocaleManager.strings.exerciseProgressLabel, // "PROGRESO"
            value: progressLabel,
            valueColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

/// Tag pequeño de texto con fondo y borde del mismo color (semitransparentes).
/// Opcional: puede tener un callback de tap (ej. el tag "DETALLES").
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap; // null → solo visual, no interactivo

  const _Tag({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),       // Fondo muy transparente del color del tag
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)), // Borde semitransparente
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
    // Si tiene callback → envuelve en GestureDetector; si no → devuelve el container directamente
    if (onTap == null) return container;
    return GestureDetector(onTap: onTap, child: container);
  }
}

/// Tarjeta de estadística con etiqueta superior y valor grande.
/// Se usa en pares: ritmo y progreso.
class _StatCard extends StatelessWidget {
  final String label;      // Etiqueta en gris arriba ("RITMO", "PROGRESO")
  final String value;      // Valor grande abajo ("NORMAL", "2 / 4")
  final Color valueColor;  // Color del valor (verde, blanco…)

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
