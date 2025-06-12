import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meenavar_thunai/presentation/views/weather/ocean_data_widget.dart';
import 'dart:math' as math;
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../../models/weather_data.dart'; // Import the WeatherData class from the models file

class WeatherDetailScreen extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDetailScreen({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final bool isDay = weatherData.isDay == 1;

    return Scaffold(
      backgroundColor: _getBackgroundColor(isDay),
      appBar: AppBar(
        title: const Text('Weather Details'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: isDay ? AppColors.textDark : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainWeatherCard(isDay),
            const SizedBox(height: 20),
            _buildHourlyTemperatureCard(),
            const SizedBox(height: 20),
            _buildWindCard(),
            const SizedBox(height: 20),
            _buildSunsetCard(isDay),
            const SizedBox(height: 20),
            const OceanDataWidget(),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDay) {
    if (isDay) {
      return const Color(0xFFE3F2FD); // Light blue for day
    } else {
      return const Color(0xFF1A1A2E); // Dark blue for night
    }
  }

  Widget _buildMainWeatherCard(bool isDay) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDay
                  ? [Colors.blue[300]!, Colors.blue[100]!]
                  : [Colors.indigo[800]!, Colors.indigo[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Text(
            'Tamil Nadu, India',
            style: AppStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weatherData.temperature.round()}°C',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _getWeatherDescription(),
            style: AppStyles.bodyLarge.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyTemperatureCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Temperature',
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140, // Increased height to accommodate content
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: math.min(
                weatherData.hourlyTimes.length,
                24,
              ), // Limit to 24 hours for performance
              itemBuilder: (context, index) {
                final time = DateTime.parse(weatherData.hourlyTimes[index]);
                final temp = weatherData.hourlyTemperatures[index];
                final hour = DateFormat('HH').format(time);

                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 36, // Fixed width to prevent overflow
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Important: minimize column size
                    children: [
                      Text(
                        '${temp.round()}°',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Slightly smaller text
                        ),
                      ),
                      const SizedBox(height: 6), // Reduced spacing
                      Expanded(
                        // Use Expanded to take available space
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 4,
                              height: (temp / 40 * 60).clamp(10.0, 60.0),
                              decoration: BoxDecoration(
                                color: _getTemperatureColor(temp),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6), // Reduced spacing
                      Text(
                        '$hour:00',
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10, // Smaller text
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindCard() {
    final currentHour = DateTime.now().hour;
    final windDirection = weatherData.hourlyWindDirection[currentHour];
    final windSpeed = weatherData.hourlyWindSpeed[currentHour];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Wind',
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Speed',
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${windSpeed.round()} km/h',
                      style: AppStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gusts',
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(windSpeed * 1.3).round()} km/h',
                      style: AppStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Direction',
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getWindDirection(windDirection)} ${windDirection.round()}°',
                      style: AppStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              _buildWindDirectionWheel(windDirection),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWindDirectionWheel(double direction) {
    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(painter: WindDirectionPainter(direction)),
    );
  }

  Widget _buildSunsetCard(bool isDay) {
    final sunrise = DateTime.parse(weatherData.sunrise);
    final sunset = DateTime.parse(weatherData.sunset);
    final now = DateTime.now();

    // Calculate progress through the day
    final dayStart = sunrise;
    final dayEnd = sunset;
    final totalDayDuration = dayEnd.difference(dayStart).inMinutes;
    final currentProgress = now.difference(dayStart).inMinutes;
    final progressRatio = (currentProgress / totalDayDuration).clamp(0.0, 1.0);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Sunset',
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(sunrise),
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sunrise',
                    style: AppStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(sunset),
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sunset',
                    style: AppStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSunProgressArc(progressRatio, isDay),
        ],
      ),
    );
  }

  Widget _buildSunProgressArc(double progress, bool isDay) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: CustomPaint(painter: SunProgressPainter(progress, isDay)),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp > 35) return Colors.red;
    if (temp > 30) return Colors.orange;
    if (temp > 25) return Colors.yellow[700]!;
    if (temp > 20) return Colors.green;
    return Colors.blue;
  }

  String _getWindDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  String _getWeatherDescription() {
    final rain = weatherData.rain;
    final isDay = weatherData.isDay == 1;
    final temperature = weatherData.temperature;

    if (rain > 5) {
      return 'Heavy Rain';
    } else if (rain > 0) {
      return 'Light Rain';
    } else if (!isDay) {
      return 'Clear Night';
    } else if (temperature > 30) {
      return 'Hot & Sunny';
    } else if (temperature > 25) {
      return 'Sunny Day';
    } else {
      return 'Pleasant Day';
    }
  }
}

class WindDirectionPainter extends CustomPainter {
  final double direction;

  WindDirectionPainter(this.direction);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw direction markers
    paint.strokeWidth = 1;
    for (int i = 0; i < 8; i++) {
      final angle = i * 45 * math.pi / 180;
      final start = Offset(
        center.dx + (radius - 10) * math.cos(angle - math.pi / 2),
        center.dy + (radius - 10) * math.sin(angle - math.pi / 2),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle - math.pi / 2),
        center.dy + radius * math.sin(angle - math.pi / 2),
      );
      canvas.drawLine(start, end, paint);
    }

    final arrowAngle = direction * math.pi / 180 - math.pi / 2;
    final arrowLength = radius - 20;
    final arrowEnd = Offset(
      center.dx + arrowLength * math.cos(arrowAngle),
      center.dy + arrowLength * math.sin(arrowAngle),
    );

    // Draw arrow line
    canvas.drawLine(
      center,
      arrowEnd,
      Paint()
        ..color = Colors.blue[600]!
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Draw arrow head
    final arrowHeadPaint =
        Paint()
          ..color = Colors.blue[600]!
          ..style = PaintingStyle.fill;

    canvas.drawCircle(arrowEnd, 6, arrowHeadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SunProgressPainter extends CustomPainter {
  final double progress;
  final bool isDay;

  SunProgressPainter(this.progress, this.isDay);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 20;

    // Draw background arc
    final backgroundPaint =
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    final progressPaint =
        Paint()
          ..color = isDay ? Colors.orange : Colors.indigo[400]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );

    // Draw sun position
    final sunAngle = math.pi + (math.pi * progress);
    final sunPosition = Offset(
      center.dx + radius * math.cos(sunAngle),
      center.dy + radius * math.sin(sunAngle),
    );

    final sunPaint =
        Paint()
          ..color = isDay ? Colors.yellow[600]! : Colors.grey[400]!
          ..style = PaintingStyle.fill;

    canvas.drawCircle(sunPosition, 8, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
