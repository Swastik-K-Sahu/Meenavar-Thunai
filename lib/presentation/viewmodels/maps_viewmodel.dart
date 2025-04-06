import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:meenavar_thunai/theme/app_colors.dart';
import 'package:vibration/vibration.dart';

class MapsViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  MapType _mapType = MapType.hybrid;
  List<List<LatLng>> _eezBoundaries = [];
  final double _proximityThreshold = 10.0;
  bool _isBorderProximityWarningActive = false;
  double _currentBorderDistance = 0.0;
  final Set<Polyline> _eezPolylines = {};

  GoogleMapController? get mapController => _mapController;
  LatLng? get currentLocation => _currentLocation;
  Set<Marker> get markers => _markers;
  MapType get mapType => _mapType;
  bool get isBorderProximityWarningActive => _isBorderProximityWarningActive;
  double get currentBorderDistance => _currentBorderDistance;
  Set<Polyline> get eezPolylines => _eezPolylines;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

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
        if (geometry['type'] == 'Polygon' ||
            geometry['type'] == 'MultiPolygon') {
          List<dynamic> coordinates =
              geometry['type'] == 'Polygon'
                  ? [geometry['coordinates']]
                  : geometry['coordinates'];

          for (var polygon in coordinates) {
            // for (var ring in polygon) {
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
                width: 6,
              ),
            );
          }
        }
      }
      // }
      _eezBoundaries = parsedBorders;
      _eezPolylines.addAll(newPolylines);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading EEZ data: $e");
      }
    }
  }

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
    checkBorderProximity();
    notifyListeners();
  }

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
      if (await Vibration.hasVibrator() ?? false) {
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

  void addMarker(LatLng position, String title, String snippet) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
    );
    _markers.add(marker);
    notifyListeners();
  }

  void changeMapType(MapType newType) {
    _mapType = newType;
    notifyListeners();
  }

  double min(double a, double b) => a < b ? a : b;
}
