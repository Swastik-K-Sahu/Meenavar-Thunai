import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../../models/weather_data.dart';
import 'weather_detail_screen.dart';
import '../../../secrets.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  WeatherData? weatherData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      const String apiUrl = AppSecrets.weatherApiUrl;

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          weatherData = WeatherData.fromJson(jsonData);
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load weather data';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current date and format it
    final DateTime now = DateTime.now();
    final String currentDay = DateFormat('EEEE').format(now);
    final String currentDate = DateFormat('d').format(now);
    final String currentMonth = DateFormat('MMM').format(now);
    final String formattedDate = '$currentDay $currentDate, $currentMonth';

    return GestureDetector(
      onTap: () {
        if (weatherData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => WeatherDetailScreen(weatherData: weatherData!),
            ),
          );
        }
      },
      child: Container(
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
        child:
            isLoading
                ? _buildLoadingWidget()
                : errorMessage != null
                ? _buildErrorWidget()
                : _buildWeatherContent(formattedDate),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Loading weather...'),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 32),
        const SizedBox(height: 8),
        Text(
          errorMessage!,
          style: AppStyles.bodyMedium.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isLoading = true;
              errorMessage = null;
            });
            _fetchWeatherData();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildWeatherContent(String formattedDate) {
    final double temperature = weatherData?.temperature ?? 16.0;
    final double windSpeed = weatherData?.windSpeed ?? 10.0;
    final bool isDay = (weatherData?.isDay ?? 1) == 1;
    final double rain = weatherData?.rain ?? 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
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
                    '${temperature.round()}°',
                    style: AppStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                _getWeatherDescription(isDay, rain, temperature),
                style: AppStyles.bodyMedium.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Row(children: _getWeatherIcons(isDay, rain)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getWindIcon(windSpeed),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${windSpeed.round()} km/h',
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _getWeatherIcons(bool isDay, double rain) {
    List<Widget> icons = [];

    if (rain > 0) {
      // Rainy weather
      icons.add(Icon(Icons.grain, color: Colors.blue[400], size: 28));
      if (rain > 5) {
        icons.add(const SizedBox(width: 4));
        icons.add(Icon(Icons.cloud, color: Colors.grey[600], size: 24));
      }
    } else if (isDay) {
      // Sunny day
      icons.add(Icon(Icons.wb_sunny, color: Colors.amber, size: 28));
      icons.add(const SizedBox(width: 4));
      icons.add(Icon(Icons.cloud_outlined, color: Colors.blue[200], size: 24));
    } else {
      // Night
      icons.add(
        Icon(Icons.nightlight_round, color: Colors.indigo[300], size: 28),
      );
      icons.add(const SizedBox(width: 4));
      icons.add(Icon(Icons.star, color: Colors.yellow[300], size: 20));
    }

    return icons;
  }

  IconData _getWindIcon(double windSpeed) {
    if (windSpeed > 20) {
      return Icons.air;
    } else if (windSpeed > 10) {
      return Icons.waves;
    } else {
      return Icons.air;
    }
  }

  String _getWeatherDescription(bool isDay, double rain, double temperature) {
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
