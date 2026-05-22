import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_message_widget.dart';
import '../../../routines/models/routine_model.dart' as rm;
import '../../../routines/presentation/screens/routine_detail_screen.dart';
import '../../../routines/presentation/screens/routines_list_screen.dart';
import '../../../routines/services/routine_service.dart';
import '../../../../shared/widgets/countdown_ring_widget.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../../users/models/user_model.dart';
import '../../../users/services/user_service.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../shared/widgets/app_button_widget.dart';
import 'notifications_screen.dart';
import 'progress_screen.dart';
import 'schedule_planning_screen.dart';
import 'settings_screen.dart';

class WelcomeIniScreen extends StatefulWidget {
  final String userName;

  const WelcomeIniScreen({super.key, required this.userName});

  @override
  State<WelcomeIniScreen> createState() => _WelcomeIniScreenState();
}

class _WelcomeIniScreenState extends State<WelcomeIniScreen> {
  int _currentIndex = 0;

  // ── Estado ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  DashboardModel? _dashboard;
  UserModel? _user;
  rm.RoutineModel? _todayRoutine;

  final DashboardService _dashboardService = DashboardService();
  final UserService _userService = UserService();
  final RoutineService _routineService = RoutineService();

  String get _displayName => _user?.userName ?? widget.userName;

  // ── AppBar configs por tab ────────────────────────────────────────────────
  List<_AppBarConfig> get _appBarConfigs => [
        _AppBarConfig(
            icon: Icons.bolt,
            label: LocaleManager.strings.appName,
            color: AppColors.primary,
            showBell: true),
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
    _loadData();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dashFuture = _dashboardService.getDashboardData();
      final userFuture = _userService.getUser();
      final routinesFuture = _routineService.getWeeklyRoutines();
      final dash = await dashFuture;
      final user = await userFuture;
      final routines = await routinesFuture;
      final todayWeekday = DateTime.now().weekday;
      setState(() {
        _dashboard = dash;
        _user = user;
        _todayRoutine = routines.cast<rm.RoutineModel?>().firstWhere(
              (r) => r!.weekday == todayWeekday,
              orElse: () => null,
            );
      });
    } catch (_) {
      setState(() => _errorMessage = LocaleManager.strings.errorLoadingInfo);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      bottomNavigationBar: isWide
          ? null
          : AppBottomNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    final cfg = _appBarConfigs[_currentIndex];
    final isHome = _currentIndex == 0;
    final hasUnread = _dashboard?.hasUnreadNotification ?? false;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: !isHome,
      titleSpacing: isHome ? 16 : null,
      title: Row(
        mainAxisSize: isHome ? MainAxisSize.max : MainAxisSize.min,
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
        if (cfg.showBell) ...[
          Text(
            _displayName,
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
              isLabelVisible: hasUnread,
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.textSecondary, size: 28),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Layout responsive ─────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Row(
      children: [
        NavigationRail(
          backgroundColor: AppColors.surface,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelType: NavigationRailLabelType.all,
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
        const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
        Expanded(child: _buildBody(wide: true)),
      ],
    );
  }

  Widget _buildNarrowLayout() => _buildBody(wide: false);

  Widget _buildBody({required bool wide}) {
    switch (_currentIndex) {
      case 1:
        return const RoutinesListScreen();
      case 2:
        return const ProgressScreen();
      case 3:
        return SettingsScreen(onLocaleChanged: () => setState(() {}));
      case 0:
        if (_isLoading) {
          return LoadingWidget(message: LocaleManager.strings.loading);
        }
        if (_errorMessage != null) {
          return ErrorMessageWidget(
            message: _errorMessage!,
            onRetry: _loadData,
          );
        }
        if (_dashboard == null) return const SizedBox.shrink();

        switch (_dashboard!.status) {
          case RoutineStatus.active:
            return _buildDashboard(wide: wide);
          case RoutineStatus.newAssignment:
            return _buildWithNewAssignment(wide: wide);
          case RoutineStatus.none:
            return _buildEmptyState(wide: wide);
        }
      default:
        return _buildPlaceholder(kAppNavItems[_currentIndex].label);
    }
  }

  // ── Estado: ACTIVE — Dashboard con progreso ───────────────────────────────

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
              _buildDashGreeting(wide),
              SizedBox(height: wide ? 40 : 32),
              _buildProgressRing(dash, wide),
              SizedBox(height: wide ? 40 : 28),
              _buildTodayRoutineCard(),
              if (dash.nextSession != null) ...[
                const SizedBox(height: 16),
                _buildNextSessionCard(dash.nextSession!, wide),
              ],
              if (dash.reminder != null) ...[
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

  Widget _buildDashGreeting(bool wide) {
    return Text(
      LocaleManager.strings.greeting(_displayName),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: wide ? 36 : 30,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildProgressRing(DashboardModel dash, bool wide) {
    final double size = wide ? 220 : 190;
    final double fontSize = wide ? 52 : 44;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CountdownRingWidget(
              progress: dash.weeklyProgress, size: size, strokeWidth: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(dash.weeklyProgress * 100).round()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                LocaleManager.strings.treatmentCompleted,
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

  Widget _buildTodayRoutineCard() {
    final routine = _todayRoutine;
    if (routine == null) return const SizedBox.shrink();

    final isCompleted = routine.status == rm.RoutineStatus.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
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
                      ? LocaleManager.strings.sessionCompleted
                      : LocaleManager.strings.todaySession,
                  style: TextStyle(
                    color: isCompleted ? Colors.greenAccent : AppColors.primary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  routine.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${routine.minutes} MIN · ${routine.difficulty}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RoutineDetailScreen(routineId: routine.id),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  LocaleManager.strings.startSession,
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
                        LocaleManager.strings.nextSession,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${session.type} · ${session.durationMinutes} MIN',
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
                      color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: _DateTimeCard(
                      label: LocaleManager.strings.date, value: session.date),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateTimeCard(
                      label: LocaleManager.strings.hour, value: session.time),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: _buildVerDetallesButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerDetallesButton() {
    return AppGradientButton(
      label: LocaleManager.strings.viewDetails,
      onPressed: () => setState(() => _currentIndex = 1),
      height: 48,
      borderRadius: 12,
      textColor: Colors.black,
    );
  }

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
                  LocaleManager.strings.reminder,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reminder,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
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
              _buildAssignmentGreeting(wide),
              const SizedBox(height: 32),
              _buildAssignmentCard(),
            ],
          ),
        ),
      ),
    );
  }

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
          LocaleManager.strings.physiotherapyStartsToday,
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

  Widget _buildAssignmentCard() {
    final title = _dashboard!.assignmentTitle ?? 'Nueva asignación';
    final physio = _user?.physioName ?? _dashboard!.physioName ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SchedulePlanningScreen()),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
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
              child: _buildNewAssignmentBadge(),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleManager.strings.currentAssignment,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
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
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          physio,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          LocaleManager.strings.seniorPhysiotherapist,
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

  Widget _buildNewAssignmentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        LocaleManager.strings.newAssignment,
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

  Widget _buildEmptyState({required bool wide}) {
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
              LocaleManager.strings.aboutToBegin,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: subtitleSize,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: wide ? 56 : 40),
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
              LocaleManager.strings.noNotificationsYet,
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

  Widget _buildPlaceholder(String label) {
    return Center(
      child: Text(
        label,
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

class _AppBarConfig {
  final IconData icon;
  final String label;
  final Color color;
  final bool showBell;

  const _AppBarConfig({
    required this.icon,
    required this.label,
    required this.color,
    required this.showBell,
  });
}

// ── Widgets locales ───────────────────────────────────────────────────────────

class _DateTimeCard extends StatelessWidget {
  final String label;
  final String value;

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
            value,
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
