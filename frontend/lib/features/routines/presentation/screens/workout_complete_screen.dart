import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';      // Textos localizados
import '../../../../core/theme/app_colors.dart';            // Paleta de colores
import '../../../../shared/widgets/app_bottom_nav_widget.dart'; // Barra de navegación inferior
import '../../../../shared/widgets/app_button_widget.dart'; // Botón sólido "IR AL INICIO"
import '../../services/workout_session_service.dart';       // Para leer los segundos transcurridos

/// Pantalla de sesión completada.
/// Se muestra al finalizar el último ejercicio de la rutina.
/// Muestra el trofeo, las estadísticas de la sesión (duración y ejercicios),
/// un mensaje de felicitación, la racha de días y el logro desbloqueado.
class WorkoutCompleteScreen extends StatefulWidget {
  /// Número total de ejercicios completados en la sesión.
  final int exerciseCount;

  const WorkoutCompleteScreen({super.key, required this.exerciseCount});

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  // `late final` porque se inicializa en `initState` y no cambia después.
  // Se captura en `initState` para que no cambie con futuros rebuilds
  // (si el servicio siguiera contando, la pantalla mostraría valores incorrectos).
  late final int _elapsedSeconds;

  // Datos mock hasta que la API devuelva la racha y los logros reales del usuario.
  static const int _streakDays = 5;                              // Días consecutivos de racha
  static const String _achievementName = 'Madrugador de Acero'; // Nombre del logro desbloqueado

  @override
  void initState() {
    super.initState();
    // Captura la duración de la sesión justo al montarse — valor fijo para toda la pantalla.
    _elapsedSeconds = WorkoutSessionService.elapsedSeconds;
  }

  /// Formatea segundos en "MM:SS" con ceros de relleno.
  /// Ejemplo: 90 → "01:30", 3661 → "61:01".
  String _formatDuration(int seconds) {
    final m = seconds ~/ 60; // División entera — minutos completos
    final s = seconds % 60;  // Módulo — segundos restantes
    // `padLeft(2, '0')` añade un "0" a la izquierda si el número tiene un solo dígito
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Vuelve a la pantalla de inicio saltando toda la pila de navegación del workout.
  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst); // Elimina todas las rutas hasta la raíz
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(), // AppBar con bandera verde y botón de cierre
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
                  _buildTrophy(isWide),             // Círculo con icono de trofeo y halo
                  const SizedBox(height: 20),
                  _buildTitle(isWide),              // "¡EXCELENTE!" + subtítulo
                  const SizedBox(height: 28),
                  _buildStatsRow(isWide),           // Duración total y número de ejercicios
                  const SizedBox(height: 16),
                  _buildCongratulationsCard(),      // Tarjeta de felicitación del fisio
                  const SizedBox(height: 12),
                  _buildStreakCard(),               // Tarjeta de racha de días
                  const SizedBox(height: 12),
                  _buildAchievementCard(),          // Tarjeta de logro desbloqueado
                  const SizedBox(height: 32),
                  _buildHomeButton(),               // Botón sólido "IR AL INICIO"
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      // Si el usuario pulsa otro tab, también vuelve al inicio
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
      // Leading: icono de bandera verde como decoración — marca el fin de la sesión
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.flag_rounded, color: AppColors.secondary, size: 24),
      ),
      title: Text(
        LocaleManager.strings.sessionCompleteAppBar, // "SESIÓN COMPLETADA"
        style: const TextStyle(
          color: AppColors.secondary, // Verde — estado de éxito
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      // Botón de cierre en la esquina derecha — equivalente a _goHome()
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: _goHome, // Vuelve al inicio directamente
        ),
      ],
    );
  }

  // ── Trofeo ────────────────────────────────────────────────────────────────

  /// Círculo con el icono de trofeo y un halo azul difuminado.
  /// El halo refuerza visualmente el sentido de logro.
  Widget _buildTrophy(bool isWide) {
    final double size = isWide ? 110 : 90; // Trofeo más grande en tablet
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,   // Fondo oscuro del círculo
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2), // Halo azul suave
            blurRadius: 24,  // Radio de difuminado amplio para efecto de brillo
            spreadRadius: 4, // El halo se expande 4 px más allá del borde del círculo
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events_rounded, // Trofeo — icono de evento/logro
        color: AppColors.primary,
        size: size * 0.48, // El icono ocupa el 48% del diámetro del círculo
      ),
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────

  /// Título principal "¡EXCELENTE!" + subtítulo "DÍA COMPLETADO".
  Widget _buildTitle(bool isWide) {
    return Column(
      children: [
        Text(
          LocaleManager.strings.excellent, // "¡EXCELENTE!"
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 46 : 38, // Grande para máximo impacto visual
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleManager.strings.dayCompleted, // "DÍA COMPLETADO"
          style: const TextStyle(
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

  /// Fila con dos tarjetas: duración total de la sesión y número de ejercicios.
  Widget _buildStatsRow(bool isWide) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            iconColor: Colors.orangeAccent, // Naranja — tiempo
            value: _formatDuration(_elapsedSeconds), // "08:45" p.ej.
            label: LocaleManager.strings.statDuration, // "DURACIÓN"
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.primary, // Azul — ejercicios
            label: LocaleManager.strings.statExercises, // "EJERCICIOS"
            value: '${widget.exerciseCount}', // Número de ejercicios completados
          ),
        ),
      ],
    );
  }

  // ── Tarjeta de felicitaciones ─────────────────────────────────────────────

  /// Tarjeta con mensaje de felicitación del fisioterapeuta.
  Widget _buildCongratulationsCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12), // Fondo azul muy suave
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.celebration_rounded,
            color: AppColors.primary, size: 22),
      ),
      content: Text(
        LocaleManager.strings.congratsMessage, // Mensaje motivacional personalizado
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  // ── Tarjeta de racha ──────────────────────────────────────────────────────

  /// Tarjeta con la racha de días consecutivos entrenados.
  /// Muestra un número de puntos (uno por día de racha) todos rellenos en naranja.
  Widget _buildStreakCard() {
    return _InfoCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.12), // Fondo naranja suave
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.local_fire_department_rounded,
            color: Colors.orangeAccent, size: 22),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleManager.strings.streakDays(_streakDays), // "5 DÍAS DE RACHA"
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleManager.strings.onFire, // "¡Estás en llamas!"
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          // Fila de puntos naranjas — uno por cada día de racha completado
          Row(
            children: List.generate(
              _streakDays, // Genera `_streakDays` puntos (5 en el mock)
              (i) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 6), // Separación entre puntos
                decoration: BoxDecoration(
                  // Todos los puntos son naranja porque `i < _streakDays` siempre es verdad
                  // (en una versión real, los días pendientes serían `AppColors.border`)
                  color:
                      i < _streakDays ? Colors.orangeAccent : AppColors.border,
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

  /// Tarjeta con el nuevo logro desbloqueado en esta sesión.
  /// El trailing es un chevron que sugiere que se puede navegar al detalle (no implementado).
  Widget _buildAchievementCard() {
    return _InfoCard(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.surface, // Fondo oscuro del avatar
        child: Icon(Icons.military_tech_rounded,
            color: Colors.amberAccent.shade400, size: 22), // Medalla dorada
      ),
      // Chevron derecho — indica que hay más detalles (navegación pendiente de implementar)
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary, size: 22),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleManager.strings.newAchievement, // "NUEVO LOGRO"
            style: const TextStyle(
              color: AppColors.secondary, // Verde — novedad positiva
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _achievementName, // "Madrugador de Acero" (mock)
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

  /// Botón sólido que lleva al usuario de vuelta a la pantalla principal.
  Widget _buildHomeButton() {
    return AppSolidButton(
      label: LocaleManager.strings.goHome, // "IR AL INICIO"
      onPressed: _goHome,
      icon: Icons.home_rounded,
      height: 56,
      borderRadius: 16,
    );
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

/// Tarjeta de estadística con icono a la izquierda y valor numérico grande.
/// Diferente de `_StatCard` en `session_paused.dart` — layout horizontal vs vertical.
class _StatCard extends StatelessWidget {
  final IconData icon;      // Icono de la métrica
  final Color iconColor;    // Color temático
  final String value;       // Valor formateado (ej: "08:45" o "4")
  final String label;       // Etiqueta de la métrica (ej: "DURACIÓN")

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
      // Layout horizontal: icono a la izquierda, label+valor a la derecha
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, // Etiqueta pequeña (ej: "DURACIÓN")
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value, // Valor grande y prominente
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta informativa genérica con leading (icono/avatar), contenido central y trailing opcional.
/// Usada para felicitaciones, racha y logros — varía solo en los parámetros.
class _InfoCard extends StatelessWidget {
  final Widget leading;    // Icono/avatar a la izquierda
  final Widget content;    // Contenido principal de la tarjeta
  final Widget? trailing;  // Widget opcional a la derecha (ej: chevron)

  const _InfoCard({
    required this.leading,
    required this.content,
    this.trailing, // null si no se necesita acción/navegación
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,             // Icono/avatar a la izquierda
          const SizedBox(width: 14),
          Expanded(child: content), // El contenido ocupa el espacio restante
          // El trailing solo se renderiza si fue proporcionado
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!, // `!` seguro porque el `if` garantiza que no es null
          ],
        ],
      ),
    );
  }
}
