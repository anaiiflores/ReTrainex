import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../shared/widgets/loading_widget.dart';        // Spinner de carga
import '../../../../shared/widgets/error_message_widget.dart'; // Error con retry
import '../../models/routine_model.dart';
import '../../services/routine_service.dart';
import '../../widgets/progress_card_widget.dart'; // Tarjeta de progreso semanal
import '../../widgets/routine_card_widget.dart';  // Tarjeta individual de rutina
import 'routine_detail_screen.dart';              // Destino al pulsar "INICIAR"

/// Pantalla de lista de rutinas semanales (tab 1).
/// Muestra la tarjeta de progreso semanal y una tarjeta por cada rutina de la semana.
/// `StatefulWidget` porque carga datos de forma asíncrona.
class RoutinesListScreen extends StatefulWidget {
  const RoutinesListScreen({super.key});

  @override
  State<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends State<RoutinesListScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  List<RoutineModel> _routines = []; // Lista de rutinas de la semana actual
  RoutineModel? _todaySession;       // La rutina de hoy (null si no hay ninguna)

  final RoutineService _routineService = RoutineService();

  // ── Computed ──────────────────────────────────────────────────────────────
  /// Número de rutinas ya completadas esta semana.
  /// Se calcula dinámicamente desde _routines para que se actualice solo al recargar.
  int get _completedCount =>
      _routines.where((r) => r.status == RoutineStatus.completed).length;

  @override
  void initState() {
    super.initState();
    _loadRoutines(); // Inicia la carga al montar la pantalla
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  /// Carga en paralelo la lista semanal y la sesión de hoy.
  Future<void> _loadRoutines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _routineService.getWeeklyRoutines(); // Lista completa
      final today = await _routineService.getTodaySession();    // Rutina de hoy (puede ser null)
      setState(() {
        _routines = result;
        _todaySession = today;
      });
    } catch (_) {
      setState(() => _errorMessage = LocaleManager.strings.routineListError); // Mensaje de error
    } finally {
      setState(() => _isLoading = false); // Oculta spinner siempre
    }
  }

  // ── Navegación ────────────────────────────────────────────────────────────

  /// Navega a RoutineDetailScreen con el ID de la rutina de hoy.
  void _openTodaySession() {
    if (_todaySession == null) return; // Seguridad: no navegar si no hay sesión de hoy
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(routineId: _todaySession!.id),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Spinner de carga mientras los datos llegan
    if (_isLoading) {
      return LoadingWidget(message: LocaleManager.strings.routineListLoading);
    }

    // Error con botón de reintentar
    if (_errorMessage != null) {
      return ErrorMessageWidget(
        message: _errorMessage!,
        onRetry: _loadRoutines,
      );
    }

    final isWide = MediaQuery.of(context).size.width >= 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isWide ? 640.0 : double.infinity), // Limita ancho en tablet
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // Tarjeta de progreso semanal (barra + mensaje de ánimo)
            ProgressCardWidget(
              completed: _completedCount,
              total: _routines.length, // Total de rutinas planificadas esta semana
            ),
            const SizedBox(height: 20),
            // Una tarjeta por cada rutina de la semana
            ..._routines.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 14), // Separación entre tarjetas
                child: RoutineCardWidget(
                  routine: r,
                  // Solo la rutina de hoy tiene el botón "INICIAR" activo
                  onStartTap: r.id == _todaySession?.id
                      ? _openTodaySession // Navega al detalle de la sesión de hoy
                      : null,            // null → botón deshabilitado o no visible
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
