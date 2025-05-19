import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/fish_catch_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<FishCatchModel>> fetchCatches(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('catches')
              .orderBy('timestamp', descending: true)
              .get();

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

  Future<String?> uploadCatchImage(
    String userId,
    String catchId,
    File imageFile,
  ) async {
    try {
      final Reference storageRef = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('catches')
          .child('$catchId.jpg');

      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
