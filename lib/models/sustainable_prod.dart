class SustainableProduct {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final double cost;
  final String buyLink;
  final int sustainabilityRating; // 1-5 scale
  final String category;

  SustainableProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.cost,
    required this.buyLink,
    required this.sustainabilityRating,
    required this.category,
  });
}
