class BoatType {
  final String name;
  final double averageSpeedKmh; // km/h
  final double fuelConsumptionRate; // liters per km
  final String description;

  BoatType({
    required this.name,
    required this.averageSpeedKmh,
    required this.fuelConsumptionRate,
    required this.description,
  });

  static List<BoatType> getCommonTamilNaduBoats() {
    return [
      BoatType(
        name: 'Vallam (Small Wooden Boat)',
        averageSpeedKmh: 15.0,
        fuelConsumptionRate: 0.5,
        description: 'Traditional small boat, good for nearshore fishing.',
      ),
      BoatType(
        name: 'Mechanized Trawler',
        averageSpeedKmh: 25.0,
        fuelConsumptionRate: 1.2,
        description: 'Larger boat for deep-sea fishing, higher fuel use.',
      ),
      BoatType(
        name: 'Fiber Boat with Outboard Motor',
        averageSpeedKmh: 20.0,
        fuelConsumptionRate: 0.8,
        description: 'Lightweight, versatile for coastal waters.',
      ),
    ];
  }
}
