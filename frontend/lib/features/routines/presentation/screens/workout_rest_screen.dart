import 'dart:async'; // Timer — cuenta atrás de descanso
import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';      // Textos localizados
import '../../../../core/theme/app_colors.dart';            // Paleta de colores
import '../../../../shared/widgets/app_bottom_nav_widget.dart';   // Barra de navegación inferior
import '../../../../shared/widgets/workout_controls_widget.dart'; // Botones +20s y skip
import '../../../exercises/models/exercise_detail_model.dart';    // ExerciseModel
import '../../../../shared/widgets/countdown_ring_widget.dart';   // Anillo de cuenta atrás verde
import 'workout_preparation_screen.dart'; // Destino cuando termina el descanso

/// Pantalla de descanso entre ejercicios.
/// Muestra una cuenta atrás verde, el nombre del siguiente ejercicio y dos controles:
///  - +20s: añade 20 segundos al descanso actual.
///  - Skip: salta el descanso e inicia la preparación del siguiente ejercicio.
/// Cuando la cuenta llega a cero navega automáticamente a WorkoutPreparationScreen.
class WorkoutRestScreen extends StatefulWidget {
  /// Lista completa de ejercicios de la sesión.
  final List<ExerciseModel> exercises;

  /// Índice del ejercicio que acaba de completarse (base 0).
  /// El siguiente ejercicio está en `completedIndex + 1`.
  final int completedIndex;

  /// Segundos de descanso por defecto cuando el backend no especifica uno.
  final int defaultRestSeconds;

  const WorkoutRestScreen({
    super.key,
    required this.exercises,
    required this.completedIndex,
    this.defaultRestSeconds = 15, // 15 s es el descanso estándar si el ejercicio no define uno
  });

  @override
  State<WorkoutRestScreen> createState() => _WorkoutRestScreenState();
}

class _WorkoutRestScreenState extends State<WorkoutRestScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  late int _secondsRemaining; // Segundos que quedan de descanso (decrementan con el timer)
  late int _totalSeconds;     // Duración total del descanso — se usa para calcular el progreso del anillo
  Timer? _timer;              // Timer periódico de 1 s — se cancela en dispose para evitar leaks

  /// Índice del próximo ejercicio (el que se hará tras el descanso).
  int get _nextIndex => widget.completedIndex + 1;

  /// El ejercicio que viene a continuación — se muestra en la tarjeta inferior.
  ExerciseModel get _nextExercise => widget.exercises[_nextIndex];

  @override
  void initState() {
    super.initState();
    // Usa el tiempo de descanso definido en el ejercicio completado si existe;
    // si no, usa el valor por defecto del widget (`defaultRestSeconds`).
    final completedExercise = widget.exercises[widget.completedIndex];
    _totalSeconds =
        completedExercise.restAfterSeconds ?? widget.defaultRestSeconds;
    _secondsRemaining = _totalSeconds; // Inicializa la cuenta atrás con el total
    _startTimer(); // Arranca inmediatamente
  }

  @override
  void dispose() {
    _timer?.cancel(); // Evita callbacks después de desmontar el widget
    super.dispose();
  }

  // ── Lógica del temporizador ───────────────────────────────────────────────

  /// Inicia el Timer periódico de 1 segundo.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); // El widget fue desmontado — para el timer
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();       // Cuenta terminada — para el timer
        _goToNextExercise();  // Navega automáticamente al siguiente ejercicio
      } else {
        setState(() => _secondsRemaining--); // Decrementa y reconstruye el anillo
      }
    });
  }

  /// Añade 20 segundos al descanso actual (por si el paciente necesita más tiempo).
  /// No cambia `_totalSeconds` porque el anillo ya no tiene valor semántico exacto
  /// después de añadir tiempo — solo se muestra el número grande.
  void _addTime() {
    setState(() => _secondsRemaining += 20); // Incrementa el contador visible
  }

  /// Salta el descanso y va directamente al siguiente ejercicio.
  void _skipRest() {
    _timer?.cancel(); // Cancela el timer antes de navegar
    _goToNextExercise();
  }

  /// Termina la sesión y vuelve a la pantalla de inicio.
  void _stopSession() {
    _timer?.cancel(); // Cancela el timer antes de salir
    Navigator.of(context).popUntil((route) => route.isFirst); // Vuelve a la raíz
  }

  /// Navega a WorkoutPreparationScreen para el siguiente ejercicio.
  /// `pushReplacement` sustituye esta pantalla — no se puede volver al descanso.
  void _goToNextExercise() {
    if (!mounted) return; // Verifica que el widget sigue montado antes de navegar
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutPreparationScreen(
          exercises: widget.exercises, // Pasa la lista completa al flujo
          currentIndex: _nextIndex,    // Prepara el ejercicio siguiente
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Fracción 0.0–1.0 para el anillo: empieza lleno (1.0) y se vacía hasta 0.0
    // Protege contra _totalSeconds == 0 (nunca debería ocurrir, pero evita NaN)
    final progress =
        _totalSeconds > 0 ? _secondsRemaining / _totalSeconds : 0.0;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context), // AppBar con bandera de fin de sesión
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
                  _buildTitle(isWide),               // "DESCANSO" y subtítulo
                  SizedBox(height: isWide ? 40 : 28),
                  _buildRing(progress, isWide),      // Anillo verde con segundos restantes
                  const SizedBox(height: 28),
                  _buildNextExerciseCard(),           // Tarjeta del siguiente ejercicio
                  const SizedBox(height: 28),
                  _buildControls(),                   // Botones +20s y skip
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      // Si el usuario pulsa otro tab de la barra inferior, termina la sesión
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) _stopSession(); // Solo el tab de rutinas mantiene la sesión
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      // Botón de bandera en el leading (izquierda) para terminar la sesión
      leading: IconButton(
        icon: const Icon(Icons.flag_rounded,
            color: AppColors.secondary, size: 24), // Verde — fin de etapa
        tooltip: LocaleManager.strings.restStopSession, // "Terminar sesión"
        onPressed: _stopSession,
      ),
      centerTitle: true,
      title: Text(
        LocaleManager.strings.restAppBar, // "DESCANSO"
        style: const TextStyle(
          color: AppColors.secondary, // Verde — estado de descanso activo
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      // Avatar del usuario en la esquina derecha — elemento visual sin acción
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surface, // Fondo oscuro del avatar
            child: const Icon(Icons.person_rounded,
                color: AppColors.textSecondary, size: 18),
          ),
        ),
      ],
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────

  /// Subtítulo etiqueta + título grande "DESCANSA".
  Widget _buildTitle(bool isWide) {
    return Column(
      children: [
        Text(
          LocaleManager.strings.restSessionLabel, // "SESIÓN EN CURSO"
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleManager.strings.restTitle, // "DESCANSA"
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 42 : 34, // Título grande — mensaje motivacional
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Anillo de cuenta atrás ────────────────────────────────────────────────

  /// Anillo verde con los segundos restantes centrados.
  /// El color verde diferencia visualmente el estado de descanso del de ejercicio (azul).
  Widget _buildRing(double progress, bool isWide) {
    final double ringSize = isWide ? 220 : 180;   // Tamaño del anillo en puntos lógicos
    final double countFontSize = isWide ? 72 : 58; // Fuente del número central

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center, // Centra el texto sobre el anillo
        children: [
          // Anillo SVG animado — color verde para diferenciar de la fase de ejercicio
          CountdownRingWidget(
            progress: progress,
            size: ringSize,
            color: AppColors.secondary, // Verde (distinto del azul del ejercicio)
          ),
          // Contenido central: número grande + etiqueta "seg"
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_secondsRemaining', // Segundos restantes en tiempo real
                style: TextStyle(
                  color: Colors.white,
                  fontSize: countFontSize,
                  fontWeight: FontWeight.w900,
                  height: 1, // Sin espacio extra para que el número quede centrado
                ),
              ),
              const SizedBox(height: 4),
              Text(
                LocaleManager.strings.restSeconds, // "seg" o "s"
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

  // ── Botones de control ────────────────────────────────────────────────────

  /// Fila con dos controles: añadir tiempo (+20s) y saltar el descanso.
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón verde +20s — permite al paciente tomar más descanso si lo necesita
        WorkoutControlButton(
          icon: Icons.more_time_rounded,
          color: AppColors.secondary, // Verde — acción positiva
          onTap: _addTime,
          tooltip: LocaleManager.strings.restAddTime, // "+20 segundos"
        ),
        const SizedBox(width: 28),
        // Botón gris skip — permite al paciente ir directo al siguiente ejercicio
        WorkoutControlButton(
          icon: Icons.skip_next_rounded,
          color: AppColors.textSecondary, // Gris — acción secundaria
          onTap: _skipRest,
          tooltip: LocaleManager.strings.restSkip, // "Saltar descanso"
        ),
      ],
    );
  }

  // ── Tarjeta siguiente ejercicio ───────────────────────────────────────────

  /// Tarjeta que muestra el nombre y parámetros del siguiente ejercicio.
  /// Da contexto al paciente sobre lo que viene después del descanso.
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
          // Icono de pesas en contenedor azul semitransparente
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),  // Fondo azul suave
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.4)), // Borde azul semitransparente
            ),
            child: const Icon(Icons.fitness_center_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleManager.strings.restNextExercise, // "PRÓXIMO EJERCICIO"
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _nextExercise.name.toUpperCase(), // Nombre en mayúsculas
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                // Solo muestra el subtítulo si el ejercicio tiene series+reps o minutos
                if (_nextExercise.series != null && _nextExercise.reps != null ||
                    _nextExercise.minutes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    // Si tiene series y reps muestra "3 × 12"; si tiene minutos muestra "5 min"
                    _nextExercise.series != null && _nextExercise.reps != null
                        ? LocaleManager.strings.exerciseSubtitleSeries(_nextExercise.series!, _nextExercise.reps!)
                        : LocaleManager.strings.exerciseSubtitleMinutes(_nextExercise.minutes!),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
