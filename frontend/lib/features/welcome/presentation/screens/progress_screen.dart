import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/strings/locale_manager.dart';
import '../../models/dashboard_model.dart';      // CalendarSessionModel
import '../../services/dashboard_service.dart';  // getCalendarSessions()

/// Pantalla de progreso (tab 2).
/// Muestra un calendario mensual propio con indicadores de sesiones completadas
/// y una lista de sesiones completadas del mes.
/// `StatefulWidget` porque gestiona el mes visible, el día seleccionado y los datos.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime _focusedMonth = DateTime.now(); // Mes actualmente visible en el calendario
  DateTime? _selectedDay = DateTime.now(); // Día seleccionado (null si no hay ninguno)
  List<CalendarSessionModel> _sessions = []; // Lista completa de sesiones del rango de fechas

  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _loadSessions(); // Carga las sesiones del calendario al montar la pantalla
  }

  /// Carga las sesiones desde el servicio y actualiza el estado si el widget sigue montado.
  Future<void> _loadSessions() async {
    final sessions = await _dashboardService.getCalendarSessions();
    if (mounted) setState(() => _sessions = sessions); // `mounted` evita setState en widget desmontado
  }

  /// Devuelve las sesiones programadas para un día concreto.
  List<CalendarSessionModel> _sessionsForDay(DateTime day) {
    return _sessions.where((s) =>
      s.date.year == day.year &&
      s.date.month == day.month &&
      s.date.day == day.day,
    ).toList();
  }

  /// Devuelve las sesiones completadas del mes visible, opcionalmente excluyendo un día.
  /// Se usa para mostrar la lista de historial sin duplicar el día seleccionado.
  List<CalendarSessionModel> _completedSessionsForMonth({DateTime? exclude}) {
    return _sessions
        .where((s) {
          final d = DateTime(s.date.year, s.date.month, s.date.day); // Normaliza a medianoche
          if (!s.completed) return false;                              // Solo completadas
          if (s.date.year != _focusedMonth.year) return false;        // Solo del año actual
          if (s.date.month != _focusedMonth.month) return false;      // Solo del mes visible
          if (exclude != null &&
              d == DateTime(exclude.year, exclude.month, exclude.day)) {
            return false; // Excluye el día seleccionado (ya se muestra en la tarjeta superior)
          }
          return true;
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Ordena de más reciente a más antigua
  }

  /// Retrocede al mes anterior.
  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      // Dart maneja el desbordamiento: mes 0 → diciembre del año anterior
    });
  }

  /// Avanza al mes siguiente.
  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Align(
        alignment: Alignment.topCenter, // Ancla el contenido arriba para que no quede centrado verticalmente
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420), // Ancho máximo para legibilidad
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(),
              const SizedBox(height: 16),
              if (_selectedDay != null) ...[
                _buildSelectedDayCard(_selectedDay!), // Tarjeta del día seleccionado
                const SizedBox(height: 10),
              ],
              _buildCompletedSessionsList(), // Lista del historial del mes
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el bloque completo del calendario (cabecera de mes + días).
  Widget _buildCalendar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cabecera con nombre del mes y flechas de navegación
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: _buildMonthHeader(),
        ),
        const SizedBox(height: 8),
        // Grid de días con etiquetas de días de la semana
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWeekDayLabels(), // "L M X J V S D"
              const SizedBox(height: 4),
              _buildDaysGrid(),     // Celdas de cada día del mes
            ],
          ),
        ),
      ],
    );
  }

  /// Delega la construcción de la cabecera al widget privado `_MonthHeader`.
  Widget _buildMonthHeader() {
    return _MonthHeader(
      focusedMonth: _focusedMonth,
      onPrevious: _previousMonth,
      onNext: _nextMonth,
    );
  }

  /// Fila con las etiquetas de los días de la semana ("L", "M", …, "D").
  Widget _buildWeekDayLabels() {
    final labels = LocaleManager.strings.weekDayShort; // ["L","M","X","J","V","S","D"]
    return Row(
      children: labels
          .map((l) => Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  /// Grid de celdas del calendario. Siempre muestra 5 filas × 7 columnas = 35 celdas.
  Widget _buildDaysGrid() {
    const totalCells = 5 * 7; // 35 celdas fijas independientemente del mes

    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // Calcula cuántos días tiene el mes: día 0 del mes siguiente = último día del actual
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // weekday: 1=Lun, 7=Dom → offset 0 si empieza en Lunes, 6 si empieza en Domingo
    final startOffset = firstDay.weekday - 1;
    final today = DateTime.now();

    final cells = <Widget>[];

    for (int i = 0; i < totalCells; i++) {
      final day = i - startOffset + 1; // Número de día del mes (puede ser ≤0 o >daysInMonth)
      if (i < startOffset || day > daysInMonth) {
        // Celda fuera del mes actual → espacio vacío invisible
        cells.add(const SizedBox.shrink());
      } else {
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        // Compara con hoy sin componente horaria
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final sel = _selectedDay;
        // Compara con el día seleccionado
        final isSelected = sel != null &&
            sel.year == date.year &&
            sel.month == date.month &&
            sel.day == date.day;
        final daySessions = _sessionsForDay(date); // Sesiones de este día
        cells.add(_buildDayCell(date, day, isToday, isSelected, daySessions));
      }
    }

    return GridView.count(
      crossAxisCount: 7,                       // 7 columnas = 7 días de la semana
      shrinkWrap: true,                         // El grid toma solo el espacio necesario
      physics: const NeverScrollableScrollPhysics(), // El scroll lo gestiona el padre
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: cells,
    );
  }

  /// Celda individual de un día del mes.
  Widget _buildDayCell(DateTime date, int day, bool isToday, bool isSelected,
      List<CalendarSessionModel> daySessions) {
    // Determina el color de fondo según el estado del día
    Color bgColor = Colors.transparent;
    Color textColor = Colors.white;
    if (isSelected) {
      bgColor = AppColors.primary;  // Azul sólido para el día seleccionado
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = AppColors.primary.withValues(alpha: 0.2); // Azul translúcido para hoy
      textColor = AppColors.primary;
    }

    final hasCompleted = daySessions.any((s) => s.completed);  // Hay sesión completada
    final hasUpcoming = daySessions.any((s) => !s.completed);  // Hay sesión pendiente

    return GestureDetector(
      onTap: () => setState(() {
        // Si ya estaba seleccionado → deselecciona; si no → lo selecciona
        _selectedDay = isSelected ? null : date;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), // Animación suave al seleccionar
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), // Círculo perfecto
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasCompleted)
              // Si la sesión está completada → muestra tick en lugar del número
              Icon(Icons.check_rounded,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.greenAccent)
            else
              // Si no completada → muestra el número del día
              Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            // Punto verde pequeño debajo del número si hay sesión pendiente (no completada)
            if (!hasCompleted && hasUpcoming)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.secondary, // Blanco si seleccionado
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta con el detalle del día seleccionado en el calendario.
  Widget _buildSelectedDayCard(DateTime day) {
    // Formatea la fecha según el idioma activo
    final monthName = LocaleManager.strings.monthNames[day.month - 1]; // Nombre del mes
    final dateLabel = LocaleManager.current == AppLocale.es
        ? '${day.day} de $monthName de ${day.year}' // "26 de mayo de 2026"
        : '$monthName ${day.day}, ${day.year}';       // "May 26, 2026"
    final daySessions = _sessionsForDay(day);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel.toUpperCase(), // "26 DE MAYO DE 2026"
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          if (daySessions.isEmpty)
            Text(
              LocaleManager.strings.noSessionsScheduled, // "Sin sesiones para este día"
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            )
          else
            // Muestra cada sesión del día seleccionado (sin la fecha, ya aparece arriba)
            ...daySessions.map((s) => _buildSessionCard(s, showDate: false)),
        ],
      ),
    );
  }

  /// Lista de sesiones completadas del mes, excluyendo el día seleccionado.
  Widget _buildCompletedSessionsList() {
    final completed = _completedSessionsForMonth(exclude: _selectedDay);
    if (completed.isEmpty) return const SizedBox.shrink(); // Nada que mostrar → sin espacio
    return Column(
      children: completed.map((s) => _buildSessionCard(s)).toList(),
    );
  }

  /// Tarjeta de una sesión individual con icono de estado (tick o mancuerna), título y metadatos.
  Widget _buildSessionCard(CalendarSessionModel session, {bool showDate = true}) {
    final monthName = LocaleManager.strings.monthNames[session.date.month - 1];
    // Formato de fecha corto según idioma
    final dateLabel = LocaleManager.current == AppLocale.es
        ? '${session.date.day} de $monthName'  // "26 de mayo"
        : '$monthName ${session.date.day}';     // "May 26"

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: session.completed
                  ? Colors.greenAccent.withValues(alpha: 0.12) // Verde tenue si completada
                  : AppColors.primary.withValues(alpha: 0.12), // Azul tenue si pendiente
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              session.completed
                  ? Icons.check_rounded           // Tick para completada
                  : Icons.fitness_center_rounded, // Mancuerna para pendiente
              color: session.completed ? Colors.greenAccent : AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title, // Nombre de la rutina
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  // showDate=true → incluye la fecha; false → solo hora y duración
                  showDate
                      ? '${dateLabel.toUpperCase()}  ·  ${session.time}  ·  ${session.durationMinutes} min'
                      : '${session.time}  ·  ${session.durationMinutes} min',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera del calendario con el nombre del mes y flechas de navegación.
/// Widget privado extraído para mantener `_ProgressScreenState` más limpio.
class _MonthHeader extends StatelessWidget {
  final DateTime focusedMonth; // Mes actualmente visible
  final VoidCallback onPrevious; // Retrocede un mes
  final VoidCallback onNext;     // Avanza un mes

  const _MonthHeader({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // Construye "MAYO 2026" usando el array de nombres del mes del LocaleManager
    final label = '${LocaleManager.strings.monthNames[focusedMonth.month - 1]} ${focusedMonth.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          padding: EdgeInsets.zero,           // Sin padding extra del IconButton
          constraints: const BoxConstraints(), // Sin tamaño mínimo impuesto por Material
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
        Text(
          label.toUpperCase(), // "MAYO 2026"
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }
}
