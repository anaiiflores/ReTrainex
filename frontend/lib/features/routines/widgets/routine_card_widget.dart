import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/routine_model.dart';

class RoutineCardWidget extends StatelessWidget {
  final RoutineModel routine;

  /// Callback llamado cuando el usuario pulsa INICIAR.
  /// La pantalla padre decide la navegación.
  final VoidCallback? onStartTap;

  const RoutineCardWidget({
    super.key,
    required this.routine,
    this.onStartTap,
  });

  bool get _isToday => routine.status == RoutineStatus.today;
  bool get _isCompleted => routine.status == RoutineStatus.completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isToday ? const Color(0xFF0D1F3C) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isToday ? AppColors.primary : AppColors.border,
          width: _isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          Text(
            routine.title,
            style: TextStyle(
              color: _isCompleted ? AppColors.textSecondary : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag(
                icon: Icons.access_time_rounded,
                label: '${routine.minutes} MIN',
                color: _isToday ? Colors.orange : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              _buildTag(
                icon: Icons.bolt_rounded,
                label: routine.difficulty,
                color: _difficultyColor(routine.difficulty),
              ),
              const Spacer(),
              _buildAction(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final String statusLabel;
    final Color statusColor;

    switch (routine.status) {
      case RoutineStatus.completed:
        statusLabel = 'COMPLETADO';
        statusColor = Colors.greenAccent;
        break;
      case RoutineStatus.today:
        statusLabel = 'HOY';
        statusColor = AppColors.primary;
        break;
      case RoutineStatus.upcoming:
        statusLabel = 'PRÓXIMO';
        statusColor = AppColors.textSecondary;
        break;
    }

    return Row(
      children: [
        Text(
          routine.day,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 6),
        Text('•', style: TextStyle(color: statusColor, fontWeight: FontWeight.w900)),
        const SizedBox(width: 6),
        Text(
          statusLabel,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTag({required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAction() {
    switch (routine.status) {
      case RoutineStatus.completed:
        return Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        );
      case RoutineStatus.today:
        return ElevatedButton(
          onPressed: onStartTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'INICIAR',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 13),
          ),
        );
      case RoutineStatus.upcoming:
        return Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          size: 24,
        );
    }
  }

  Color _difficultyColor(String d) {
    switch (d.toUpperCase()) {
      case 'ALTA':
        return Colors.redAccent;
      case 'MEDIA':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}
