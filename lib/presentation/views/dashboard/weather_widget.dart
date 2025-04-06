import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current date and format it
    final DateTime now = DateTime.now();
    final String currentDay = DateFormat('EEEE').format(now);
    final String currentDate = DateFormat('d').format(now);
    final String currentMonth = DateFormat('MMM').format(now);
    final String formattedDate = '$currentDay $currentDate, $currentMonth';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tamil Nadu, India',
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: AppStyles.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '16°',
                    style: AppStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Sunny Day',
                style: AppStyles.bodyMedium.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud, color: Colors.blue[300], size: 28),
                      Icon(Icons.wb_sunny, color: Colors.amber, size: 24),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.air, color: AppColors.primary, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '10 km/h',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
