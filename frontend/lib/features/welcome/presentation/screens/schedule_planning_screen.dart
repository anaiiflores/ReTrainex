import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';            // Paleta de colores
import '../../../../core/strings/locale_manager.dart';      // Textos localizados
import '../../../../shared/widgets/app_button_widget.dart'; // Botón degradado principal
import '../../../../shared/widgets/time_picker_field_widget.dart'; // Campo selector de hora

/// Pantalla de planificación de horario del programa de rehabilitación.
/// Permite al usuario elegir los días de la semana y la hora de sus sesiones.
/// Se accede desde el onboarding o desde la configuración.
/// Al pulsar "EMPEZAR" cierra la pantalla con `Navigator.pop` (sin devolver datos por ahora).
class SchedulePlanningScreen extends StatefulWidget {
  const SchedulePlanningScreen({super.key});

  @override
  State<SchedulePlanningScreen> createState() => _SchedulePlanningScreenState();
}

class _SchedulePlanningScreenState extends State<SchedulePlanningScreen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  /// Conjunto de índices de días seleccionados (0 = lunes, 6 = domingo).
  /// `Set` porque el orden no importa y evita duplicados automáticamente.
  /// Valor inicial: lunes (0), miércoles (2), viernes (4) — pauta típica 3 días/semana.
  final Set<int> _selectedDays = {0, 2, 4};

  /// Hora seleccionada para las sesiones (formato "HH:MM AM/PM").
  String _time = '10:30 AM';

  /// Activa o desactiva un día en el conjunto.
  /// Restricción: al menos un día debe quedar seleccionado siempre.
  void _toggleDay(int index) {
    setState(() {
      if (_selectedDays.contains(index)) {
        // Solo desactiva si quedaría al menos otro día seleccionado
        if (_selectedDays.length > 1) _selectedDays.remove(index);
        // Si es el único día seleccionado, no hace nada (previene dejar cero días)
      } else {
        _selectedDays.add(index); // Activa el día si no estaba seleccionado
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600; // Tablet vs móvil

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context), // AppBar con el nombre de la app en azul
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 24, // Más margen en tablet
            vertical: 28,
          ),
          child: Center(
            child: ConstrainedBox(
              // Limita el ancho en tablet para mejor presentación
              constraints:
                  BoxConstraints(maxWidth: isWide ? 480.0 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(isWide),          // Título grande + subtítulo
                  const SizedBox(height: 32),
                  _buildDaySection(),           // Selector de días de la semana (burbujas)
                  const SizedBox(height: 32),
                  _buildTimeSection(),          // Selector de hora de la sesión
                  const SizedBox(height: 40),
                  _buildStartButton(context),   // Botón degradado "EMPEZAR"
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  /// AppBar simple con el nombre de la app como título y botón de retroceso.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon:
            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
        onPressed: () => Navigator.of(context).pop(), // Vuelve sin guardar
      ),
      centerTitle: true,
      title: Text(
        LocaleManager.strings.appName, // "RETRAINEX" — nombre de la app
        style: const TextStyle(
          color: AppColors.primary, // Azul — branding de la app
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // ── Título ────────────────────────────────────────────────────────────────

  /// Título y subtítulo explicativos de lo que se va a configurar.
  Widget _buildTitle(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.formPlanTitle, // "PLANIFICA TU SEMANA"
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 38 : 32, // Más grande en tablet
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleManager.strings.formPlanSubtitle, // "Elige los días y hora de tus sesiones"
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ── Selección de días ─────────────────────────────────────────────────────

  /// Sección de selección de días de la semana mediante burbujas circulares.
  /// Usa `Wrap` para que las burbujas se reorganicen si no caben en una fila.
  Widget _buildDaySection() {
    final labels = LocaleManager.strings.weekDayMedium; // ["LUN", "MAR", ..., "DOM"]
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.formSelectDays, // "SELECCIONA LOS DÍAS"
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,   // Espacio horizontal entre burbujas
          runSpacing: 10, // Espacio vertical entre filas de burbujas
          children: List.generate(
            labels.length, // Una burbuja por día de la semana
            (i) => _DayBubble(
              label: labels[i],                    // "LUN", "MAR", etc.
              isSelected: _selectedDays.contains(i), // Seleccionada si el índice está en el Set
              onTap: () => _toggleDay(i),          // Activa/desactiva el día
            ),
          ),
        ),
      ],
    );
  }

  // ── Selector de hora ──────────────────────────────────────────────────────

  /// Sección del selector de hora con etiqueta y el campo de hora.
  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleManager.strings.formActivityTime, // "HORA DE ACTIVIDAD"
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        TimePickerField(
          time: _time, // Hora actualmente seleccionada
          // Callback que actualiza la hora cuando el usuario elige una nueva
          onChanged: (value) => setState(() => _time = value),
        ),
      ],
    );
  }

  // ── Botón empezar ─────────────────────────────────────────────────────────

  /// Botón degradado con cohete que confirma la planificación y cierra la pantalla.
  /// Por ahora solo hace `pop` — cuando el backend esté listo guardará los datos primero.
  Widget _buildStartButton(BuildContext context) {
    return AppGradientButton(
      label: LocaleManager.strings.formStart, // "EMPEZAR"
      onPressed: () => Navigator.of(context).pop(), // Cierra la pantalla
      icon: Icons.rocket_launch_rounded, // Cohete — inicio del programa
      height: 58,
      borderRadius: 30, // Borde muy redondeado — estilo pill
    );
  }
}

// ─── Widgets locales ──────────────────────────────────────────────────────────

/// Burbuja circular seleccionable para un día de la semana.
/// Cuando está seleccionada muestra borde y texto en azul; cuando no, en gris.
class _DayBubble extends StatelessWidget {
  final String label;         // Abreviatura del día ("LUN", "MAR", etc.)
  final bool isSelected;      // Si el día está actualmente seleccionado
  final VoidCallback onTap;   // Acción al pulsar (activa/desactiva el día)

  const _DayBubble({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180), // Transición suave al seleccionar
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Forma circular — "día del calendario"
          // Fondo transparente cuando seleccionado (el borde azul es suficiente);
          // fondo oscuro cuando no seleccionado para diferenciarlo del fondo de pantalla.
          color: isSelected ? Colors.transparent : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border, // Azul o gris
            width: isSelected ? 2 : 1, // Borde más grueso cuando seleccionado
          ),
        ),
        alignment: Alignment.center, // Centra el texto en la burbuja
        child: Text(
          label, // "LUN", "MAR", etc.
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary, // Azul o gris
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
