import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_message_widget.dart';
import '../../models/routine_detail_model.dart';
import '../../services/routine_service.dart';
import '../../services/workout_session_service.dart';
import '../../widgets/exercise_card_widget.dart';
import 'workout_preparation_screen.dart';

const Color _kAccent = Color(0xFF6B5CF6); // violeta de sesión activa

class RoutineDetailScreen extends StatefulWidget {
  /// ID de la rutina a cargar. Se usará para la llamada al API.
  final String routineId;

  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  RoutineDetailModel? _detail;

  final RoutineService _routineService = RoutineService();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _routineService.getRoutineDetail(widget.routineId);
      setState(() => _detail = result);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudo cargar el detalle de la sesión');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Acción principal ──────────────────────────────────────────────────────

  Future<void> _onStartSession() async {
    if (_detail == null || _detail!.exercises.isEmpty) return;

    WorkoutSessionService.markStart();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutPreparationScreen(
          exercises: _detail!.exercises,
          currentIndex: 0,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) Navigator.of(context).pop();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final sessionLabel = _detail?.sessionId ?? '...';

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: _kAccent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'SESSION: $sessionLabel',
          style: const TextStyle(
            color: _kAccent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _kAccent.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) return const LoadingWidget(message: 'Cargando sesión...');

    if (_errorMessage != null) {
      return ErrorMessageWidget(message: _errorMessage!, onRetry: _loadDetail);
    }

    if (_detail == null) return const SizedBox.shrink();

    final isWide = MediaQuery.of(context).size.width >= 600;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 680.0 : double.infinity),
              child: _buildScrollContent(_detail!),
            ),
          ),
        ),
        _buildStartButton(context),
      ],
    );
  }

  Widget _buildScrollContent(RoutineDetailModel detail) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        _buildHeader(detail),
        const SizedBox(height: 20),
        _buildDescriptionCard(detail),
        const SizedBox(height: 28),
        _buildExerciseListHeader(detail),
        const SizedBox(height: 14),
        ...detail.exercises.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExerciseCardWidget(
              exercise: e,
              onPlayTap: () {
                // TODO: reproducir vídeo o instrucciones del ejercicio
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(RoutineDetailModel detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE_PROTOCOL',
          style: TextStyle(
            color: _kAccent.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'DETALLES DE SESIÓN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(RoutineDetailModel detail) {
    return Container(
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
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SYS_LOG: MISSION_OBJECTIVE',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  detail.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.tune_rounded,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseListHeader(RoutineDetailModel detail) {
    final count = detail.exercises.length.toString().padLeft(2, '0');
    return Row(
      children: [
        const Text(
          'EJE_LISTA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '// $count ITEMS',
          style: TextStyle(
            color: _kAccent.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: AppColors.background,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _detail != null ? _onStartSession : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: const Text(
            'INICIAR',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
