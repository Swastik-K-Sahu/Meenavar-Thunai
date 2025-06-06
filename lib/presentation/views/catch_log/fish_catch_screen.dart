import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/fish_catch_viewmodel.dart';
import '../../../core/widgets/sustainability_alert.dart';
import '../../../core/widgets/catch_detail_card.dart';

class FishCatchScreen extends StatefulWidget {
  const FishCatchScreen({super.key});

  @override
  _FishCatchScreenState createState() => _FishCatchScreenState();
}

class _FishCatchScreenState extends State<FishCatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFishSpecies;
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedNetType;

  @override
  void initState() {
    super.initState();
    // Prefetch data when screen loads
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<FishCatchViewModel>(
          context,
          listen: false,
        ).loadCatches(currentUser.uid);
      });
    }
  }

  void _submitCatch(BuildContext context) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to record a catch')),
      );
      return;
    }

    if (_formKey.currentState!.validate() &&
        _selectedFishSpecies != null &&
        _selectedNetType != null) {
      final viewModel = Provider.of<FishCatchViewModel>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging catch, please wait...')),
      );
      try {
        // Add catch
        FishCatchResult result = await viewModel.addCatch(
          userId: currentUser.uid,
          fishSpecies: _selectedFishSpecies!,
          quantityInQuintal: double.parse(_quantityController.text),
          netType: _selectedNetType!,
        );
        ScaffoldMessenger.of(context).clearSnackBars();

        if (result.success) {
          // Reset form
          setState(() {
            _selectedFishSpecies = null;
            _quantityController.clear();
            _selectedNetType = null;
          });

          // Show sustainability alert if there are warnings
          if (result.sustainabilityCheck != null &&
              result.sustainabilityCheck!.warnings.isNotEmpty) {
            showDialog(
              context: context,
              builder:
                  (context) => SustainabilityAlertDialog(
                    sustainabilityCheck: result.sustainabilityCheck!,
                  ),
            );
          } else {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Catch logged successfully! Points awarded: ${result.sustainabilityCheck?.pointsAwarded ?? 0}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to log catch: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddCatchDialog(BuildContext context) {
    final viewModel = Provider.of<FishCatchViewModel>(context, listen: false);
    setState(() {
      _selectedFishSpecies = null;
      _quantityController.clear();
      _selectedNetType = null;
    });
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text(
              'Log New Catch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fish Species Dropdown
                    _buildDropdown(
                      'Fish Species',
                      Icons.set_meal,
                      viewModel.fishSpecies,
                      _selectedFishSpecies,
                      (value) => setState(() => _selectedFishSpecies = value),
                    ),

                    // Quantity in Quintal
                    _buildTextField(
                      _quantityController,
                      'Quantity (quintal)',
                      Icons.scale,
                      isNumeric: true,
                    ),

                    // Net Type Dropdown
                    _buildDropdown(
                      'Net Type',
                      Icons.grid_on,
                      viewModel.netTypes,
                      _selectedNetType,
                      (value) => setState(() => _selectedNetType = value),
                    ),

                    // Date & Time (auto-filled)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            'Date & Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitCatch(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log Catch',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        value: selectedValue,
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please select $label';
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter $label';
          if (isNumeric && double.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Catch Log'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FishCatchViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                viewModel.catches.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sailing,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No catches logged yet!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the + button to record your first catch',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: viewModel.catches.length,
                      itemBuilder: (context, index) {
                        final catchData = viewModel.catches[index];
                        return CatchDetailCard(catchData: catchData);
                      },
                    ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCatchDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
}
