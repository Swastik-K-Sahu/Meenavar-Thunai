import 'package:flutter/material.dart';
import '../../models/fish_catch_model.dart';
import '../../core/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class FishCatchViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<FishCatchModel> _catches = [];

  List<FishCatchModel> get catches => _catches;

  Future<void> loadCatches(String userId) async {
    _catches = await _firebaseService.fetchCatches(userId);
    notifyListeners();
  }

  Future<void> addCatch(
    String userId,
    String fishType,
    double weight,
    int quantity,
  ) async {
    String id = Uuid().v4();
    FishCatchModel newCatch = FishCatchModel(
      id: id,
      fishType: fishType,
      weight: weight,
      quantity: quantity,
      timestamp: DateTime.now(),
    );

    await _firebaseService.addFishCatch(userId, newCatch);
    _catches.add(newCatch);
    notifyListeners();
  }
}
