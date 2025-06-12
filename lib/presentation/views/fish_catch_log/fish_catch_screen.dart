import 'package:flutter/material.dart';
import 'package:meenavar_thunai/theme/app_colors.dart';
import 'package:meenavar_thunai/theme/app_styles.dart';
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

  // Add a loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available and avoid rebuilding during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // Centralized data loading function
  Future<void> _loadData() async {
    // Set loading state to true
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final viewModel = Provider.of<FishCatchViewModel>(context, listen: false);
      // Load both recent catches and monthly data
      await viewModel.loadCatches(currentUser.uid);
      await viewModel.loadMonthlyData(currentUser.uid);
    } else {
      // Handle case where user is not logged in
      print('User not logged in. Cannot load fish catches.');
      // Optionally show a message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your catches.')),
        );
      }
    }

    // Set loading state to false after data is loaded
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitCatch(BuildContext context) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to record a fish catch')),
      );
      return;
    }

    if (_formKey.currentState!.validate() &&
        _selectedFishSpecies != null &&
        _selectedNetType != null) {
      final viewModel = Provider.of<FishCatchViewModel>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging fish catch, please wait...')),
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
                  'Fish Catch logged successfully! Points awarded: ${result.sustainabilityCheck?.pointsAwarded ?? 0}',
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
                      (value) {
                        if (mounted)
                          setState(() => _selectedFishSpecies = value);
                      },
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
                      (value) {
                        if (mounted) setState(() => _selectedNetType = value);
                      },
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
                  Navigator.pop(
                    context,
                  ); // Dismiss the dialog after submission attempt
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

  Widget _buildMonthlyReport(FishCatchViewModel viewModel) {
    // Check if _monthlyCatches is null or empty before calculating total quantity
    // and endangered count to avoid potential errors if data hasn't loaded yet.
    int monthlyEndangeredCount = viewModel.monthlyEndangeredCount;
    double monthlyTotalQuantity = viewModel.monthlyTotalQuantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Monthly Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildIndicator(
                title: 'Endangered Species Catch',
                icon: Icons.warning,
                current: monthlyEndangeredCount, // Use calculated value
                maximum: 10,
                threshold: 6,
              ),
              const SizedBox(height: 12),
              _buildIndicator(
                title: 'Total Fish Catch (Quintal)',
                icon: Icons.catching_pokemon,
                current: monthlyTotalQuantity.toInt(), // Use calculated value
                maximum: 100,
                threshold: 60,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required String title,
    required IconData icon,
    required int current,
    required int maximum,
    required int threshold,
  }) {
    bool isExceeded = current > maximum;
    bool isOverThreshold = current > threshold;
    Color indicatorColor = isOverThreshold ? Colors.red : Colors.green;
    double progress = isExceeded ? 1.0 : current / maximum;
    // Handle division by zero for progress if maximum is 0
    if (maximum == 0) progress = 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: indicatorColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isExceeded ? 'Limit Exceeded for this Month' : '$current',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: indicatorColor,
                ),
              ),
              Text(
                '/$maximum',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Threshold: $threshold',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Max: $maximum',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fish Catch Log',
          style: AppStyles.titleMedium.copyWith(
            color: AppColors.lightGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<FishCatchViewModel>(
        builder: (context, viewModel, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Report Section
                _buildMonthlyReport(viewModel),

                // Latest Fish Catches Section
                Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Latest Fish Catches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Catches List
                Expanded(
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
                                  'No fish catches logged yet!',
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
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCatchDialog(context),
        backgroundColor: AppColors.primary,
        tooltip: 'Add Fish Catch',
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
