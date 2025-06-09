class FishingHotspot {
  final double latitude;
  final double longitude;
  final double probability;
  final String description;
  final List<String> probableSpecies;
  final String weatherConditions;
  final List<String> precautions;
  final String bestTimeToFish;
  final double radius; // in kilometers

  FishingHotspot({
    required this.latitude,
    required this.longitude,
    required this.probability,
    required this.description,
    required this.probableSpecies,
    required this.weatherConditions,
    required this.precautions,
    required this.bestTimeToFish,
    this.radius = 2.0,
  });

  factory FishingHotspot.fromJson(Map<String, dynamic> json) {
    return FishingHotspot(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      probability: json['probability'].toDouble(),
      description: json['description'] ?? '',
      probableSpecies: List<String>.from(json['probable_species'] ?? []),
      weatherConditions: json['weather_conditions'] ?? '',
      precautions: List<String>.from(json['precautions'] ?? []),
      bestTimeToFish: json['best_time_to_fish'] ?? '',
      radius: (json['radius'] ?? 2.0).toDouble(),
    );
  }
}
