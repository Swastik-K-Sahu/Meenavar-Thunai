import 'package:cloud_firestore/cloud_firestore.dart';

class FishCatchModel {
  final String id;
  final String fishSpecies;
  final double quantityInQuintal;
  final String netType;
  final DateTime timestamp;
  final bool isSustainable;
  final int pointsAwarded;

  FishCatchModel({
    required this.id,
    required this.fishSpecies,
    required this.quantityInQuintal,
    required this.netType,
    required this.timestamp,
    required this.isSustainable,
    required this.pointsAwarded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishSpecies': fishSpecies,
      'quantityInQuintal': quantityInQuintal,
      'netType': netType,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSustainable': isSustainable,
      'pointsAwarded': pointsAwarded,
    };
  }

  static FishCatchModel fromMap(Map<String, dynamic> map) {
    return FishCatchModel(
      id: map['id'],
      fishSpecies: map['fishSpecies'],
      quantityInQuintal: map['quantityInQuintal'],
      netType: map['netType'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isSustainable: map['isSustainable'],
      pointsAwarded: map['pointsAwarded'],
    );
  }
}
