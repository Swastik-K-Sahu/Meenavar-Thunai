import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fish_catch_model.dart';

class FirebaseService {
  final CollectionReference catchReportCollection = FirebaseFirestore.instance
      .collection('catch_report');

  Future<void> addFishCatch(String userId, FishCatchModel fishCatch) async {
    try {
      DocumentReference userDoc = catchReportCollection.doc(
        'rhinoYR0FnlffQX82We5',
      );

      await userDoc.update({
        'catches': FieldValue.arrayUnion([fishCatch.toMap()]),
      });
    } catch (e) {
      print('Error adding fish catch: $e');
    }
  }

  Future<List<FishCatchModel>> fetchCatches(String userId) async {
    try {
      DocumentSnapshot doc =
          await catchReportCollection.doc('rhinoYR0FnlffQX82We5').get();

      if (doc.exists) {
        List<dynamic> catches = doc['catches'] ?? [];
        return catches.map((data) => FishCatchModel.fromMap(data)).toList();
      }
    } catch (e) {
      print('Error fetching catches: $e');
    }
    return [];
  }
}
