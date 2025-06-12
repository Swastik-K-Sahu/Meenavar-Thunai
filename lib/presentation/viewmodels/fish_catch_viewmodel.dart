import 'package:flutter/material.dart';
import '../../models/fish_catch_model.dart';
import '../../core/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class FishCatchViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<FishCatchModel> _catches = [];
  List<FishCatchModel> _monthlyCatches = [];

  List<FishCatchModel> get catches => _catches;

  // Monthly report getters
  int get monthlyEndangeredCount {
    return _monthlyCatches
        .where((Catch) => Catch.fishSpecies.contains('Tuna (Endangered)'))
        .length;
  }

  double get monthlyTotalQuantity {
    return _monthlyCatches.fold(
      0.0,
      (sum, Catch) => sum + Catch.quantityInQuintal,
    );
  }

  // Fish species list
  final List<String> fishSpecies = ['Tuna (Endangered)', 'Salmon', 'Cod'];

  // Net types
  final List<String> netTypes = ['Small', 'Medium', 'Large'];

  Future<void> loadCatches(String userId) async {
    _catches = await _firebaseService.fetchCatches(userId);
    notifyListeners();
  }

  Future<void> loadMonthlyData(String userId) async {
    _monthlyCatches = await _firebaseService.fetchMonthlyCatches(userId);
    notifyListeners();
  }

  Future<SustainabilityCheck> checkSustainability(
    String fishSpecies,
    double quantityInQuintal,
    String netType,
  ) {
    bool isEndangered = fishSpecies == 'Tuna (Endangered)';
    bool isOverfishing = quantityInQuintal > 8;
    bool isHarmfulNet = netType == 'Small';

    List<String> warnings = [];

    if (isEndangered) {
      warnings.add('You have caught an endangered species (Tuna).');
    }

    if (isOverfishing) {
      warnings.add('The quantity exceeds sustainable limits (8 quintals).');
    }

    if (isHarmfulNet) {
      warnings.add('Small nets can harm juvenile fish and other marine life.');
    }

    bool isSustainable = !isEndangered && !isOverfishing && !isHarmfulNet;
    int pointsAwarded = isSustainable ? 100 : 0;

    return Future.value(
      SustainabilityCheck(
        isSustainable: isSustainable,
        warnings: warnings,
        pointsAwarded: pointsAwarded,
      ),
    );
  }

  Future<FishCatchResult> addCatch({
    required String userId,
    required String fishSpecies,
    required double quantityInQuintal,
    required String netType,
  }) async {
    try {
      String id = const Uuid().v4();
      DateTime timestamp = DateTime.now();

      // Check sustainability
      SustainabilityCheck sustainabilityCheck = await checkSustainability(
        fishSpecies,
        quantityInQuintal,
        netType,
      );

      FishCatchModel newCatch = FishCatchModel(
        id: id,
        fishSpecies: fishSpecies,
        quantityInQuintal: quantityInQuintal,
        netType: netType,
        timestamp: timestamp,
        isSustainable: sustainabilityCheck.isSustainable,
        pointsAwarded: sustainabilityCheck.pointsAwarded,
      );

      await _firebaseService.addFishCatch(userId, newCatch);

      // Update both lists
      _catches.insert(0, newCatch);

      // Check if the new catch is from current month before adding to monthly catches
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime startOfNextMonth = DateTime(now.year, now.month + 1, 1);

      if (timestamp.isAtSameMomentAs(startOfMonth) ||
          timestamp.isAfter(startOfMonth) &&
              timestamp.isBefore(startOfNextMonth)) {
        _monthlyCatches.add(newCatch);
      }

      notifyListeners();

      return FishCatchResult(
        success: true,
        sustainabilityCheck: sustainabilityCheck,
        catchModel: newCatch,
      );
    } catch (e) {
      return FishCatchResult(success: false, error: e.toString());
    }
  }
}

class SustainabilityCheck {
  final bool isSustainable;
  final List<String> warnings;
  final int pointsAwarded;

  SustainabilityCheck({
    required this.isSustainable,
    required this.warnings,
    required this.pointsAwarded,
  });
}

class FishCatchResult {
  final bool success;
  final SustainabilityCheck? sustainabilityCheck;
  final FishCatchModel? catchModel;
  final String? error;

  FishCatchResult({
    required this.success,
    this.sustainabilityCheck,
    this.catchModel,
    this.error,
  });
}
