class FishCatchModel {
  final String id;
  final String fishType;
  final double weight;
  final int quantity;
  final DateTime timestamp;

  FishCatchModel({
    required this.id,
    required this.fishType,
    required this.weight,
    required this.quantity,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishType': fishType,
      'weight': weight,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static FishCatchModel fromMap(Map<String, dynamic> map) {
    return FishCatchModel(
      id: map['id'],
      fishType: map['fishType'],
      weight: map['weight'],
      quantity: map['quantity'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
