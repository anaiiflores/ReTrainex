import 'package:flutter/material.dart';
import '../../core/strings/locale_manager.dart';
import '../../core/theme/app_colors.dart';

class VideoAreaWidget extends StatelessWidget {
  final String? videoUrl;
  final bool isWide;

  const VideoAreaWidget({
    super.key,
    required this.videoUrl,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final double height = isWide ? 240 : 180;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: videoUrl != null
          ? const Center(
              child: Icon(Icons.play_circle_outline_rounded,
                  color: AppColors.primary, size: 64),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    size: 48),
                const SizedBox(height: 10),
                Text(
                  LocaleManager.strings.videoComingSoon,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
