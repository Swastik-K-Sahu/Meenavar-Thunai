// import 'package:flutter/material.dart';
// import '../../data/models/weather_model.dart';
// import '../../domain/entities/weather_forecast.dart';
// import '../../domain/usecases/weather/get_forecast_usecase.dart';
// import '../../core/services/connectivity_service.dart';
// import '../../core/services/location_service.dart';

// class WeatherViewModel extends ChangeNotifier {
//   final GetForecastUseCase _getForecastUseCase;
//   final ConnectivityService _connectivityService;
//   final LocationService _locationService;

//   WeatherViewModel({
//     required GetForecastUseCase getForecastUseCase,
//     required ConnectivityService connectivityService,
//     required LocationService locationService,
//   }) : _getForecastUseCase = getForecastUseCase,
//        _connectivityService = connectivityService,
//        _locationService = locationService;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   WeatherForecast? _currentWeather;
//   WeatherForecast? get currentWeather => _currentWeather;

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   DateTime? _lastUpdated;
//   DateTime? get lastUpdated => _lastUpdated;

//   Future<void> fetchWeatherData() async {
//     if (_isLoading) return;

//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final isConnected = await _connectivityService.isConnected;

//       if (!isConnected) {
//         // Try to get cached weather data
//         final cachedWeather = await _getForecastUseCase.getCachedForecast();

//         if (cachedWeather != null) {
//           _currentWeather = cachedWeather;
//           _lastUpdated =
//               DateTime.now(); // This should actually come from the cache
//         } else {
//           _errorMessage = 'No cached weather data available';
//         }
//       } else {
//         // Get current location
//         final location = await _locationService.getCurrentLocation();

//         if (location != null) {
//           // Fetch fresh weather data
//           final result = await _getForecastUseCase.execute(
//             latitude: location.latitude,
//             longitude: location.longitude,
//           );

//           if (result.success) {
//             _currentWeather = result.data;
//             _lastUpdated = DateTime.now();
//           } else {
//             _errorMessage = result.message ?? 'Failed to fetch weather data';
//           }
//         } else {
//           _errorMessage = 'Unable to get location';
//         }
//       }
//     } catch (e) {
//       _errorMessage = 'An error occurred: ${e.toString()}';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Additional methods for specific weather functions
//   // ...
// }
