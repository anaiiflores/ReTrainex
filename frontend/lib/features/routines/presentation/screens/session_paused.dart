import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';     // Textos localizados
import '../../../../core/theme/app_colors.dart';           // Paleta de colores de la app
import '../../../../shared/widgets/app_button_widget.dart'; // Botón principal degradado
import '../../../../shared/widgets/video_area_widget.dart'; // Reproductor de vídeo del ejercicio
import '../../../exercises/models/exercise_detail_model.dart'; // ExerciseModel — modelo de ejercicio
import 'workout_preparation_screen.dart';     // Destino al pulsar "INICIAR"
import '../../services/workout_session_service.dart'; // Para marcar el inicio de la sesión

/// Pantalla de previsualización de un ejercicio (modo pausa o modo preview).
/// Se usa en dos contextos:
///  1. `fromWorkout = false` (por defecto): acceso desde RoutineDetailScreen al pulsar play
///     en un ejercicio. El botón muestra "INICIAR" y lanza el flujo completo de sesión.
///  2. `fromWorkout = true`: acceso desde WorkoutExerciseScreen al abrir los detalles
///     durante la sesión. El botón muestra "VOLVER" y solo hace `Navigator.pop`.
/// `StatelessWidget` porque no tiene estado propio (no hay timers ni animaciones).
class SessionPausedScreen extends StatelessWidget {
  /// El ejercicio cuya información se está mostrando.
  final ExerciseModel exercise;

  /// Lista completa de ejercicios de la sesión — se necesita para lanzar
  /// WorkoutPreparationScreen con el contexto correcto (modo "INICIAR").
  final List<ExerciseModel> exercises;

  /// Índice del ejercicio actual en la lista (base 0).
  final int currentIndex;

  /// Si `true`, viene desde el workout activo → el botón actúa como "VOLVER".
  /// Si `false` (por defecto), viene desde el preview → el botón lanza la sesión.
  final bool fromWorkout;

  const SessionPausedScreen({
    super.key,
    required this.exercise,
    required this.exercises,
    required this.currentIndex,
    this.fromWorkout = false, // Por defecto, vista de preview desde la lista de rutinas
  });

  /// Formatea un número de segundos en texto legible.
  /// Ejemplos: 90 → "1:30", 60 → "1min", 45 → "45s", 0 → "0s".
  String _formatDuration(int seconds) {
    final m = seconds ~/ 60; // División entera: minutos completos
    final s = seconds % 60;  // Módulo: segundos restantes tras quitar los minutos
    if (m == 0) return '${s}s';               // Solo segundos si no llega al minuto
    if (s == 0) return '${m}min';             // Solo minutos si los segundos son exactos
    return '$m:${s.toString().padLeft(2, '0')}'; // "1:05" — segundos con cero de relleno
  }

  /// Marca el inicio de la sesión y navega a WorkoutPreparationScreen.
  /// `pushReplacement` sustituye esta pantalla para que el usuario no vuelva
  /// al preview desde la pantalla de preparación.
  void _startExercise(BuildContext context) {
    WorkoutSessionService.markStart(); // Guarda el timestamp de inicio para calcular duración
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutPreparationScreen(
          exercises: exercises,      // Pasa la lista completa al flujo de sesión
          currentIndex: currentIndex, // Empieza en el ejercicio que el usuario previsualiza
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600; // Tablet vs móvil

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context), // AppBar con título y contador de ejercicios
      body: SafeArea(
        child: SingleChildScrollView(
          // Más margen horizontal en tablet para no estirar el contenido
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 24,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              // Limita el ancho máximo en tablet a 520 lógicos para mejor legibilidad
              constraints:
                  BoxConstraints(maxWidth: isWide ? 520.0 : double.infinity),
              child: Column(
                children: [
                  _buildVideoArea(isWide),       // Reproductor de vídeo / placeholder
                  const SizedBox(height: 20),
                  _buildTitle(isWide),            // Nombre del ejercicio + ritmo
                  const SizedBox(height: 28),
                  _buildStatsRow(),               // Tarjetas de duración, series y reps
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),        // Tarjeta de descripción del ejercicio
                  const SizedBox(height: 12),
                  _buildTipsCard(),               // Tarjeta de consejos de ejecución
                  const SizedBox(height: 32),
                  // Botón principal: "INICIAR" si viene del preview, "VOLVER" si viene del workout
                  AppGradientButton(
                    label: fromWorkout
                        ? LocaleManager.strings.sessionPausedBack  // "VOLVER"
                        : LocaleManager.strings.sessionPausedStart, // "INICIAR"
                    onPressed: fromWorkout
                        ? () => Navigator.of(context).pop() // Cierra y vuelve al workout
                        : () => _startExercise(context),    // Lanza la sesión completa
                    icon: fromWorkout
                        ? Icons.arrow_back_rounded  // Flecha atrás para "VOLVER"
                        : Icons.play_arrow_rounded, // Play para "INICIAR"
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
      elevation: 0,      // Sin sombra — el diseño es plano
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(), // Vuelve a la pantalla anterior
      ),
      title: Text(
        LocaleManager.strings.sessionPausedTitle, // "EJERCICIO PAUSADO" o "DETALLE"
        style: const TextStyle(
          color: AppColors.primary, // Azul — marca esta pantalla como informativa
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            // Contador "índice / total" para ubicar al usuario en la lista de ejercicios
            child: Text(
              '${currentIndex + 1} / ${exercises.length}', // Ej: "2 / 5"
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

  /// Delega en VideoAreaWidget para mostrar el vídeo, el slideshow de imágenes o un placeholder.
  Widget _buildVideoArea(bool isWide) {
    return VideoAreaWidget(
      videoUrl: exercise.videoUrl,
      imageAssets: exercise.imageAssets, // Fotogramas locales del ejercicio
      isWide: isWide,
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────

  /// Muestra el nombre del ejercicio en mayúsculas y, si hay ritmo definido, lo muestra debajo.
  Widget _buildTitle(bool isWide) {
    return Column(
      children: [
        Text(
          exercise.name.toUpperCase(), // Nombre en mayúsculas — estilo técnico
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 32 : 26, // Más grande en tablet
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1.1,
          ),
        ),
        // El ritmo solo se muestra si el ejercicio lo especifica (ej: "2-1-2")
        if (exercise.rhythm != null) ...[
          const SizedBox(height: 8),
          Text(
            LocaleManager.strings.sessionPausedRhythm(exercise.rhythm!), // "RITMO: 2-1-2"
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

  /// Fila de tres tarjetas con las métricas del ejercicio: duración, series y repeticiones.
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: Colors.orangeAccent, // Naranja — tiempo
            label: LocaleManager.strings.statDuration, // "DURACIÓN"
            // Formatea el tiempo efectivo (puede ser 0 para ejercicios sin tiempo)
            value: _formatDuration(exercise.effectiveDurationSeconds),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.repeat_rounded,
            iconColor: AppColors.primary, // Azul — series
            label: LocaleManager.strings.sessionPausedSeries, // "SERIES"
            value: exercise.series != null ? '${exercise.series}' : '—', // '—' si no aplica
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.format_list_numbered_rounded,
            iconColor: AppColors.secondary, // Verde — reps
            label: LocaleManager.strings.sessionPausedReps, // "REPS"
            value: exercise.reps != null ? '${exercise.reps}' : '—', // '—' si no aplica
          ),
        ),
      ],
    );
  }

  // ── Info cards ────────────────────────────────────────────────────────────

  /// Tarjeta de descripción del ejercicio con icono azul.
  Widget _buildDescriptionCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12), // Fondo azul muy suave
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.description_rounded,
            color: AppColors.primary, size: 22),
      ),
      title: LocaleManager.strings.sessionPausedDescription, // "DESCRIPCIÓN"
      content: Text(
        LocaleManager.strings.sessionPausedDescriptionText, // Texto descriptivo del ejercicio
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.55, // Interlineado para mejor legibilidad
        ),
      ),
    );
  }

  /// Tarjeta de consejos de ejecución con icono verde.
  Widget _buildTipsCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.12), // Fondo verde muy suave
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.tips_and_updates_rounded,
            color: AppColors.secondary, size: 22),
      ),
      title: LocaleManager.strings.sessionPausedTips, // "CONSEJOS"
      content: Text(
        LocaleManager.strings.sessionPausedTipsText, // Texto de consejos de ejecución
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.55,
        ),
      ),
    );
  }
}

// ── Widgets locales ───────────────────────────────────────────────────────────

/// Tarjeta de métrica individual (duración, series o reps).
/// Muestra un icono de color, la etiqueta pequeña y el valor grande.
class _StatCard extends StatelessWidget {
  final IconData icon;      // Icono que identifica la métrica
  final Color iconColor;    // Color temático del icono
  final String label;       // Etiqueta descriptiva en mayúsculas
  final String value;       // Valor numérico o "—" si no aplica

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
        color: AppColors.card,              // Fondo oscuro de tarjeta
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20), // Icono de color temático
          const SizedBox(height: 8),
          Text(
            label, // Etiqueta en letra pequeña (ej: "DURACIÓN")
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value, // Valor grande y prominente (ej: "45s" o "3")
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1, // Sin interlineado extra para que el número no se separe del borde
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta informativa genérica con un widget líder (icono en caja),
/// un título en mayúsculas y un widget de contenido libre.
/// Usada tanto para la descripción como para los consejos.
class _InfoCard extends StatelessWidget {
  final Widget leading; // Icono en contenedor cuadrado (diferente color por sección)
  final String title;   // Título de la sección en mayúsculas
  final Widget content; // Contenido libre (normalmente un `Text`)

  const _InfoCard({
    required this.leading,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ocupa todo el ancho disponible
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea al tope cuando el texto es largo
        children: [
          leading,            // Icono a la izquierda
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, // Título de la tarjeta en blanco y negrilla
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                content, // Cuerpo de la tarjeta (texto de descripción o consejos)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
