import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class MapsViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  MapType _mapType = MapType.hybrid;

  // Tamil Nadu Maritime Boundary Coordinates (Approximate)
  static final List<List<LatLng>> tamilNaduMaritimeBorders = [
    // Chennai Coast
    [
      LatLng(13.0827, 80.2707), // Chennai
      LatLng(12.9716, 80.1947),
      LatLng(13.1202, 80.3084),
    ],
    // Kanniyakumari Coast
    [
      LatLng(8.0883, 77.5469), // Kanniyakumari
      LatLng(8.0712, 77.5534),
      LatLng(8.0993, 77.5398),
    ],
    // Rameswaram Coast
    [
      LatLng(9.2881, 79.3174), // Rameswaram
      LatLng(9.2785, 79.3268),
      LatLng(9.2952, 79.3084),
    ],
  ];

  // Border Proximity Variables
  bool _isBorderProximityWarningActive = false;
  double _currentBorderDistance = 0.0;

  // Proximity threshold in kilometers
  final double _proximityThreshold = 10.0;

  // Getters
  GoogleMapController? get mapController => _mapController;
  LatLng? get currentLocation => _currentLocation;
  Set<Marker> get markers => _markers;
  MapType get mapType => _mapType;
  bool get isBorderProximityWarningActive => _isBorderProximityWarningActive;
  double get currentBorderDistance => _currentBorderDistance;

  // Change Map Type
  void changeMapType(MapType mapType) {
    _mapType = mapType;
    notifyListeners();
  }

  // Initialize Location
  Future<void> initializeLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

    // Check border proximity after location is initialized
    checkBorderProximity();

    notifyListeners();
  }

  // Map Controller
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  // Add Marker
  void addMarker(LatLng position, String title, String snippet) {
    final marker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
    );
    _markers.add(marker);
    notifyListeners();
  }

  // Move Camera
  void moveCamera(LatLng target) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ),
    );
  }

  // Border Proximity Check
  void checkBorderProximity() {
    if (_currentLocation == null) return;

    double minDistance = double.infinity;

    for (var border in tamilNaduMaritimeBorders) {
      double distance = _calculateMinDistanceToBorder(
        _currentLocation!,
        border,
      );

      minDistance = min(minDistance, distance);
    }

    // Update proximity warning state
    _isBorderProximityWarningActive = minDistance <= _proximityThreshold;
    _currentBorderDistance = minDistance;

    if (_isBorderProximityWarningActive) {
      print('Border Proximity Warning: $minDistance km');
    }

    notifyListeners();
  }

  // Calculate Minimum Distance to Border
  double _calculateMinDistanceToBorder(
    LatLng currentLocation,
    List<LatLng> borderPoints,
  ) {
    double minDistance = double.infinity;

    for (int i = 0; i < borderPoints.length - 1; i++) {
      double distance =
          Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            (borderPoints[i].latitude + borderPoints[i + 1].latitude) / 2,
            (borderPoints[i].longitude + borderPoints[i + 1].longitude) / 2,
          ) /
          1000; // Convert to kilometers

      minDistance = min(minDistance, distance);
    }

    return minDistance;
  }

  // Utility function to find minimum of two doubles
  double min(double a, double b) => a < b ? a : b;

  // Update Border Coordinates
  void updateInternationalBorders(List<List<LatLng>> newBorders) {
    tamilNaduMaritimeBorders.clear();
    tamilNaduMaritimeBorders.addAll(newBorders);
    notifyListeners();
  }
}
