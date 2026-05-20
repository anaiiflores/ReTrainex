import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart';
import '../../core/theme/app_colors.dart';

class WeekDaySelector extends StatefulWidget {
  final Set<int> initialSelected;
  final bool multiSelect;
  final ValueChanged<Set<int>>? onChanged;

  const WeekDaySelector({
    super.key,
    this.initialSelected = const {},
    this.multiSelect = false,
    this.onChanged,
  });

  @override
  State<WeekDaySelector> createState() => _WeekDaySelectorState();
}

class _WeekDaySelectorState extends State<WeekDaySelector> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  void didUpdateWidget(WeekDaySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_setsEqual(oldWidget.initialSelected, widget.initialSelected)) {
      setState(() => _selected = Set.from(widget.initialSelected));
    }
  }

  bool _setsEqual(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  void _toggle(int index) {
    setState(() {
      if (widget.multiSelect) {
        if (_selected.contains(index) && _selected.length > 1) {
          _selected.remove(index);
        } else if (!_selected.contains(index)) {
          _selected.add(index);
        }
      } else {
        if (!_selected.contains(index)) _selected = {index};
      }
    });
    widget.onChanged?.call(Set.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(LocaleManager.strings.weekDayMedium.length, (i) {
        final isSelected = _selected.contains(i);
        return GestureDetector(
          onTap: () => _toggle(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                LocaleManager.strings.weekDayMedium[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
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
