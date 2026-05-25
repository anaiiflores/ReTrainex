import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_widget.dart';    // Barra de navegación inferior
import '../../../../shared/widgets/loading_widget.dart';           // Spinner de carga
import '../../../../shared/widgets/error_message_widget.dart';     // Mensaje de error con retry
import '../../../routines/models/routine_model.dart' as rm;        // Alias `rm` para evitar conflicto con RoutineStatus de dashboard
import '../../../routines/presentation/screens/routine_detail_screen.dart'; // Destino del botón "INICIAR"
import '../../../routines/presentation/screens/routines_list_screen.dart';  // Tab de rutinas
import '../../../routines/services/routine_service.dart';
import '../../../../shared/widgets/countdown_ring_widget.dart';    // Anillo de progreso semanal
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../../users/models/user_model.dart';
import '../../../users/services/user_service.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../shared/widgets/app_button_widget.dart';        // AppGradientButton
import 'notifications_screen.dart';
import 'progress_screen.dart';
import 'schedule_planning_screen.dart';
import 'settings_screen.dart';

/// Pantalla principal de la app (tab 0).
/// Actúa también como shell de navegación: gestiona los 4 tabs (Home, Rutinas, Progreso, Ajustes).
/// `StatefulWidget` porque mantiene el índice activo y los datos del dashboard.
class WelcomeIniScreen extends StatefulWidget {
  final String userName; // Nombre inicial — se sobrescribe con el dato real del UserService

  const WelcomeIniScreen({super.key, required this.userName});

  @override
  State<WelcomeIniScreen> createState() => _WelcomeIniScreenState();
}

class _WelcomeIniScreenState extends State<WelcomeIniScreen> {
  int _currentIndex = 0; // Índice del tab activo (0=Home, 1=Rutinas, 2=Progreso, 3=Ajustes)

  // ── Estado ────────────────────────────────────────────────────────────────
  bool _isLoading = false;       // true mientras se cargan los datos iniciales
  String? _errorMessage;         // null si no hay error; mensaje de error si la carga falla
  DashboardModel? _dashboard;    // Datos del dashboard (null hasta que carga)
  UserModel? _user;              // Perfil completo del usuario (null hasta que carga)
  rm.RoutineModel? _todayRoutine; // Rutina programada para hoy (null si no hay ninguna)

  // Instancias de servicios — se crean aquí para poder reutilizarlas en _loadData
  final DashboardService _dashboardService = DashboardService();
  final UserService _userService = UserService();
  final RoutineService _routineService = RoutineService();

  /// Nombre a mostrar: prefiere el nombre cargado del backend, cae en el prop del widget.
  String get _displayName => _user?.userName ?? widget.userName;

  // ── AppBar configs por tab ────────────────────────────────────────────────
  /// Configuración dinámica del AppBar según el tab activo.
  /// Es un getter (no const) porque los strings vienen de LocaleManager.
  List<_AppBarConfig> get _appBarConfigs => [
        _AppBarConfig(
            icon: Icons.bolt,
            label: LocaleManager.strings.appName, // "ReTrainex"
            color: AppColors.primary,
            showBell: true), // Solo en Home se muestra la campana de notificaciones
        _AppBarConfig(
            icon: Icons.route_rounded,
            label: LocaleManager.strings.navRoutines,
            color: AppColors.secondary,
            showBell: false),
        _AppBarConfig(
            icon: Icons.trending_up_rounded,
            label: LocaleManager.strings.navProgress,
            color: AppColors.secondary,
            showBell: false),
        _AppBarConfig(
            icon: Icons.settings_rounded,
            label: LocaleManager.strings.navSettings,
            color: AppColors.secondary,
            showBell: false),
      ];

  @override
  void initState() {
    super.initState();
    _loadData(); // Carga todos los datos al montar la pantalla
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  /// Carga en paralelo el dashboard, el perfil del usuario y las rutinas semanales.
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Resetea el error previo al reintentar
    });
    try {
      // Lanza las tres peticiones en paralelo para minimizar el tiempo de espera
      final dashFuture = _dashboardService.getDashboardData();
      final userFuture = _userService.getUser();
      final routinesFuture = _routineService.getWeeklyRoutines();

      // Espera a que las tres completen
      final dash = await dashFuture;
      final user = await userFuture;
      final routines = await routinesFuture;

      // weekday devuelve 1=Lun … 7=Dom (ISO 8601)
      final todayWeekday = DateTime.now().weekday;
      setState(() {
        _dashboard = dash;
        _user = user;
        // Busca la rutina de hoy en la lista semanal; null si no hay ninguna para hoy
        _todayRoutine = routines.cast<rm.RoutineModel?>().firstWhere(
              (r) => r!.weekday == todayWeekday,
              orElse: () => null, // No lanza excepción si no hay coincidencia
            );
      });
    } catch (_) {
      // Cualquier error de red o parsing muestra el mensaje de error con botón de retry
      setState(() => _errorMessage = LocaleManager.strings.errorLoadingInfo);
    } finally {
      setState(() => _isLoading = false); // Oculta el spinner siempre, con o sin error
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600; // Tablet si ≥600px

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      // En tablet: layout con NavigationRail lateral; en móvil: pantalla completa
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      // En tablet no hay barra inferior; en móvil sí
      bottomNavigationBar: isWide
          ? null
          : AppBottomNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i), // Cambia de tab
            ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  /// Construye el AppBar adaptado al tab activo.
  PreferredSizeWidget _buildAppBar() {
    final cfg = _appBarConfigs[_currentIndex]; // Configuración del tab activo
    final isHome = _currentIndex == 0;
    final hasUnread = _dashboard?.hasUnreadNotification ?? false; // Badge de notificaciones

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: !isHome, // En Home el título está a la izquierda; en otros tabs, centrado
      titleSpacing: isHome ? 16 : null, // Más margen solo en Home
      title: Row(
        mainAxisSize: isHome ? MainAxisSize.max : MainAxisSize.min, // Home ocupa todo el ancho
        children: [
          Icon(cfg.icon, color: cfg.color, size: 20),
          const SizedBox(width: 8),
          Text(
            cfg.label,
            style: TextStyle(
              color: cfg.color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        if (cfg.showBell) ...[ // Solo en el tab Home se muestran las acciones
          Text(
            _displayName, // Nombre del usuario junto a la campana
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Badge(
              isLabelVisible: hasUnread, // Punto rojo solo si hay notificaciones sin leer
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.textSecondary, size: 28),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(), // Navega a la pantalla de notifs
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Layout responsive ─────────────────────────────────────────────────────

  /// Layout tablet: NavigationRail a la izquierda + contenido a la derecha.
  Widget _buildWideLayout() {
    return Row(
      children: [
        NavigationRail(
          backgroundColor: AppColors.surface, // Fondo del rail lateral
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelType: NavigationRailLabelType.all, // Muestra siempre las etiquetas
          selectedIconTheme:
              const IconThemeData(color: AppColors.primary, size: 28),
          unselectedIconTheme:
              const IconThemeData(color: AppColors.textSecondary, size: 26),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1,
          ),
          unselectedLabelTextStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 1,
          ),
          destinations: [
            NavigationRailDestination(
                icon: Icon(kAppNavItems[0].icon),
                label: Text(LocaleManager.strings.navHome)),
            NavigationRailDestination(
                icon: Icon(kAppNavItems[1].icon),
                label: Text(LocaleManager.strings.navRoutines)),
            NavigationRailDestination(
                icon: Icon(kAppNavItems[2].icon),
                label: Text(LocaleManager.strings.navProgress)),
            NavigationRailDestination(
                icon: Icon(kAppNavItems[3].icon),
                label: Text(LocaleManager.strings.navSettings)),
          ],
        ),
        const VerticalDivider(width: 1, thickness: 1, color: AppColors.border), // Separador visual
        Expanded(child: _buildBody(wide: true)), // Contenido ocupa el resto del ancho
      ],
    );
  }

  /// Layout móvil: solo el contenido, a pantalla completa.
  Widget _buildNarrowLayout() => _buildBody(wide: false);

  /// Decide qué widget mostrar según el tab activo y el estado de carga.
  Widget _buildBody({required bool wide}) {
    switch (_currentIndex) {
      case 1:
        return const RoutinesListScreen(); // Tab Rutinas → lista de rutinas
      case 2:
        return const ProgressScreen();     // Tab Progreso → calendario y estadísticas
      case 3:
        // Tab Ajustes → callback para reconstruir el widget al cambiar el idioma
        return SettingsScreen(onLocaleChanged: () => setState(() {}));
      case 0:
        // Tab Home → contenido condicional según estado de carga y RoutineStatus
        if (_isLoading) {
          return LoadingWidget(message: LocaleManager.strings.loading); // Spinner
        }
        if (_errorMessage != null) {
          return ErrorMessageWidget(
            message: _errorMessage!,
            onRetry: _loadData, // Botón para reintentar la carga
          );
        }
        if (_dashboard == null) return const SizedBox.shrink(); // Estado inicial antes de cargar

        // Tres estados posibles del dashboard
        switch (_dashboard!.status) {
          case RoutineStatus.active:
            return _buildDashboard(wide: wide); // Dashboard completo con progreso
          case RoutineStatus.newAssignment:
            return _buildWithNewAssignment(wide: wide); // Tarjeta de nueva asignación del fisio
          case RoutineStatus.none:
            return _buildEmptyState(wide: wide); // Pantalla vacía (sin rutina asignada)
        }
      default:
        // Fallback para tabs sin pantalla implementada
        return _buildPlaceholder(kAppNavItems[_currentIndex].label);
    }
  }

  // ── Estado: ACTIVE — Dashboard con progreso ───────────────────────────────

  /// Dashboard principal: saludo + anillo de progreso + tarjeta de hoy + próxima sesión + recordatorio.
  Widget _buildDashboard({required bool wide}) {
    final dash = _dashboard!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: wide ? 36 : 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 480 : double.infinity),
          child: Column(
            children: [
              _buildDashGreeting(wide),          // "¡Hola, MARÍA!"
              SizedBox(height: wide ? 40 : 32),
              _buildProgressRing(dash, wide),    // Anillo con % semanal
              SizedBox(height: wide ? 40 : 28),
              _buildTodayRoutineCard(),           // Tarjeta de la rutina de hoy
              if (dash.nextSession != null) ...[  // Solo si hay próxima sesión con el fisio
                const SizedBox(height: 16),
                _buildNextSessionCard(dash.nextSession!, wide),
              ],
              if (dash.reminder != null) ...[    // Solo si el fisio dejó un recordatorio
                const SizedBox(height: 16),
                _buildReminderCard(dash.reminder!),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Texto de saludo personalizado con el nombre del usuario.
  Widget _buildDashGreeting(bool wide) {
    return Text(
      LocaleManager.strings.greeting(_displayName), // "¡Hola, MARÍA!"
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: wide ? 36 : 30, // Más grande en tablet
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  /// Anillo de progreso semanal con el porcentaje centrado.
  Widget _buildProgressRing(DashboardModel dash, bool wide) {
    final double size = wide ? 220 : 190;    // Tamaño del anillo según dispositivo
    final double fontSize = wide ? 52 : 44; // Tamaño del número central

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center, // Superpone el texto sobre el anillo
        children: [
          CountdownRingWidget(
              progress: dash.weeklyProgress, // 0.0–1.0
              size: size,
              strokeWidth: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(dash.weeklyProgress * 100).round()}%', // Porcentaje redondeado
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  height: 1, // Sin espacio extra sobre/bajo el texto
                ),
              ),
              const SizedBox(height: 6),
              Text(
                LocaleManager.strings.treatmentCompleted, // "TRATAMIENTO\nCOMPLETADO"
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tarjeta de la rutina programada para hoy.
  /// Si no hay rutina hoy → devuelve SizedBox.shrink() (sin espacio).
  Widget _buildTodayRoutineCard() {
    final routine = _todayRoutine;
    if (routine == null) return const SizedBox.shrink(); // Sin rutina hoy → no renderiza nada

    final isCompleted = routine.status == rm.RoutineStatus.completed; // Ya completada hoy?

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        // Verde si completada, azul si pendiente
        border: Border.all(
          color: isCompleted
              ? Colors.greenAccent.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.greenAccent.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.fitness_center_rounded,
              color: isCompleted ? Colors.greenAccent : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted
                      ? LocaleManager.strings.sessionCompleted // "SESIÓN COMPLETADA"
                      : LocaleManager.strings.todaySession,    // "SESIÓN DE HOY"
                  style: TextStyle(
                    color: isCompleted ? Colors.greenAccent : AppColors.primary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  routine.title.toUpperCase(), // "FORTALECIMIENTO ESCAPULAR"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${routine.minutes} MIN · ${routine.difficulty}', // "20 MIN · MEDIA"
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Solo se muestra el botón "INICIAR" si la sesión no está completada
          if (!isCompleted)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RoutineDetailScreen(routineId: routine.id), // Navega al detalle
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  LocaleManager.strings.startSession, // "INICIAR"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Tarjeta de la próxima sesión programada con el fisioterapeuta.
  Widget _buildNextSessionCard(NextSessionModel session, bool wide) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleManager.strings.nextSession, // "PRÓXIMA SESIÓN"
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${session.type} · ${session.durationMinutes} MIN', // "FISIOTERAPIA · 15 MIN"
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_repeat_rounded,
                      color: AppColors.primary, size: 20), // Icono de cita recurrente
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dos mini-tarjetas: fecha y hora
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: _DateTimeCard(
                      label: LocaleManager.strings.date, value: session.date), // "20 OCT"
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateTimeCard(
                      label: LocaleManager.strings.hour, value: session.time), // "10:30 AM"
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Botón "VER DETALLES" que navega al tab de Rutinas
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: _buildVerDetallesButton(),
          ),
        ],
      ),
    );
  }

  /// Botón de degradado que salta al tab de Rutinas (índice 1).
  Widget _buildVerDetallesButton() {
    return AppGradientButton(
      label: LocaleManager.strings.viewDetails, // "VER DETALLES"
      onPressed: () => setState(() => _currentIndex = 1), // Cambia al tab de Rutinas
      height: 48,
      borderRadius: 12,
      textColor: Colors.black,
    );
  }

  /// Tarjeta con el recordatorio del fisioterapeuta.
  Widget _buildReminderCard(String reminder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleManager.strings.reminder, // "RECORDATORIO"
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reminder, // Texto del recordatorio del fisio
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5, // Interlineado para mejor legibilidad
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Estado: NEW ASSIGNMENT — Tarjeta del fisio ────────────────────────────

  /// Pantalla de bienvenida cuando el fisio acaba de asignar una nueva rutina.
  Widget _buildWithNewAssignment({required bool wide}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 520 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAssignmentGreeting(wide), // Saludo + subtítulo
              const SizedBox(height: 32),
              _buildAssignmentCard(),          // Tarjeta interactiva con la nueva rutina
            ],
          ),
        ),
      ),
    );
  }

  /// Saludo y subtítulo para el estado de nueva asignación.
  Widget _buildAssignmentGreeting(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.greeting(_displayName),
          style: TextStyle(
            color: Colors.white,
            fontSize: wide ? 36 : 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleManager.strings.physiotherapyStartsToday, // "TU FISIOTERAPIA EMPIEZA HOY"
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Tarjeta de la nueva asignación del fisio.
  /// Al pulsarla navega a SchedulePlanningScreen para configurar los días.
  Widget _buildAssignmentCard() {
    final title = _dashboard!.assignmentTitle ?? LocaleManager.strings.newAssignment;
    final physio = _user?.physioName ?? _dashboard!.physioName ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SchedulePlanningScreen()), // Configurar horario
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Degradado oscuro de izquierda a derecha
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2A4A), AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildNewAssignmentBadge(), // Etiqueta "NUEVA ASIGNACIÓN"
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleManager.strings.currentAssignment, // "ASIGNACIÓN ACTUAL"
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title, // Título de la rutina asignada
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1), // Separador entre título y fisio
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          physio, // Nombre del fisioterapeuta
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          LocaleManager.strings.seniorPhysiotherapist, // "FISIOTERAPEUTA SENIOR"
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge de etiqueta "NUEVA ASIGNACIÓN" con borde verde semitransparente.
  Widget _buildNewAssignmentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.5), // Borde verde semitransparente
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        LocaleManager.strings.newAssignment, // "NUEVA ASIGNACIÓN"
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Estado: NONE — Pantalla vacía ─────────────────────────────────────────

  /// Pantalla vacía cuando el usuario no tiene ninguna rutina asignada todavía.
  Widget _buildEmptyState({required bool wide}) {
    // Tamaños adaptativos para tablet vs móvil
    final double greetingSize = wide ? 36 : 26;
    final double subtitleSize = wide ? 16 : 13;
    final double circleSize = wide ? 140 : 110;
    final double iconSize = wide ? 60 : 46;
    final double emptyTextSize = wide ? 18 : 15;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocaleManager.strings.greeting(_displayName),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: greetingSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              LocaleManager.strings.aboutToBegin, // "TU TRATAMIENTO ESTÁ A PUNTO DE COMENZAR"
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: subtitleSize,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: wide ? 56 : 40),
            // Círculo con icono de sobre — representa "esperando asignación del fisio"
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Center(
                child: Icon(Icons.mail_outline_rounded,
                    color: AppColors.textSecondary, size: iconSize),
              ),
            ),
            SizedBox(height: wide ? 36 : 28),
            Text(
              LocaleManager.strings.noNotificationsYet, // "No tienes notificaciones todavía"
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: emptyTextSize,
                height: 1.6,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder para tabs sin pantalla implementada.
  Widget _buildPlaceholder(String label) {
    return Center(
      child: Text(
        label, // Nombre del tab como texto provisional
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 22,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Config AppBar ─────────────────────────────────────────────────────────────

/// Configuración del AppBar para cada tab.
/// Clase privada (`_`) — solo se usa dentro de este archivo.
class _AppBarConfig {
  final IconData icon;   // Icono del tab en el AppBar
  final String label;    // Nombre del tab
  final Color color;     // Color del icono y texto (primario en Home, secundario en el resto)
  final bool showBell;   // true → muestra nombre de usuario y campana de notificaciones

  const _AppBarConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.showBell,
  });
}

// ── Widgets locales ───────────────────────────────────────────────────────────

/// Tarjeta pequeña que muestra una etiqueta y un valor grande.
/// Se usa en pares para mostrar la fecha y la hora de la próxima sesión.
class _DateTimeCard extends StatelessWidget {
  final String label; // Etiqueta superior en gris ("FECHA", "HORA")
  final String value; // Valor principal en blanco grande ("20 OCT", "10:30 AM")

  const _DateTimeCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value, // Valor grande y llamativo
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
