import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';

class AlertsWidget extends StatelessWidget {
  const AlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample alerts data
    final alerts = [
      {
        'title': 'High Tide Warning',
        'description':
            'High tide expected at 15:30. Use caution when navigating coastal areas.',
        'severity': 'warning',
        'time': '1h ago',
      },
      {
        'title': 'Marine Life Sighting',
        'description':
            'Dolphin pod spotted 3km offshore from Pine Beach. Great photo opportunity!',
        'severity': 'info',
        'time': '3h ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Important Alerts',
              style: AppStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: AppStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];

            // Determine alert color based on severity
            Color alertColor;
            IconData alertIcon;

            switch (alert['severity']) {
              case 'warning':
                alertColor = Colors.orange;
                alertIcon = Icons.warning_amber_rounded;
                break;
              case 'danger':
                alertColor = Colors.red;
                alertIcon = Icons.error_outline;
                break;
              case 'info':
              default:
                alertColor = Colors.blue;
                alertIcon = Icons.info_outline;
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: alertColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(alertIcon, color: alertColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert['title']!,
                                      style: AppStyles.titleSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    alert['time']!,
                                    style: AppStyles.bodySmall.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert['description']!,
                                style: AppStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
