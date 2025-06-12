import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_styles.dart';
import '../../views/fishing_ban/fishing_ban_info_screen.dart';
import '../../../core/services/fishing_ban_service.dart';

class FishingBanIndicator extends StatelessWidget {
  const FishingBanIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final banStatus = FishingBanService.getBanStatus();
    final isBanActive = banStatus.isActive;
    final remainingDays = banStatus.remainingDays;
    final progress = banStatus.progress;

    Color containerColor =
        isBanActive ? AppColors.errorLight : AppColors.backgroundWhite;

    Color textColor = isBanActive ? AppColors.error : AppColors.primary;

    String statusText =
        isBanActive
            ? 'Active: Fishing is prohibited'
            : 'Inactive: Fishing is allowed';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FishingBanInfoScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isBanActive
                    ? AppColors.error.withOpacity(0.3)
                    : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isBanActive
                      ? Icons.do_not_disturb
                      : Icons.check_circle_outline,
                  color: textColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fishing Ban Period',
                  style: AppStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isBanActive ? AppColors.error : AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Annual Conservation Period: 15 Apr - 15 May',
              style: AppStyles.bodyMedium.copyWith(
                color:
                    isBanActive
                        ? AppColors.error.withOpacity(0.8)
                        : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isBanActive ? AppColors.error : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            if (isBanActive)
              Text(
                '$remainingDays days remaining until fishing resumes',
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isBanActive ? AppColors.error : AppColors.primary,
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap for more information',
              style: AppStyles.bodySmall.copyWith(
                color:
                    isBanActive
                        ? AppColors.error.withOpacity(0.8)
                        : AppColors.primary.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
