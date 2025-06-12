import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meenavar_thunai/secrets.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart' as lottie;
import '../../../models/fishing_hotspot.dart';
import '../../../core/services/hotspot_prediction_routing_service.dart';
import '../../viewmodels/fishing_maps_viewmodel.dart';
import '../../../data/boat_type.dart';

class FishingMapsScreen extends StatefulWidget {
  const FishingMapsScreen({super.key});

  @override
  _FishingMapsScreenState createState() => _FishingMapsScreenState();
}

class _FishingMapsScreenState extends State<FishingMapsScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _routePolylines = {};
  List<FishingHotspot> _hotspots = [];
  Map<String, dynamic>? _optimizedRoute;
  bool _isRouteLoading = false;
  bool _showRouteDetailsCard = false;
  late FishingMapsViewModel _fishingMapsViewModel;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  double _currentZoom = 10.0;
  Future<void> _zoomIn() async {
    if (_mapController != null) {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 20.0);
      await _mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    }
  }

  Future<void> _zoomOut() async {
    if (_mapController != null) {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 20.0);
      await _mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    }
  }

  final HotspotPredictionService _predictionService = HotspotPredictionService(
    geminiApiKey: AppSecrets.geminiApiKey,
    weatherApiUrl: 'https://api.open-meteo.com/v1/forecast',
    oceanApiUrl: 'https://marine-api.open-meteo.com/v1/marine',
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _fishingMapsViewModel = Provider.of<FishingMapsViewModel>(
      context,
      listen: false,
    );
    _fishingMapsViewModel.initializeLocation();
    _fishingMapsViewModel.loadEEZData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        _moveToCurrentLocation();
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _findHotspots() async {
    if (_fishingMapsViewModel.currentLocation == null) {
      print('Current location is null, cannot find hotspots.');
      _showErrorSnackbar('Current location unavailable.');
      return;
    }

    print(
      'Finding hotspots for location: (${_fishingMapsViewModel.currentLocation!.latitude}, ${_fishingMapsViewModel.currentLocation!.longitude})',
    );
    await _fishingMapsViewModel.findHotspots(
      centerLat: _fishingMapsViewModel.currentLocation!.latitude,
      centerLng: _fishingMapsViewModel.currentLocation!.longitude,
      radiusKm: 20.0,
    );

    print('Hotspots found: ${_fishingMapsViewModel.hotspots.length}');
    setState(() {
      _hotspots = _fishingMapsViewModel.hotspots;
      _circles.clear();
      _markers.clear();
      _createHotspotMarkers();
      if (_fishingMapsViewModel.hotspots.isNotEmpty) {
        _showHotspotsFoundSnackbar(_fishingMapsViewModel.hotspots.length);
      } else if (_fishingMapsViewModel.error != null) {
        print('Error in finding hotspots: ${_fishingMapsViewModel.error}');
        _showErrorSnackbar(_fishingMapsViewModel.error!);
      } else {
        print('No hotspots found, but no error reported.');
        _showErrorSnackbar('No fishing hotspots found in this area.');
      }
    });
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _zoomIn,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Container(
                width: 48,
                height: 48,
                child: Icon(Icons.add, color: Colors.blue, size: 24),
              ),
            ),
          ),
          Container(width: 48, height: 1, color: Colors.grey[300]),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _zoomOut,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                width: 48,
                height: 48,
                child: Icon(Icons.remove, color: Colors.blue, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createHotspotMarkers() {
    print('Creating hotspot markers for ${_hotspots.length} hotspots.');

    for (int i = 0; i < _hotspots.length; i++) {
      final hotspot = _hotspots[i];
      final color = _getHotspotColor(hotspot.probability);

      print(
        'Adding marker for hotspot $i at (${hotspot.latitude}, ${hotspot.longitude}) with probability ${hotspot.probability}',
      );
      _markers.add(
        Marker(
          markerId: MarkerId('hotspot_$i'),
          position: LatLng(hotspot.latitude, hotspot.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(hotspot.probability),
          ),
          onTap: () => _showHotspotDetails(hotspot),
          infoWindow: InfoWindow(
            title: 'Fishing Hotspot',
            snippet: '${(hotspot.probability * 100).toInt()}% probability',
          ),
        ),
      );

      _circles.add(
        Circle(
          circleId: CircleId('circle_$i'),
          center: LatLng(hotspot.latitude, hotspot.longitude),
          radius: hotspot.radius * 1000,
          fillColor: color.withOpacity(0.3),
          strokeColor: color,
          strokeWidth: 2,
        ),
      );
    }
    print(
      'Markers created: ${_markers.length}, Circles created: ${_circles.length}',
    );
  }

  Color _getHotspotColor(double probability) {
    if (probability >= 0.8) return Colors.green;
    if (probability >= 0.6) return Colors.orange;
    if (probability >= 0.4) return Colors.yellow;
    return Colors.red;
  }

  double _getMarkerHue(double probability) {
    if (probability >= 0.8) return BitmapDescriptor.hueGreen;
    if (probability >= 0.6) return BitmapDescriptor.hueOrange;
    if (probability >= 0.4) return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueRed;
  }

  void _showHotspotDetails(FishingHotspot hotspot) {
    _fishingMapsViewModel.selectHotspot(hotspot);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHotspotBottomSheet(hotspot),
    );
  }

  void _showHotspotsFoundSnackbar(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Found $count fishing hotspots!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _navigateToHotspot(FishingHotspot hotspot) async {
    BoatType? selectedBoat = await _showBoatSelectionDialog();
    if (selectedBoat == null) return;

    setState(() {
      _isRouteLoading = true;
    });

    // Fetch weather and ocean data for the hotspot
    var weatherData = await _predictionService.fetchWeatherData(
      hotspot.latitude,
      hotspot.longitude,
    );
    var oceanData = await _predictionService.fetchOceanData(
      hotspot.latitude,
      hotspot.longitude,
    );

    if (weatherData == null || oceanData == null) {
      _showErrorSnackbar('Failed to fetch weather or ocean data.');
      setState(() {
        _isRouteLoading = false;
      });
      return;
    }

    // Calculate optimized route
    var route = await _predictionService.calculateOptimizedRoute(
      startLat: _fishingMapsViewModel.currentLocation!.latitude,
      startLng: _fishingMapsViewModel.currentLocation!.longitude,
      destLat: hotspot.latitude,
      destLng: hotspot.longitude,
      boat: selectedBoat,
      weather: weatherData,
      ocean: oceanData,
    );

    if (route != null) {
      setState(() {
        _optimizedRoute = route;
        _showRouteDetailsCard = true;
        _routePolylines.clear();
        _routePolylines.add(
          Polyline(
            polylineId: PolylineId('optimized_route'),
            points:
                (route['waypoints'] as List)
                    .map(
                      (point) => LatLng(point['latitude'], point['longitude']),
                    )
                    .toList(),
            color: Colors.blue,
            width: 5,
          ),
        );
      });

      // Adjust camera to show the entire route
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              (_fishingMapsViewModel.currentLocation!.latitude <
                      hotspot.latitude
                  ? _fishingMapsViewModel.currentLocation!.latitude
                  : hotspot.latitude),
              (_fishingMapsViewModel.currentLocation!.longitude <
                      hotspot.longitude
                  ? _fishingMapsViewModel.currentLocation!.longitude
                  : hotspot.longitude),
            ),
            northeast: LatLng(
              (_fishingMapsViewModel.currentLocation!.latitude >
                      hotspot.latitude
                  ? _fishingMapsViewModel.currentLocation!.latitude
                  : hotspot.latitude),
              (_fishingMapsViewModel.currentLocation!.longitude >
                      hotspot.longitude
                  ? _fishingMapsViewModel.currentLocation!.longitude
                  : hotspot.longitude),
            ),
          ),
          50,
        ),
      );
    } else {
      _showErrorSnackbar('Failed to calculate optimized route.');
    }

    setState(() {
      _isRouteLoading = false;
    });
  }

  void _moveToCurrentLocation() {
    if (_fishingMapsViewModel.currentLocation != null &&
        _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _fishingMapsViewModel.currentLocation!,
            zoom: 12,
          ),
        ),
      );
    }
  }

  Future<BoatType?> _showBoatSelectionDialog() async {
    return showDialog<BoatType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Select Your Boat Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  BoatType.getCommonTamilNaduBoats().map((boat) {
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          boat.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(boat.description),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context, boat);
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Consumer<FishingMapsViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.currentLocation != null &&
                  _currentPosition != viewModel.currentLocation) {
                _currentPosition = viewModel.currentLocation;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _moveToCurrentLocation();
                });
              }
              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;

                  if (viewModel.currentLocation != null) {
                    Future.delayed(Duration(milliseconds: 100), () {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: viewModel.currentLocation!,
                            zoom: _currentZoom,
                          ),
                        ),
                      );
                    });
                  }
                },
                onCameraMove: (CameraPosition position) {
                  _currentZoom = position.zoom;
                },
                initialCameraPosition: CameraPosition(
                  target:
                      viewModel.currentLocation ??
                      LatLng(7.84725004878, 77.5753854671),
                  zoom: _currentZoom,
                ),
                markers: _markers,
                circles: _circles,
                polylines: {...viewModel.eezPolylines, ..._routePolylines},
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.hybrid,
                zoomControlsEnabled: false,
              );
            },
          ),

          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _optimizedRoute = null;
                            _routePolylines.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.blue),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Fishing Hotspots',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Proximity Warning UI
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Consumer<FishingMapsViewModel>(
                builder: (context, fishingMapsViewModel, child) {
                  if (!fishingMapsViewModel.isBorderProximityWarningActive) {
                    return const SizedBox.shrink();
                  }
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade200.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        lottie.Lottie.asset(
                          'assets/animations/warning.json',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Border Proximity Alert',
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'You are ${fishingMapsViewModel.currentBorderDistance.toStringAsFixed(2)} km from the maritime border.',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Route Details Card
          if (_optimizedRoute != null && _showRouteDetailsCard)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 320,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    margin: EdgeInsets.all(20),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Optimized Route',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      onPressed: () {
                                        setState(() {
                                          _showRouteDetailsCard = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Distance: ${_optimizedRoute!['distance_km'].toStringAsFixed(2)} km',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Time: ${_optimizedRoute!['estimated_time_hours'].toStringAsFixed(2)} hrs',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                if (_optimizedRoute!['fuel_saving_tips']
                                    .isNotEmpty) ...[
                                  SizedBox(height: 16),
                                  Text(
                                    'Fuel Saving Tips:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                          if (_optimizedRoute!['fuel_saving_tips'].isNotEmpty)
                            Flexible(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    ...(_optimizedRoute!['fuel_saving_tips']
                                            as List)
                                        .map(
                                          (tip) => Padding(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.lightbulb_outline,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    tip,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Find Hotspots Button
          if (_optimizedRoute == null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        _fishingMapsViewModel.isLoading || _isRouteLoading
                            ? (1.0 + _pulseAnimation.value * 0.1)
                            : 1.0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap:
                              _fishingMapsViewModel.isLoading || _isRouteLoading
                                  ? null
                                  : _findHotspots,
                          child: Center(
                            child:
                                _fishingMapsViewModel.isLoading ||
                                        _isRouteLoading
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Processing...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Find Fishing Hotspots',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Close Route Button
          if (_optimizedRoute != null && !_showRouteDetailsCard)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red[400]!,
                      Colors.red[600]!,
                    ], // Red gradient for "Close"
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      setState(() {
                        _optimizedRoute = null;
                        _routePolylines.clear();
                        _showRouteDetailsCard = false;
                      });
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Close Route',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(bottom: 250, right: 20, child: _buildZoomControls()),
          // My Location Button
          Positioned(
            bottom: 180,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_fishingMapsViewModel.currentLocation != null &&
                    _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLng(
                      _fishingMapsViewModel.currentLocation!,
                    ),
                  );
                }
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotBottomSheet(FishingHotspot hotspot) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getHotspotColor(
                              hotspot.probability,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.place,
                            color: _getHotspotColor(hotspot.probability),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fishing Hotspot',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(hotspot.probability * 100).toInt()}% Success Probability',
                                style: TextStyle(
                                  color: _getHotspotColor(hotspot.probability),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Description
                    _buildInfoSection(
                      'Description',
                      Icons.info_outline,
                      hotspot.description,
                    ),

                    SizedBox(height: 16),

                    // Weather Conditions
                    _buildInfoSection(
                      'Weather Conditions',
                      Icons.wb_sunny,
                      hotspot.weatherConditions,
                    ),

                    SizedBox(height: 16),

                    // Best Time to Fish
                    _buildInfoSection(
                      'Best Time to Fish',
                      Icons.access_time,
                      hotspot.bestTimeToFish,
                    ),

                    SizedBox(height: 16),

                    // Probable Species
                    if (hotspot.probableSpecies.isNotEmpty) ...[
                      _buildListSection(
                        'Probable Species',
                        FontAwesomeIcons.fish,
                        hotspot.probableSpecies,
                        Colors.blue,
                      ),
                      SizedBox(height: 16),
                    ],

                    // Precautions
                    if (hotspot.precautions.isNotEmpty) ...[
                      _buildListSection(
                        'Precautions',
                        Icons.warning,
                        hotspot.precautions,
                        Colors.orange,
                      ),
                      SizedBox(height: 20),
                    ],

                    // Navigate Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToHotspot(hotspot);
                          },
                          child: Center(
                            child: Text(
                              'Navigate to Hotspot',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(
    String title,
    IconData icon,
    List<String> items,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items
                  .map(
                    (item) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
