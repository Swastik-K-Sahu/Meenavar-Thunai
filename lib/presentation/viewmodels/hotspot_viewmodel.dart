// viewmodels/hotspot_view_model.dart
import 'package:flutter/foundation.dart';
import '../../models/fishing_hotspot.dart';
import '../../core/services/hotspot_prediction_service.dart';

class HotspotViewModel extends ChangeNotifier {
  final HotspotPredictionService _predictionService;

  HotspotViewModel({required HotspotPredictionService predictionService})
    : _predictionService = predictionService;

  List<FishingHotspot> _hotspots = [];
  bool _isLoading = false;
  String? _error;
  FishingHotspot? _selectedHotspot;

  // Getters
  List<FishingHotspot> get hotspots => _hotspots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FishingHotspot? get selectedHotspot => _selectedHotspot;
  int get hotspotsCount => _hotspots.length;

  // Get hotspots by probability range
  List<FishingHotspot> get highProbabilityHotspots =>
      _hotspots.where((h) => h.probability >= 0.8).toList();

  List<FishingHotspot> get mediumProbabilityHotspots =>
      _hotspots
          .where((h) => h.probability >= 0.6 && h.probability < 0.8)
          .toList();

  List<FishingHotspot> get lowProbabilityHotspots =>
      _hotspots.where((h) => h.probability < 0.6).toList();

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
      // Use the center point of existing hotspots for refresh
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
}
