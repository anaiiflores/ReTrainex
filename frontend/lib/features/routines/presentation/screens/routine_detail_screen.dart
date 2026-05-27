import 'package:flutter/material.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_widget.dart';    // Barra de navegación inferior
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_message_widget.dart';
import '../../models/routine_detail_model.dart';                   // RoutineDetailModel
import '../../../exercises/models/exercise_detail_model.dart';      // ExerciseModel
import '../../services/routine_service.dart';
import '../../services/workout_session_service.dart';
import '../../../exercises/services/exercise_service.dart';        // Para cargar el detalle de un ejercicio al pulsar play
import '../../widgets/exercise_card_widget.dart';
import 'workout_preparation_screen.dart';                          // Primera pantalla del flujo de sesión
import 'session_paused.dart';                                      // Pantalla de ejercicio en pausa/preview

/// Color de acento violeta para el estilo técnico/sesión activa.
/// Se usa en el AppBar, la línea separadora y los textos de identificador.
const Color _kAccent = Color(0xFF6B5CF6);

/// Pantalla de detalle de una rutina.
/// Muestra la descripción, la lista de ejercicios y el botón de inicio de sesión.
/// `StatefulWidget` porque carga el detalle de forma asíncrona.
class RoutineDetailScreen extends StatefulWidget {
  /// ID de la rutina a cargar. Viene de RoutinesListScreen o WelcomeIniScreen.
  final String routineId;

  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  RoutineDetailModel? _detail; // Detalle completo (null hasta que carga o si hay error)

  final RoutineService _routineService = RoutineService();

  @override
  void initState() {
    super.initState();
    _loadDetail(); // Inicia la carga al montar la pantalla
  }

  // ── Carga de datos ────────────────────────────────────────────────────────

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Pasa el routineId al servicio para que cuando se conecte al backend lo use
      final result = await _routineService.getRoutineDetail(widget.routineId);
      setState(() => _detail = result);
    } catch (_) {
      setState(
          () => _errorMessage = LocaleManager.strings.errorLoadingSession);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Acción: pulsar play en un ejercicio individual ────────────────────────

  /// Carga el detalle del ejercicio y navega a SessionPausedScreen para previsualizar.
  Future<void> _onExerciseTap(
      String exerciseId, List<ExerciseModel> exercises, int index) async {
    final exercise = await ExerciseService().getExerciseDetail(exerciseId);
    if (!mounted) return; // El widget puede haberse desmontado durante el await
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionPausedScreen(
          exercise: exercise,  // Ejercicio seleccionado
          exercises: exercises, // Lista completa de la rutina
          currentIndex: index,  // Posición en la lista
        ),
      ),
    );
  }

  // ── Acción: botón INICIAR SESIÓN ──────────────────────────────────────────

  /// Registra el inicio de la sesión y navega al flujo de workout.
  Future<void> _onStartSession() async {
    if (_detail == null || _detail!.exercises.isEmpty) return; // Sin ejercicios → no inicia

    WorkoutSessionService.markStart(); // Registra el timestamp de inicio para calcular duración

    // Navega a la pantalla de preparación (cuenta atrás antes del primer ejercicio)
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutPreparationScreen(
          exercises: _detail!.exercises, // Pasa la lista completa al flujo de sesión
          currentIndex: 0,               // Empieza desde el primer ejercicio
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
      // Barra inferior con tab 1 (Rutinas) activo; pulsar otro tab cierra la pantalla
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) Navigator.of(context).pop(); // Vuelve atrás si se selecciona otro tab
        },
      ),
    );
  }

  /// AppBar con el identificador técnico de la sesión (violeta).
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final sessionLabel = _detail?.sessionId ?? '...'; // Muestra "..." mientras carga

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      // El título muestra el sessionId en un contenedor con borde violeta
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: _kAccent, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'SESSION: $sessionLabel', // Identificador técnico — no se traduce
          style: const TextStyle(
            color: _kAccent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
      // Línea violeta semitransparente bajo el AppBar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _kAccent.withValues(alpha: 0.3)),
      ),
    );
  }

  /// Cuerpo principal: spinner / error / detalle + botón de inicio.
  Widget _buildBody(BuildContext context) {
    if (_isLoading) return LoadingWidget(message: LocaleManager.strings.loadingSession);

    if (_errorMessage != null) {
      return ErrorMessageWidget(message: _errorMessage!, onRetry: _loadDetail);
    }

    if (_detail == null) return const SizedBox.shrink();

    final isWide = MediaQuery.of(context).size.width >= 600;

    return Column(
      children: [
        // La lista de ejercicios ocupa todo el espacio disponible
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 680.0 : double.infinity),
              child: _buildScrollContent(_detail!),
            ),
          ),
        ),
        // Botón de inicio fijo en la parte inferior
        _buildStartButton(context),
      ],
    );
  }

  /// Contenido scrollable: cabecera, descripción y lista de ejercicios.
  Widget _buildScrollContent(RoutineDetailModel detail) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        _buildHeader(detail),           // "PROTOCOLO ACTIVO" + título
        const SizedBox(height: 20),
        _buildDescriptionCard(detail),  // Descripción del fisio con estilo terminal
        const SizedBox(height: 28),
        _buildExerciseListHeader(detail), // "EJERCICIOS" + contador
        const SizedBox(height: 14),
        // Una ExerciseCardWidget por cada ejercicio de la rutina
        ...detail.exercises.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExerciseCardWidget(
                  exercise: entry.value,
                  // Al pulsar play en un ejercicio → navega a su preview
                  onPlayTap: () => _onExerciseTap(
                    entry.value.id,    // ID del ejercicio pulsado
                    detail.exercises,  // Lista completa para contexto
                    entry.key,         // Índice actual en la lista
                  ),
                ),
              ),
            ),
      ],
    );
  }

  /// Cabecera con la etiqueta "PROTOCOLO ACTIVO" y el título de la pantalla.
  Widget _buildHeader(RoutineDetailModel detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.routineActiveProtocol, // "PROTOCOLO ACTIVO"
          style: TextStyle(
            color: _kAccent.withValues(alpha: 0.8), // Violeta semitransparente
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          LocaleManager.strings.routineDetailTitle, // "TU SESIÓN DE HOY"
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

  /// Tarjeta con la descripción de la sesión, estilizada como un log de sistema.
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
                    // Punto verde pulsante (simulado) — indica sesión activa
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleManager.strings.routineSysLog, // "SYS.LOG"
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
                  detail.description, // Instrucciones del fisioterapeuta
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
          // Icono de ajustes en la esquina derecha — estético, sin acción
          Icon(
            Icons.tune_rounded,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Fila con "EJERCICIOS" y el contador de ejercicios.
  Widget _buildExerciseListHeader(RoutineDetailModel detail) {
    return Row(
      children: [
        Text(
          LocaleManager.strings.routineExerciseList, // "EJERCICIOS"
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          LocaleManager.strings.routineItems(detail.exercises.length), // "04 ITEMS"
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

  /// Botón fijo en la parte inferior para iniciar la sesión completa.
  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: AppColors.background,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          // Deshabilitado mientras carga (_detail == null)
          onPressed: _detail != null ? _onStartSession : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border, // Gris cuando está deshabilitado
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            LocaleManager.strings.startSession, // "INICIAR SESIÓN"
            style: const TextStyle(
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
