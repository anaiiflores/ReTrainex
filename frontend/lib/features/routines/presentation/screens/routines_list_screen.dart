import 'package:flutter/material.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_message_widget.dart';
import '../../models/routine_model.dart';
import '../../services/routine_service.dart';
import '../../widgets/progress_card_widget.dart';
import '../../widgets/routine_card_widget.dart';
import 'routine_detail_screen.dart';

class RoutinesListScreen extends StatefulWidget {
  const RoutinesListScreen({super.key});

  @override
  State<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends State<RoutinesListScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  List<RoutineModel> _routines = [];

  final RoutineService _routineService = RoutineService();

  // ── Computed ──────────────────────────────────────────────────────────────
  int get _completedCount =>
      _routines.where((r) => r.status == RoutineStatus.completed).length;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> _loadRoutines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _routineService.getWeeklyRoutines();
      setState(() => _routines = result);
    } catch (_) {
      setState(() => _errorMessage = 'No se pudieron cargar las rutinas');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Navegación ────────────────────────────────────────────────────────────

  void _openRoutineDetail(RoutineModel routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(routineId: routine.id),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando rutinas...');
    }

    if (_errorMessage != null) {
      return ErrorMessageWidget(
        message: _errorMessage!,
        onRetry: _loadRoutines,
      );
    }

    final isWide = MediaQuery.of(context).size.width >= 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWide ? 640.0 : double.infinity),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            ProgressCardWidget(
              completed: _completedCount,
              total: _routines.length,
            ),
            const SizedBox(height: 20),
            ..._routines.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: RoutineCardWidget(
                  routine: r,
                  onStartTap: r.status == RoutineStatus.today
                      ? () => _openRoutineDetail(r)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
