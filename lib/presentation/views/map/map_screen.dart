import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_styles.dart';
import '../../viewmodels/maps_viewmodel.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapsViewModel = Provider.of<MapsViewModel>(context, listen: false);
      mapsViewModel.initializeLocation();

      // Start periodic border proximity checks
      _startBorderProximityMonitoring();
    });
  }

  void _startBorderProximityMonitoring() {
    final mapsViewModel = Provider.of<MapsViewModel>(context, listen: false);

    // Check border proximity every 30 seconds
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (mounted) {
        mapsViewModel.checkBorderProximity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Coastal Maps',
          style: AppStyles.titleLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.layers_outlined, color: AppColors.textDark),
            onPressed: () {
              _showMapTypeDialog(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          Consumer<MapsViewModel>(
            builder: (context, mapsViewModel, child) {
              if (mapsViewModel.currentLocation == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return GoogleMap(
                mapType: mapsViewModel.mapType,
                initialCameraPosition: CameraPosition(
                  target: mapsViewModel.currentLocation!,
                  zoom: 14.0,
                ),
                onMapCreated: mapsViewModel.onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: mapsViewModel.markers,
                polylines: _createBorderPolylines(),
              );
            },
          ),

          // Border Proximity Warning
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Consumer<MapsViewModel>(
                builder: (context, mapsViewModel, child) {
                  if (!mapsViewModel.isBorderProximityWarningActive) {
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
                        Lottie.asset(
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
                                'You are ${mapsViewModel.currentBorderDistance.toStringAsFixed(2)} km from the maritime border.',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red.shade800),
                          onPressed: () {
                            final mapsViewModel = Provider.of<MapsViewModel>(
                              context,
                              listen: false,
                            );
                            mapsViewModel.checkBorderProximity();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_location_outlined),
        onPressed: () {
          final mapsViewModel = Provider.of<MapsViewModel>(
            context,
            listen: false,
          );
          _showAddMarkerDialog(context, mapsViewModel);
        },
      ),
    );
  }

  Set<Polyline> _createBorderPolylines() {
    return MapsViewModel.tamilNaduMaritimeBorders.map((border) {
      return Polyline(
        polylineId: PolylineId('border_${border.hashCode}'),
        color: Colors.red.withOpacity(0.5),
        width: 3,
        points: border,
      );
    }).toSet();
  }

  void _showMapTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Map Type', style: AppStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Normal'),
                onTap: () {
                  Navigator.pop(context);
                  _changeMapType(MapType.normal);
                },
              ),
              ListTile(
                title: const Text('Satellite'),
                onTap: () {
                  Navigator.pop(context);
                  _changeMapType(MapType.satellite);
                },
              ),
              ListTile(
                title: const Text('Hybrid'),
                onTap: () {
                  Navigator.pop(context);
                  _changeMapType(MapType.hybrid);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeMapType(MapType mapType) {
    final mapsViewModel = Provider.of<MapsViewModel>(context, listen: false);
    mapsViewModel.changeMapType(mapType);
  }

  void _showAddMarkerDialog(BuildContext context, MapsViewModel mapsViewModel) {
    final titleController = TextEditingController();
    final snippetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Marker', style: AppStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: snippetController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                mapsViewModel.addMarker(
                  mapsViewModel.currentLocation!,
                  titleController.text,
                  snippetController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
