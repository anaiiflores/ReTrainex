import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/time_picker_field_widget.dart';  // Selector de hora AM/PM
import '../../../../shared/widgets/week_day_selector_widget.dart'; // Selector de días de la semana
import '../../../users/presentation/screens/user_screen.dart';     // Pantalla de datos personales
import '../../../users/services/user_service.dart';                // Para cargar los días del usuario

/// Pantalla de ajustes (tab 3).
/// Muestra configuración de notificaciones, perfil y herramientas de desarrollo.
/// Incluye animaciones de entrada escalonadas para cada sección.
/// `StatefulWidget` con `TickerProviderStateMixin` para manejar múltiples AnimationControllers.
class SettingsScreen extends StatefulWidget {
  /// Callback que se invoca cuando el usuario cambia el idioma,
  /// para que WelcomeIniScreen reconstruya toda la UI.
  final VoidCallback? onLocaleChanged;
  const SettingsScreen({super.key, this.onLocaleChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  // ── Estado de la pantalla ────────────────────────────────────────────────
  bool _remindersEnabled = true;           // true → recordatorios activados
  String _notificationTime = '10:00 AM';  // Hora del recordatorio diario

  // ── Controladores de animación ────────────────────────────────────────────
  late final AnimationController _entryCtrl; // Controla la animación de entrada de los tiles
  late final AnimationController _pulseCtrl; // Controla el pulso del logo en el footer

  /// Listas de animaciones de posición y opacidad, una por cada tile de la lista.
  late final List<Animation<Offset>> _slides;
  late final List<Animation<double>> _fades;

  static const int _tileCount = 7; // Número de tiles con animación de entrada

  @override
  void initState() {
    super.initState();

    // Animación de entrada: dura 950 ms en total, los tiles aparecen escalonados
    _entryCtrl = AnimationController(
      vsync: this, // `this` es válido gracias a TickerProviderStateMixin
      duration: const Duration(milliseconds: 950),
    );

    // Animación de pulso del logo: ciclo de 1800 ms que se repite hacia atrás y adelante
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true); // `..` encadena la llamada a repeat() en la misma expresión

    // Genera animaciones de deslizamiento para cada tile con intervalos escalonados
    _slides = List.generate(_tileCount, (i) {
      final start = (i * 0.1).clamp(0.0, 0.65); // Cada tile empieza 100 ms después del anterior
      final end = (start + 0.5).clamp(0.0, 1.0); // Duración de cada animación: 50% del total
      return Tween<Offset>(begin: const Offset(-0.12, 0), end: Offset.zero)
          // Comienza 12% a la izquierda y termina en posición normal
          .animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic), // Subintervalo dentro del controlador
      ));
    });

    // Genera animaciones de opacidad (fade in) sincronizadas con los slides
    _fades = List.generate(_tileCount, (i) {
      final start = (i * 0.1).clamp(0.0, 0.65);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Interval(start, end)),
      );
    });

    _entryCtrl.forward(); // Dispara la animación de entrada al montar la pantalla
  }

  @override
  void dispose() {
    _entryCtrl.dispose(); // Libera los recursos del controlador
    _pulseCtrl.dispose();
    super.dispose();
  }

  /// Envuelve un widget hijo en una animación de deslizamiento + fade de entrada.
  /// [i] es el índice del tile (0–6) que determina su retraso.
  Widget _tile(int i, Widget child) => SlideTransition(
        position: _slides[i],  // Animación de posición horizontal
        child: FadeTransition(opacity: _fades[i], child: child), // Animación de opacidad
      );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 16,
        vertical: isWide ? 36 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isWide ? 560.0 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sección: Notificaciones ─────────────────────────────────
              _tile(
                  0, // Tile 0 → aparece primero
                  _SectionLabel(
                    icon: Icons.notifications_rounded,
                    label: LocaleManager.strings.settingsNotifications, // "NOTIFICACIONES"
                  )),
              const SizedBox(height: 10),
              _tile(1, _buildNotifCard()), // Tile 1 → tarjeta de notificaciones
              const SizedBox(height: 28),
              // ── Sección: Perfil ─────────────────────────────────────────
              _tile(
                  4, // Índice 4 (los índices 2 y 3 están dentro de la tarjeta de notifs)
                  _SectionLabel(
                    icon: Icons.person_rounded,
                    label: LocaleManager.strings.settingsProfile, // "PERFIL"
                  )),
              const SizedBox(height: 10),
              _tile(5, _buildProfileCard()), // Tile 5 → tarjeta de perfil
              const SizedBox(height: 36),
              _buildDevSection(), // Sección de herramientas de desarrollo (sin animación propia)
              const SizedBox(height: 28),
              _tile(6, _buildFooter()), // Tile 6 → footer con logo animado
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Notificaciones ─────────────────────────────────────────────────────────

  /// Tarjeta de configuración de notificaciones: toggle + hora + FAQ.
  Widget _buildNotifCard() {
    return _Card(
      children: [
        _tile(
            2, // Tile 2 → toggle de recordatorios
            _RemindersRow(
              value: _remindersEnabled,
              onChanged: (v) {
                setState(() => _remindersEnabled = v);
                // Muestra un snackbar al activar los recordatorios
                if (v && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Text('⚡', style: TextStyle(fontSize: 18)), // Emoji decorativo
                          SizedBox(width: 8),
                          Text(
                            LocaleManager.strings.remindersEnabled, // "¡Recordatorios activados!"
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating, // Flota sobre el contenido
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            )),
        const _TileDivider(), // Línea separadora
        _tile(
          3, // Tile 3 → selector de hora
          Opacity(
            opacity: _remindersEnabled ? 1.0 : 0.4, // Se atenúa si los recordatorios están off
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TimePickerField(
                time: _notificationTime,
                // Solo actualiza la hora si los recordatorios están activos
                onChanged: _remindersEnabled
                    ? (t) => setState(() => _notificationTime = t)
                    : (_) {}, // Callback vacío → campo visualmente desactivado
              ),
            ),
          ),
        ),
        const _TileDivider(),
        _SettingsTile(
          icon: Icons.help_outline_rounded,
          iconColor: AppColors.textSecondary,
          title: LocaleManager.strings.settingsFaq, // "Preguntas frecuentes"
          onTap: _showFaq, // Abre el bottom sheet de FAQ
        ),
      ],
    );
  }

  // ── Perfil ─────────────────────────────────────────────────────────────────

  /// Tarjeta con acceso a datos personales y cambio de idioma.
  Widget _buildProfileCard() {
    return _Card(
      children: [
        _SettingsTile(
          icon: Icons.account_circle_rounded,
          iconColor: AppColors.primary,
          iconBg: true, // true → muestra fondo circular alrededor del icono
          title: LocaleManager.strings.settingsPersonalData,       // "Datos personales"
          subtitle: LocaleManager.strings.settingsPersonalDataSub, // Subtítulo descriptivo
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UserScreen()), // Navega al perfil
          ),
        ),
        const _TileDivider(),
        _SettingsTile(
          icon: Icons.language_rounded,
          iconColor: AppColors.textSecondary,
          title: LocaleManager.strings.settingsLanguage, // "Idioma"
          // Muestra la bandera y nombre del idioma actual
          subtitle: LocaleManager.current == AppLocale.es
              ? '🇪🇸 Español'
              : '🇬🇧 English',
          onTap: () {
            setState(() {
              // Alterna entre español e inglés
              LocaleManager.setLocale(
                LocaleManager.current == AppLocale.es
                    ? AppLocale.en  // Español → Inglés
                    : AppLocale.es, // Inglés → Español
              );
            });
            // Notifica al padre (WelcomeIniScreen) para que reconstruya la UI con el nuevo idioma
            widget.onLocaleChanged?.call();
          },
        ),
      ],
    );
  }

  // ── DEV ───────────────────────────────────────────────────────────────────

  /// Sección de herramientas de desarrollo — visible en todos los entornos por ahora.
  Widget _buildDevSection() {
    return _Card(
      children: [
        _SettingsTile(
          icon: Icons.developer_mode_rounded,
          iconColor: Colors.orangeAccent,
          title: LocaleManager.strings.settingsDevTestTitle,  // "Test de componentes"
          subtitle: LocaleManager.strings.settingsDevTestSub, // Descripción de la herramienta
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const _WeekDaySelectorTestScreen()), // Pantalla de test interna
          ),
        ),
      ],
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  /// Footer con el logo animado (pulso), nombre de la app, versión y copyright.
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Logo con efecto de halo pulsante usando AnimatedBuilder
          AnimatedBuilder(
            animation: _pulseCtrl, // Se reconstruye en cada tick del pulso
            builder: (_, __) {
              // glow oscila entre 0.3 y 1.0 según el valor del controlador (0.0–1.0)
              final glow = 0.3 + 0.7 * _pulseCtrl.value;
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: glow * 0.65), // Halo animado
                      blurRadius: 18 + 14 * _pulseCtrl.value, // El halo crece y decrece
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 36),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            LocaleManager.strings.appName, // "ReTrainex"
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleManager.strings.settingsVersion, // "v1.0.0"
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleManager.strings.settingsCopyright, // "© 2026 ReTrainex"
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Acciones ───────────────────────────────────────────────────────────────

  /// Abre el bottom sheet con las preguntas frecuentes.
  void _showFaq() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,     // Permite que ocupe más del 50% de la pantalla
      backgroundColor: Colors.transparent, // El fondo lo define el propio sheet
      builder: (_) => const _FaqSheet(),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

/// Etiqueta de sección: icono pequeño + texto en gris.
/// Reutilizada antes de cada bloque de la pantalla.
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Card container ────────────────────────────────────────────────────────────

/// Contenedor de tarjeta con bordes redondeados que agrupa tiles de ajustes.
class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children), // Los tiles se apilan verticalmente dentro de la tarjeta
    );
  }
}

// ── Tile divider ──────────────────────────────────────────────────────────────

/// Línea separadora horizontal entre tiles de una misma tarjeta.
class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16), // Sangría para que no llegue al borde
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}

// ── Reminders toggle row ──────────────────────────────────────────────────────

/// Fila con el toggle (interruptor) personalizado para activar/desactivar recordatorios.
/// Incluye una animación de rebote al pulsarlo.
class _RemindersRow extends StatefulWidget {
  final bool value;                  // Estado actual del toggle
  final ValueChanged<bool> onChanged; // Callback con el nuevo valor

  const _RemindersRow({required this.value, required this.onChanged});

  @override
  State<_RemindersRow> createState() => _RemindersRowState();
}

class _RemindersRowState extends State<_RemindersRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl; // Controla el efecto de escala al pulsar

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.88, // Escala mínima al comprimir (88%)
      upperBound: 1.0,  // Escala normal (100%)
      value: 1.0,       // Comienza en tamaño normal
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  /// Anima el toggle con un rebote: reduce escala, cambia estado, expande.
  Future<void> _toggle() async {
    await _bounceCtrl.reverse(); // Reduce a 88%
    widget.onChanged(!widget.value); // Notifica el nuevo valor al padre
    _bounceCtrl.forward();          // Vuelve al 100%
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleManager.strings.reminders, // "Recordatorios"
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  LocaleManager.strings.remindersSubtitle, // Descripción breve
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Envuelve el toggle en ScaleTransition para el efecto de rebote
          ScaleTransition(
            scale: _bounceCtrl,
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOut,
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // Azul si activo, gris si inactivo
                  color: widget.value ? AppColors.primary : AppColors.border,
                  // Halo azul solo cuando está activo
                  boxShadow: widget.value
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                // Círculo blanco que se desliza dentro del toggle
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                  // Derecha si activo, izquierda si inactivo
                  alignment: widget.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.all(3), // Margen interior para separar del borde
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

/// Fila de ajuste individual con icono, título, subtítulo opcional y flecha de navegación.
/// Incluye una animación de escala (100% → 95% → 100%) al pulsarlo.
class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final bool iconBg;      // true → envuelve el icono en un contenedor con fondo de color
  final String title;
  final String? subtitle; // null → no se muestra segunda línea
  final VoidCallback? onTap; // null → el tile no es interactivo (sin flecha)

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    this.iconBg = false,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl; // Controla la escala del tile al pulsarlo

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.95, // Compresión mínima (95%)
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Efecto de escala: reduce a 95%, luego vuelve a 100%, luego ejecuta la acción.
  Future<void> _onTap() async {
    if (widget.onTap == null) return; // Sin callback → no hace nada
    await _ctrl.reverse(); // Comprime a 95%
    _ctrl.forward();       // Vuelve a 100% (se ejecuta en paralelo con la acción)
    widget.onTap!();        // Ejecuta la acción del tile
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _ctrl, // Aplica la animación de escala al tile completo
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // El área vacía también detecta taps
        onTap: _onTap,
        child: Opacity(
          opacity: 1.0, // Por ahora siempre visible (podría usarse para deshabilitar)
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icono: con fondo si iconBg=true, sin fondo si false
                widget.iconBg
                    ? Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon,
                            color: widget.iconColor, size: 20),
                      )
                    : Icon(widget.icon, color: widget.iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!, // '!' seguro: ya verificamos != null
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                // Flecha de navegación solo si el tile tiene acción
                if (widget.onTap != null)
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── WeekDaySelector Test Screen ───────────────────────────────────────────────

/// Pantalla de prueba del selector de días de la semana y el TimePicker.
/// Accesible desde la sección de desarrollo en Ajustes.
class _WeekDaySelectorTestScreen extends StatefulWidget {
  const _WeekDaySelectorTestScreen();

  @override
  State<_WeekDaySelectorTestScreen> createState() =>
      _WeekDaySelectorTestScreenState();
}

class _WeekDaySelectorTestScreenState
    extends State<_WeekDaySelectorTestScreen> {
  Set<int> _selectedDays = {}; // Días seleccionados en el selector
  String _activityTime = '10:00 AM'; // Hora de actividad seleccionada

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadDays(); // Pre-carga los días del usuario desde el servicio
  }

  /// Carga los días de rutina del usuario como selección inicial.
  Future<void> _loadDays() async {
    final user = await _userService.getUser();
    if (mounted) setState(() => _selectedDays = user.routineDays.toSet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          LocaleManager.strings.settingsDevTestTitle.toUpperCase(), // "TEST DE COMPONENTES"
          style: const TextStyle(
            color: Colors.orangeAccent, // Naranja para indicar que es una herramienta de dev
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleManager.strings.formPlanTitle, // "PLANIFICACIÓN"
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              LocaleManager.strings.formPlanSubtitle, // Subtítulo descriptivo
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              LocaleManager.strings.formSelectDays, // "Selecciona tus días de entrenamiento"
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Selector de días con multiselección habilitada
            WeekDaySelector(
              multiSelect: true,
              initialSelected: _selectedDays,
              onChanged: (days) => setState(() => _selectedDays = days),
            ),
            const SizedBox(height: 24),
            Text(
              LocaleManager.strings.formActivityTime, // "Hora de actividad"
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            // Selector de hora con diálogo nativo
            TimePickerField(
              time: _activityTime,
              onChanged: (t) => setState(() => _activityTime = t),
            ),
            const SizedBox(height: 32),
            // Botón de inicio (pendiente de implementar la lógica real)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {}, // TODO: guardar la configuración
                icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                label: Text(
                  LocaleManager.strings.formStart, // "COMENZAR"
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAQ Bottom Sheet ──────────────────────────────────────────────────────────

/// Bottom sheet con las preguntas frecuentes, arrastrable por el usuario.
class _FaqSheet extends StatelessWidget {
  const _FaqSheet();

  /// Lista de preguntas y respuestas localizadas.
  /// Es un getter para obtener siempre los strings del idioma activo.
  List<_FaqData> get _faqs => [
        _FaqData(
          question: LocaleManager.strings.faq1Question,
          answer: LocaleManager.strings.faq1Answer,
        ),
        _FaqData(
          question: LocaleManager.strings.faq2Question,
          answer: LocaleManager.strings.faq2Answer,
        ),
        _FaqData(
          question: LocaleManager.strings.faq3Question,
          answer: LocaleManager.strings.faq3Answer,
        ),
        _FaqData(
          question: LocaleManager.strings.faq4Question,
          answer: LocaleManager.strings.faq4Answer,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,  // Ocupa el 60% de la pantalla al abrirse
      maxChildSize: 0.92,     // Se puede expandir hasta el 92%
      minChildSize: 0.4,      // Se puede contraer hasta el 40%
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // Solo esquinas superiores
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Indicador de arrastre (barra gris horizontal)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              LocaleManager.strings.faqTitle, // "PREGUNTAS FRECUENTES"
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                controller: ctrl, // Vincula el scroll al controlador del sheet draggable
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                separatorBuilder: (_, __) => const SizedBox(height: 10), // Espacio entre preguntas
                itemCount: _faqs.length,
                itemBuilder: (_, i) => _FaqItem(data: _faqs[i]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Datos de una pregunta frecuente (pregunta + respuesta).
class _FaqData {
  final String question;
  final String answer;
  const _FaqData({required this.question, required this.answer});
}

/// Item expandible de la FAQ.
/// Al pulsar muestra/oculta la respuesta con animación `AnimatedCrossFade`.
class _FaqItem extends StatefulWidget {
  final _FaqData data;
  const _FaqItem({required this.data});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false; // false → solo muestra la pregunta; true → muestra pregunta + respuesta

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded), // Toggle al pulsar
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Fondo azul translúcido si expandido, gris oscuro si contraído
          color: _expanded
              ? AppColors.primary.withValues(alpha: 0.09)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded
                ? AppColors.primary.withValues(alpha: 0.35) // Borde azul si expandido
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data.question, // Texto de la pregunta siempre visible
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Flecha que rota 180° al expandir (AnimatedRotation)
                AnimatedRotation(
                  duration: const Duration(milliseconds: 280),
                  turns: _expanded ? 0.5 : 0.0, // 0.5 turns = 180 grados
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary, size: 22),
                ),
              ],
            ),
            // Respuesta: se muestra/oculta con CrossFade (fade between two children)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(), // Widget vacío cuando está contraído
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.data.answer, // Texto de la respuesta
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.55, // Interlineado para párrafos largos
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond  // Expandido → muestra la respuesta
                  : CrossFadeState.showFirst,  // Contraído → muestra SizedBox.shrink()
              duration: const Duration(milliseconds: 280),
            ),
          ],
        ),
      ),
    );
  }
}
