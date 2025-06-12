import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/fish_catch_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FishCatchModel>> fetchCatches(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('catches')
              .orderBy('timestamp', descending: true)
              .limit(4)
              .get();
      print('Fetched ${snapshot.docs.length} recent catches for user $userId');
      return snapshot.docs
          .map(
            (doc) => FishCatchModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching catches: $e');
      return [];
    }
  }

  Future<List<FishCatchModel>> fetchMonthlyCatches(String userId) async {
    try {
      // Get the start and end of current month
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime startOfNextMonth = DateTime(now.year, now.month + 1, 1);

      print(
        'Fetching monthly catches from ${startOfMonth.toString()} to ${startOfNextMonth.toString()}',
      );

      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('catches')
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
              )
              .where(
                'timestamp',
                isLessThan: Timestamp.fromDate(startOfNextMonth),
              )
              .get();

      print('Found ${snapshot.docs.length} catches for current month');

      List<FishCatchModel> monthlyCatches =
          snapshot.docs
              .map(
                (doc) =>
                    FishCatchModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      // Debug print
      for (var Catch in monthlyCatches) {
        print(
          'Monthly catch: ${Catch.fishSpecies}, quantity: ${Catch.quantityInQuintal}, date: ${Catch.timestamp}',
        );
      }

      return monthlyCatches;
    } catch (e) {
      print('Error fetching monthly catches: $e');
      return [];
    }
  }

  Future<void> addFishCatch(String userId, FishCatchModel fishCatch) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('catches')
          .doc(fishCatch.id)
          .set(fishCatch.toMap());
    } catch (e) {
      print('Error adding fish catch: $e');
      rethrow;
    }
  }

  Future<int> fetchTotalSustainabilityPoints(String userId) async {
    try {
      int totalPoints = 0;
      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('catches')
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('pointsAwarded') && data['pointsAwarded'] is int) {
          totalPoints += data['pointsAwarded'] as int;
        } else {
          print(
            'Warning: Document ${doc.id} does not have a valid "pointsAwarded" field or it\'s not an integer.',
          );
        }
      }
      print(
        'Fetched total sustainability points for user $userId: $totalPoints',
      );
      return totalPoints;
    } catch (e) {
      print('Error fetching total sustainability points: $e');
      return 0;
    }
  }
}
