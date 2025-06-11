import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meenavar_thunai/secrets.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart' as lottie;
import '../../../models/fishing_hotspot.dart';
import '../../../core/services/hotspot_prediction_service.dart';
import '../../viewmodels/fishing_maps_viewmodel.dart';

class FishingMapsScreen extends StatefulWidget {
  const FishingMapsScreen({super.key});

  @override
  _FishingMapsScreenState createState() => _FishingMapsScreenState();
}

class _FishingMapsScreenState extends State<FishingMapsScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  // Location _location = Location();
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  List<FishingHotspot> _hotspots = [];
  // bool _isLoading = false;
  FishingHotspot? _selectedHotspot;

  late FishingMapsViewModel _fishingMapsViewModel;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _findHotspots() async {
    if (_fishingMapsViewModel.currentLocation == null) return;

    await _fishingMapsViewModel.findHotspots(
      centerLat: _fishingMapsViewModel.currentLocation!.latitude,
      centerLng: _fishingMapsViewModel.currentLocation!.longitude,
      radiusKm: 20.0,
    );

    setState(() {
      _circles.clear();
      _markers.clear();
      _createHotspotMarkers();
      if (_fishingMapsViewModel.hotspots.isNotEmpty) {
        _showHotspotsFoundSnackbar(_fishingMapsViewModel.hotspots.length);
      } else if (_fishingMapsViewModel.error != null) {
        _showErrorSnackbar(_fishingMapsViewModel.error!);
      }
    });
  }

  void _createHotspotMarkers() {
    setState(() {
      _circles.clear();
      _markers.clear();
      _fishingMapsViewModel.clearHotspots();
      for (int i = 0; i < _fishingMapsViewModel.hotspots.length; i++) {
        final hotspot = _fishingMapsViewModel.hotspots[i];
        final color = _getHotspotColor(hotspot.probability);

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
            radius: hotspot.radius * 1000, // Convert km to meters
            fillColor: color,
            strokeColor: color,
            strokeWidth: 2,
          ),
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Consumer<FishingMapsViewModel>(
            builder: (context, viewModel, child) {
              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target:
                      _currentPosition ?? LatLng(7.84725004878, 77.5753854671),
                  zoom: 10,
                ),
                markers: _markers,
                circles: _circles,
                polylines: viewModel.eezPolylines,
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
                        onTap: () => Navigator.pop(context),
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
                          'assets/animations/warning.json', // Ensure this path is correct
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

          // Find Hotspots Button
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      _fishingMapsViewModel.isLoading
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
                            _fishingMapsViewModel.isLoading
                                ? null
                                : _findHotspots,
                        child: Center(
                          child:
                              _fishingMapsViewModel.isLoading
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        'Finding Hotspots...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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

          // Hotspots Legend
          if (_fishingMapsViewModel.hotspots.isNotEmpty)
            Positioned(top: 100, right: 20, child: _buildHotspotsLegend()),
        ],
      ),
    );
  }

  Widget _buildHotspotsLegend() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hotspot Probability',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 8),
          _buildLegendItem(Colors.green, '80-100%'),
          _buildLegendItem(Colors.orange, '60-79%'),
          _buildLegendItem(Colors.yellow, '40-59%'),
          _buildLegendItem(Colors.red, '20-39%'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 10)),
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
        mainAxisSize: MainAxisSize.min, // Keep this as min
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
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(hotspot.latitude, hotspot.longitude),
                                15,
                              ),
                            );
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
