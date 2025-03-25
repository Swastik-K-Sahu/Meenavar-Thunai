import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapsViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  MapType _mapType = MapType.hybrid;

  GoogleMapController? get mapController => _mapController;
  LatLng? get currentLocation => _currentLocation;
  Set<Marker> get markers => _markers;
  MapType get mapType => _mapType;

  void changeMapType(MapType mapType) {
    _mapType = mapType;
    notifyListeners();
  }

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
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  void addMarker(LatLng position, String title, String snippet) {
    final marker = Marker(
      markerId: MarkerId(DateTime.now().toString()),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
    );
    _markers.add(marker);
    notifyListeners();
  }

  void moveCamera(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ),
    );
  }
}
