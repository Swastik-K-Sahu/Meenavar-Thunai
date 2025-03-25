import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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
      body: Consumer<MapsViewModel>(
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
          );
        },
      ),
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
