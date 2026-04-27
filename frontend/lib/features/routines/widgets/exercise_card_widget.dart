import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/routine_detail_model.dart';

class ExerciseCardWidget extends StatelessWidget {
  final ExerciseModel exercise;

  /// Callback cuando el usuario pulsa el botón de play.
  final VoidCallback? onPlayTap;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ExerciseThumbnail(imageUrl: exercise.imageUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onPlayTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _ExerciseThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.accessibility_new_rounded,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
              ),
            )
          : const Icon(
              Icons.accessibility_new_rounded,
              color: AppColors.textSecondary,
              size: 32,
            ),
    );
  }
}
