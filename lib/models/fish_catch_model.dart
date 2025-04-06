class FishCatchModel {
  final String id;
  final String fishSpecies;
  final double quantityInQuintal;
  final String netType;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isSustainable;
  final int pointsAwarded;

  FishCatchModel({
    required this.id,
    required this.fishSpecies,
    required this.quantityInQuintal,
    required this.netType,
    required this.timestamp,
    this.imageUrl,
    required this.isSustainable,
    required this.pointsAwarded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishSpecies': fishSpecies,
      'quantityInQuintal': quantityInQuintal,
      'netType': netType,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
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
      timestamp: DateTime.parse(map['timestamp']),
      imageUrl: map['imageUrl'],
      isSustainable: map['isSustainable'],
      pointsAwarded: map['pointsAwarded'],
    );
  }
}
