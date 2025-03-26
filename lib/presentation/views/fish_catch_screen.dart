import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../viewmodels/fish_catch_viewmodel.dart';

class FishCatchScreen extends StatefulWidget {
  const FishCatchScreen({super.key});

  @override
  _FishCatchScreenState createState() => _FishCatchScreenState();
}

class _FishCatchScreenState extends State<FishCatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fishTypeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  void _submitCatch(BuildContext context) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to record a catch')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<FishCatchViewModel>(context, listen: false);
      String fishType = _fishTypeController.text;
      double weight = double.parse(_weightController.text);
      int quantity = int.parse(_quantityController.text);

      viewModel.addCatch(currentUser.uid, fishType, weight, quantity);

      _fishTypeController.clear();
      _weightController.clear();
      _quantityController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Catch logged successfully!')));
    }
  }

  void _showAddCatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Log New Catch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    _fishTypeController,
                    'Fish Type',
                    Icons.anchor,
                  ),
                  _buildTextField(
                    _weightController,
                    'Weight (kg)',
                    Icons.scale,
                    isNumeric: true,
                  ),
                  _buildTextField(
                    _quantityController,
                    'Quantity',
                    Icons.format_list_numbered,
                    isNumeric: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitCatch(context);
                  Navigator.pop(context);
                },
                child: Text('Log Catch'),
              ),
            ],
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
      appBar: AppBar(title: Text('Fish Catch Log')),
      body: Consumer<FishCatchViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                viewModel.catches.isEmpty
                    ? Center(
                      child: Text(
                        'No catches logged yet!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: viewModel.catches.length,
                      itemBuilder: (context, index) {
                        final catchData = viewModel.catches[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(
                              Icons.anchor,
                              color: Colors.blueAccent,
                              size: 32,
                            ),
                            title: Text(
                              catchData.fishType,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${catchData.weight} kg | ${catchData.quantity} pcs\n'
                              '${DateFormat('dd MMM yyyy, hh:mm a').format(catchData.timestamp.toLocal())}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCatchDialog(context),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}
