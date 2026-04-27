import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_message_widget.dart';
import '../../../routines/presentation/screens/routines_list_screen.dart';
import '../../../routines/widgets/countdown_ring_widget.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import 'notifications_screen.dart';
import 'schedule_planning_screen.dart';

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

  final DashboardService _dashboardService = DashboardService();

  // ── AppBar configs por tab ────────────────────────────────────────────────
  static const List<_AppBarConfig> _appBarConfigs = [
    _AppBarConfig(icon: Icons.bolt, label: 'RETRAINEX', color: AppColors.primary, showBell: true),
    _AppBarConfig(icon: Icons.route_rounded, label: 'MIS RUTINAS', color: AppColors.secondary, showBell: false),
    _AppBarConfig(icon: Icons.trending_up_rounded, label: 'MI PROGRESO', color: AppColors.secondary, showBell: false),
    _AppBarConfig(icon: Icons.settings_rounded, label: 'AJUSTES', color: AppColors.textSecondary, showBell: false),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _dashboardService.getDashboard();
      setState(() => _dashboard = result);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo cargar la información');
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
      actions: cfg.showBell
          ? [
              Text(
                widget.userName,
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
              const SizedBox(width: 4),
            ]
          : null,
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
          selectedIconTheme: const IconThemeData(color: AppColors.primary, size: 28),
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
          destinations: kAppNavItems
              .map((n) => NavigationRailDestination(
                    icon: Icon(n.icon),
                    label: Text(n.label),
                  ))
              .toList(),
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
      case 0:
        if (_isLoading) {
          return const LoadingWidget(message: 'Cargando...');
        }
        if (_errorMessage != null) {
          return ErrorMessageWidget(
            message: _errorMessage!,
            onRetry: _loadDashboard,
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
              if (dash.nextSession != null)
                _buildNextSessionCard(dash.nextSession!, wide),
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
      '¡HOLA, ${widget.userName}!',
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
    final double progress = dash.progressPercentage / 100;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CountdownRingWidget(progress: progress, size: size, strokeWidth: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${dash.progressPercentage}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'TRATAMIENTO\nCOMPLETADO',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      const Text(
                        'PRÓXIMA SESIÓN',
                        style: TextStyle(
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
                  child: _DateTimeCard(label: 'FECHA', value: session.date),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateTimeCard(label: 'HORA', value: session.time),
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
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: () => setState(() => _currentIndex = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'VER DETALLES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
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
                const Text(
                  'RECORDATORIO',
                  style: TextStyle(
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
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            child: Icon(Icons.person_rounded,
                color: AppColors.textSecondary, size: 20),
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
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: wide ? 36 : 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            children: [
              const TextSpan(
                  text: '¡HOLA, ', style: TextStyle(color: Colors.white)),
              TextSpan(
                text: '${widget.userName}!',
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'TU FISIOTERAPIA COMIENZA HOY',
          style: TextStyle(
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
    final physio = _dashboard!.physioName ?? 'Dr. Pérez';

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
                  const Text(
                    'ASIGNACIÓN ACTUAL',
                    style: TextStyle(
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
                        const Text(
                          'FISIOTERAPEUTA SENIOR',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
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
      child: const Text(
        'NUEVA ASIGNACIÓN',
        style: TextStyle(
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
              '¡HOLA, ${widget.userName}!',
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
              'ESTÁS A PUNTO DE COMENZAR ESTA AVENTURA',
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
              'NO HAS RECIBIDO\nNINGUNA NOTIFICACIÓN\nDE MOMENTO',
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
