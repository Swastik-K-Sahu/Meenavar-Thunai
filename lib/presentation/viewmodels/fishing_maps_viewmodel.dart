import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:vibration/vibration.dart';
import '../../models/fishing_hotspot.dart';
import '../../core/services/hotspot_prediction_service.dart';
import 'package:meenavar_thunai/theme/app_colors.dart';

class FishingMapsViewModel extends ChangeNotifier {
  final HotspotPredictionService _predictionService;

  FishingMapsViewModel({required HotspotPredictionService predictionService})
    : _predictionService = predictionService;

  List<FishingHotspot> _hotspots = [];
  bool _isLoading = false;
  String? _error;
  FishingHotspot? _selectedHotspot;
  LatLng? _currentLocation;
  List<List<LatLng>> _eezBoundaries = [];
  final double _proximityThreshold = 10.0;
  bool _isBorderProximityWarningActive = false;
  double _currentBorderDistance = double.infinity;
  final Set<Polyline> _eezPolylines = {};

  // Getters
  List<FishingHotspot> get hotspots => _hotspots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FishingHotspot? get selectedHotspot => _selectedHotspot;
  int get hotspotsCount => _hotspots.length;
  LatLng? get currentLocation => _currentLocation;
  bool get isBorderProximityWarningActive => _isBorderProximityWarningActive;
  double get currentBorderDistance => _currentBorderDistance;
  Set<Polyline> get eezPolylines => _eezPolylines;

  // Get hotspots by probability range
  List<FishingHotspot> get highProbabilityHotspots =>
      _hotspots.where((h) => h.probability >= 0.8).toList();

  List<FishingHotspot> get mediumProbabilityHotspots =>
      _hotspots
          .where((h) => h.probability >= 0.6 && h.probability < 0.8)
          .toList();

  List<FishingHotspot> get lowProbabilityHotspots =>
      _hotspots.where((h) => h.probability < 0.6).toList();

  /// Initialize location services
  Future<void> initializeLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }
    LocationData locationData = await location.getLocation();
    _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

    // Set up location updates
    location.onLocationChanged.listen((LocationData newLocation) {
      _currentLocation = LatLng(newLocation.latitude!, newLocation.longitude!);
      checkBorderProximity();
      notifyListeners();
    });

    checkBorderProximity();
    notifyListeners();
  }

  /// Load EEZ boundaries from GeoJSON
  Future<void> loadEEZData() async {
    try {
      final String geojsonString = await rootBundle.loadString(
        'assets/india_eez.geojson',
      );
      final geojsonData = json.decode(geojsonString);
      List<List<LatLng>> parsedBorders = [];
      Set<Polyline> newPolylines = {};

      for (var feature in geojsonData['features']) {
        var geometry = feature['geometry'];

        if (geometry['type'] == 'LineString') {
          // Handle LineString geometry
          List<dynamic> coordinates = geometry['coordinates'];
          List<LatLng> borderPoints =
              coordinates
                  .map<LatLng>((point) => LatLng(point[1], point[0]))
                  .toList();

          parsedBorders.add(borderPoints);
          newPolylines.add(
            Polyline(
              polylineId: PolylineId('eez_${newPolylines.length}'),
              points: borderPoints,
              color: AppColors.maritimeBoundaryColor,
              width: 4,
            ),
          );
        } else if (geometry['type'] == 'Polygon') {
          List<dynamic> coordinates = geometry['coordinates'];
          List<LatLng> borderPoints =
              coordinates[0]
                  .map<LatLng>((point) => LatLng(point[1], point[0]))
                  .toList();

          parsedBorders.add(borderPoints);
          newPolylines.add(
            Polyline(
              polylineId: PolylineId('eez_${newPolylines.length}'),
              points: borderPoints,
              color: AppColors.maritimeBoundaryColor,
              width: 4,
            ),
          );
        } else if (geometry['type'] == 'MultiPolygon') {
          List<dynamic> coordinates = geometry['coordinates'];
          for (var polygon in coordinates) {
            List<LatLng> borderPoints =
                polygon[0]
                    .map<LatLng>((point) => LatLng(point[1], point[0]))
                    .toList();

            parsedBorders.add(borderPoints);
            newPolylines.add(
              Polyline(
                polylineId: PolylineId('eez_${newPolylines.length}'),
                points: borderPoints,
                color: AppColors.maritimeBoundaryColor,
                width: 4,
              ),
            );
          }
        }
      }

      _eezBoundaries = parsedBorders;
      _eezPolylines.addAll(newPolylines);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading EEZ data: $e");
      }
    }
  }

  /// Check proximity to EEZ boundaries
  void checkBorderProximity() async {
    if (_currentLocation == null || _eezBoundaries.isEmpty) return;

    double minDistance = double.infinity;
    for (var border in _eezBoundaries) {
      double distance = _calculateMinDistanceToBorder(
        _currentLocation!,
        border,
      );
      minDistance = min(minDistance, distance);
    }

    bool isClose = minDistance <= _proximityThreshold;

    if (isClose && !_isBorderProximityWarningActive) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 5000);
      }
      print(
        'Warning! You are near the international maritime boundary: $minDistance km away.',
      );
    }

    _isBorderProximityWarningActive = isClose;
    _currentBorderDistance = minDistance;
    notifyListeners();
  }

  /// Calculate minimum distance to border
  double _calculateMinDistanceToBorder(
    LatLng position,
    List<LatLng> borderPoints,
  ) {
    double minDistance = double.infinity;
    for (int i = 0; i < borderPoints.length - 1; i++) {
      double distance =
          Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            (borderPoints[i].latitude + borderPoints[i + 1].latitude) / 2,
            (borderPoints[i].longitude + borderPoints[i + 1].longitude) / 2,
          ) /
          1000;
      minDistance = min(minDistance, distance);
    }
    return minDistance;
  }

  /// Find fishing hotspots around a location
  Future<void> findHotspots({
    required double centerLat,
    required double centerLng,
    double radiusKm = 20.0,
  }) async {
    _isLoading = true;
    _error = null;
    _selectedHotspot = null;
    notifyListeners();

    try {
      _hotspots = await _predictionService.predictHotspots(
        centerLat: centerLat,
        centerLng: centerLng,
        radiusKm: radiusKm,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to find hotspots: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a specific hotspot
  void selectHotspot(FishingHotspot hotspot) {
    _selectedHotspot = hotspot;
    notifyListeners();
  }

  /// Clear selected hotspot
  void clearSelection() {
    _selectedHotspot = null;
    notifyListeners();
  }

  /// Clear all hotspots and reset state
  void clearHotspots() {
    _hotspots.clear();
    _selectedHotspot = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh hotspots for the same location
  Future<void> refreshHotspots() async {
    if (_hotspots.isNotEmpty) {
      double avgLat =
          _hotspots.map((h) => h.latitude).reduce((a, b) => a + b) /
          _hotspots.length;
      double avgLng =
          _hotspots.map((h) => h.longitude).reduce((a, b) => a + b) /
          _hotspots.length;
      await findHotspots(centerLat: avgLat, centerLng: avgLng);
    }
  }

  /// Get hotspot statistics
  Map<String, dynamic> getHotspotStats() {
    if (_hotspots.isEmpty) {
      return {
        'total': 0,
        'high_probability': 0,
        'medium_probability': 0,
        'low_probability': 0,
        'average_probability': 0.0,
        'best_hotspot': null,
      };
    }

    double avgProbability =
        _hotspots.map((h) => h.probability).reduce((a, b) => a + b) /
        _hotspots.length;

    FishingHotspot bestHotspot = _hotspots.reduce(
      (a, b) => a.probability > b.probability ? a : b,
    );

    return {
      'total': _hotspots.length,
      'high_probability': highProbabilityHotspots.length,
      'medium_probability': mediumProbabilityHotspots.length,
      'low_probability': lowProbabilityHotspots.length,
      'average_probability': avgProbability,
      'best_hotspot': bestHotspot,
    };
  }

  @override
  void dispose() {
    _hotspots.clear();
    super.dispose();
  }

  double min(double a, double b) => a < b ? a : b;
}
