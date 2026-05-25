import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart'; // Para las etiquetas localizadas de los días
import '../../core/theme/app_colors.dart';

/// Selector de días de la semana con soporte para selección múltiple o única.
/// Cada día se muestra como un círculo animado que cambia de color al seleccionarlo.
/// Se usa en SchedulePlanningScreen y en el test de configuración de Settings.
class WeekDaySelector extends StatefulWidget {
  /// Conjunto de índices seleccionados al crear el widget (0=Lun, 6=Dom).
  final Set<int> initialSelected;

  /// true → puede haber varios días seleccionados simultáneamente.
  /// false → solo puede estar seleccionado un día a la vez.
  final bool multiSelect;

  /// Callback llamado cada vez que cambia la selección. Recibe el Set actualizado.
  final ValueChanged<Set<int>>? onChanged;

  const WeekDaySelector({
    super.key,
    this.initialSelected = const {}, // Por defecto ningún día seleccionado
    this.multiSelect = false,
    this.onChanged,
  });

  @override
  State<WeekDaySelector> createState() => _WeekDaySelectorState();
}

class _WeekDaySelectorState extends State<WeekDaySelector> {
  late Set<int> _selected; // Estado local — copia del initialSelected

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected); // Copia para no modificar el original
  }

  @override
  // Llamado por Flutter cuando el widget padre se reconstruye con nuevos parámetros.
  // Sin esto, si el padre recarga datos, el selector no se actualizaría.
  void didUpdateWidget(WeekDaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_setsEqual(oldWidget.initialSelected, widget.initialSelected)) {
      // Los días cambiaron desde fuera (ej. se cargaron del backend) → sincronizamos
      setState(() => _selected = Set.from(widget.initialSelected));
    }
  }

  /// Comprueba si dos Sets tienen exactamente los mismos elementos.
  /// containsAll verifica que todos los elementos de b están en a; la comparación
  /// de longitud garantiza que no haya elementos extra en a.
  bool _setsEqual(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  /// Maneja el toque sobre un día.
  void _toggle(int index) {
    setState(() {
      if (widget.multiSelect) {
        // Modo multiselección: deselecciona si ya estaba y hay más de uno seleccionado
        // (siempre debe quedar al menos un día seleccionado)
        if (_selected.contains(index) && _selected.length > 1) {
          _selected.remove(index); // Quita el día si había más de uno
        } else if (!_selected.contains(index)) {
          _selected.add(index); // Añade el día si no estaba
        }
        // Si _selected.length == 1 y se pulsa el único día → no hace nada (mínimo 1)
      } else {
        // Modo selección única: sustituye cualquier selección anterior
        if (!_selected.contains(index)) _selected = {index};
      }
    });
    // Notifica al padre con una copia del Set (inmutabilidad)
    widget.onChanged?.call(Set.from(_selected)); // ?. evita llamar si onChanged == null
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye los 7 círculos uniformemente
      children: List.generate(LocaleManager.strings.weekDayMedium.length, (i) {
        // Genera un círculo por cada día de la semana (índice 0=Lun, …, 6=Dom)
        final isSelected = _selected.contains(i);
        return GestureDetector(
          onTap: () => _toggle(i),
          child: AnimatedContainer( // Anima el cambio de color suavemente
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface, // Azul si activo, oscuro si no
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border, // Borde resaltado si activo
              ),
            ),
            child: Center(
              child: Text(
                LocaleManager.strings.weekDayMedium[i], // "LUN", "MAR", etc.
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary, // Blanco si activo
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
