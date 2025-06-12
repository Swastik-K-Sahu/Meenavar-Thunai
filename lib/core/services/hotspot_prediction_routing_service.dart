import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../models/fishing_hotspot.dart';
import '../../models/weather_data.dart';
import '../../models/ocean_data.dart';
import '../../data/boat_type.dart';

class HotspotPredictionService {
  final String geminiApiKey;
  final String weatherApiUrl;
  final String oceanApiUrl;

  HotspotPredictionService({
    required this.geminiApiKey,
    required this.weatherApiUrl,
    required this.oceanApiUrl,
  });

  Future<List<FishingHotspot>> predictHotspots({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) async {
    try {
      // Generate multiple points around the center location
      List<Map<String, double>> searchPoints = _generateSearchPoints(
        centerLat,
        centerLng,
        radiusKm,
      );

      List<FishingHotspot> hotspots = [];

      for (var point in searchPoints) {
        // Fetch weather and ocean data for each point
        var weatherData = await _fetchWeatherData(point['lat']!, point['lng']!);
        var oceanData = await _fetchOceanData(point['lat']!, point['lng']!);

        // Use Gemini to analyze the data and predict fishing potential
        var prediction = await _analyzeWithGemini(
          point['lat']!,
          point['lng']!,
          weatherData,
          oceanData,
        );

        if (prediction != null && prediction.probability > 0.3) {
          hotspots.add(prediction);
        }
      }

      // Sort by probability (highest first)
      hotspots.sort((a, b) => b.probability.compareTo(a.probability));

      return hotspots;
    } catch (e) {
      print('Error predicting hotspots: $e');
      return [];
    }
  }

  List<Map<String, double>> _generateSearchPoints(
    double centerLat,
    double centerLng,
    double radiusKm,
  ) {
    List<Map<String, double>> points = [];
    const int numberOfPoints = 2;
    const double earthRadius = 6371;

    for (int i = 0; i < numberOfPoints; i++) {
      double angle = (i * 2 * pi) / numberOfPoints;
      double distance = radiusKm * (0.3 + (i % 3) * 0.35); // Vary distance

      double lat =
          centerLat + (distance / earthRadius) * (180 / pi) * cos(angle);
      double lng =
          centerLng +
          (distance / earthRadius) *
              (180 / pi) *
              sin(angle) /
              cos(centerLat * pi / 180);

      points.add({'lat': lat, 'lng': lng});
    }

    return points;
  }

  Future<WeatherData?> _fetchWeatherData(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$weatherApiUrl?latitude=$lat&longitude=$lng&current=temperature_2m,wind_speed_10m,is_day&hourly=temperature_80m,rain,wind_speed_80m,wind_direction_80m&daily=sunrise,sunset&timezone=auto',
        ),
      );

      if (response.statusCode == 200) {
        print('Weather data fetched successfully for ($lat, $lng)');
        return WeatherData.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
    return null;
  }

  Future<OceanData?> _fetchOceanData(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$oceanApiUrl?latitude=$lat&longitude=$lng&current=sea_surface_temperature,ocean_current_velocity,ocean_current_direction&hourly=wave_height,sea_level_height_msl',
        ),
      );

      if (response.statusCode == 200) {
        return OceanData.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error fetching ocean data: $e');
    }
    return null;
  }

  Future<WeatherData?> fetchWeatherData(double lat, double lng) async {
    return await _fetchWeatherData(lat, lng);
  }

  Future<OceanData?> fetchOceanData(double lat, double lng) async {
    return await _fetchOceanData(lat, lng);
  }

  Future<FishingHotspot?> _analyzeWithGemini(
    double lat,
    double lng,
    WeatherData? weather,
    OceanData? ocean,
  ) async {
    if (weather == null || ocean == null) return null;

    try {
      final prompt = _buildHotspotPredPrompt(lat, lng, weather, ocean);

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 1000},
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        print('Gemini response content: $content');
        return _parseGeminiResponse(lat, lng, content);
      }
    } catch (e) {
      print('Error analyzing with Gemini: $e');
    }
    return null;
  }

  String _buildHotspotPredPrompt(
    double lat,
    double lng,
    WeatherData weather,
    OceanData ocean,
  ) {
    return '''
    Analyze the following fishing conditions at coordinates ($lat, $lng) and provide a JSON response:

    Weather Data:
    - Temperature: ${weather.temperature}°C
    - Wind Speed: ${weather.windSpeed} km/h
    - Rain: ${weather.rain}mm
    - Is Day: ${weather.isDay == 1 ? 'Yes' : 'No'}
    - Sunrise: ${weather.sunrise}
    - Sunset: ${weather.sunset}

    Ocean Data:
    - Sea Surface Temperature: ${ocean.current.seaSurfaceTemperature}°C
    - Ocean Current Velocity: ${ocean.current.oceanCurrentVelocity} m/s
    - Current Direction: ${ocean.current.oceanCurrentDirection}°
    - Wave Height: ${ocean.hourly.waveHeight.isNotEmpty ? ocean.hourly.waveHeight.first : 'N/A'} m

    Please provide a JSON response with the following structure:
    {
      "probability": 0.0-1.0 (fishing success probability),
      "description": "Brief description of fishing conditions",
      "probable_species": ["species1", "species2", "species3"],
      "weather_conditions": "Summary of current weather impact on fishing",
      "precautions": ["precaution1", "precaution2"],
      "best_time_to_fish": "Recommended time period",
      "latitude": $lat,
      "longitude": $lng
    }

    Consider factors like:
    - Optimal water temperature for fish activity
    - Wave conditions for boat safety
    - Wind conditions for casting
    - Current strength for bait presentation
    - Time of day effects on fish feeding
    - Seasonal fish behavior patterns
    - Local fishing regulations and practices
    - Try to give practical tips for fishing in these conditions
    - Try to give time duration of fishing in these conditions, not just a time of day, 
      e.g., "Best from 6 AM to 10 AM"
    - Give the timing during sunlight hours, as fishermen prefer fishing during the day, not at night
    ''';
  }

  FishingHotspot? _parseGeminiResponse(double lat, double lng, String content) {
    try {
      // Extract JSON from the response
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = content.substring(jsonStart, jsonEnd);
        final data = json.decode(jsonString);
        print('Parsed JSON: $data');
        return FishingHotspot.fromJson(data);
      }
    } catch (e) {
      print('Error parsing Gemini response: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> calculateOptimizedRoute({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    required BoatType boat,
    required WeatherData weather,
    required OceanData ocean,
  }) async {
    try {
      final prompt = _buildRouteOptimizationPrompt(
        startLat,
        startLng,
        destLat,
        destLng,
        boat,
        weather,
        ocean,
      );

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 1500},
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        print('Gemini route optimization response: $content');
        return _parseRouteOptimizationResponse(content);
      }
    } catch (e) {
      print('Error calculating optimized route: $e');
    }
    return null;
  }

  String _buildRouteOptimizationPrompt(
    double startLat,
    double startLng,
    double destLat,
    double destLng,
    BoatType boat,
    WeatherData weather,
    OceanData ocean,
  ) {
    // Get current time in IST
    final istOffset = Duration(hours: 5, minutes: 30); // IST is UTC+5:30
    final currentTime = DateTime.now().toUtc().add(istOffset);
    final currentHour = currentTime.hour;

    double currentWindDirection =
        weather.hourlyWindDirection.length > currentHour
            ? weather.hourlyWindDirection[currentHour]
            : 0.0;
    return '''
    You are an expert fisherman from Tamil Nadu, India, with deep knowledge of navigating coastal waters. Given the starting point ($startLat, $startLng) and destination ($destLat, $destLng), calculate an optimized route that minimizes fuel consumption and travel time while ensuring safety based on the following conditions:

    Boat Specifications:
    - Boat Type: ${boat.name}
    - Average Speed: ${boat.averageSpeedKmh} km/h
    - Fuel Consumption Rate: ${boat.fuelConsumptionRate} liters/km

    Weather Data at Destination:
    - Temperature: ${weather.temperature}°C
    - Wind Speed: ${weather.windSpeed} km/h
    - Wind Direction: $currentWindDirection°
    - Rain: ${weather.rain}mm

    Ocean Data at Destination:
    - Sea Surface Temperature: ${ocean.current.seaSurfaceTemperature}°C
    - Ocean Current Velocity: ${ocean.current.oceanCurrentVelocity} m/s
    - Current Direction: ${ocean.current.oceanCurrentDirection}°
    - Wave Height: ${ocean.hourly.waveHeight.isNotEmpty ? ocean.hourly.waveHeight.first : 'N/A'} m

    Provide a JSON response with the following structure:
    {
      "waypoints": [
        {"latitude": double, "longitude": double},
        {"latitude": double, "longitude": double},
        ...
      ],
      "distance_km": double,
      "estimated_time_hours": double,
      "fuel_saving_tips": ["tip1", "tip2", ...]
    }

    Consider the following:
    - Use ocean currents to your advantage to reduce fuel consumption.
    - Avoid areas with high waves or strong winds that could increase fuel use or risk safety.
    - Adjust the route to minimize travel time while ensuring fuel efficiency.
    - Provide practical fuel-saving tips based on the conditions and boat type (e.g., optimal speed, avoiding certain areas).
    - Ensure the route is safe for the boat type and current weather conditions.
    - Limit the tips to 4-5 practical suggestions.
    - Keep the tips simple and actionable, suitable for a fisherman with basic navigation skills.
    ''';
  }

  Map<String, dynamic>? _parseRouteOptimizationResponse(String content) {
    try {
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = content.substring(jsonStart, jsonEnd);
        return json.decode(jsonString);
      }
    } catch (e) {
      print('Error parsing route optimization response: $e');
    }
    return null;
  }
}
