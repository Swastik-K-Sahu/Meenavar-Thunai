// lib/data/sustainable_products_data.dart
import '../models/sustainable_prod.dart';

class SustainableProductsData {
  static List<SustainableProduct> getSustainableProducts() {
    return [
      SustainableProduct(
        id: '1',
        name: 'Biodegradable Fishing Net',
        imageUrl: 'assets/images/biodegradable_net.png',
        description:
            'Made from natural fibers that decompose within 2 years if lost at sea, reducing ghost fishing impact.',
        cost: 1200.00,
        buyLink: 'https://example.com/buy/biodegradable_net',
        sustainabilityRating: 5,
        category: 'Nets',
      ),
      SustainableProduct(
        id: '2',
        name: 'LED Fishing Lights',
        imageUrl: 'assets/images/led_lights.png',
        description:
            'Solar-powered LED lights that reduce bycatch by attracting only target species.',
        cost: 850.00,
        buyLink: 'https://example.com/buy/led_lights',
        sustainabilityRating: 4,
        category: 'Accessories',
      ),
      SustainableProduct(
        id: '3',
        name: 'Escape Gap Trap',
        imageUrl: 'assets/images/escape_gap_trap.png',
        description:
            'Allows juvenile fish and non-target species to escape, improving selectivity.',
        cost: 1500.00,
        buyLink: 'https://example.com/buy/escape_gap_trap',
        sustainabilityRating: 5,
        category: 'Traps',
      ),
      SustainableProduct(
        id: '4',
        name: 'Turtle Excluder Device',
        imageUrl: 'assets/images/turtle_excluder.png',
        description:
            'Prevents accidental capture of sea turtles while maintaining target catch.',
        cost: 1800.00,
        buyLink: 'https://example.com/buy/turtle_excluder',
        sustainabilityRating: 5,
        category: 'Accessories',
      ),
      SustainableProduct(
        id: '5',
        name: 'Circle Hooks Set',
        imageUrl: 'assets/images/circle_hooks.png',
        description:
            'Reduces deep hooking and injury to fish, allowing safe release of non-target species.',
        cost: 350.00,
        buyLink: 'https://example.com/buy/circle_hooks',
        sustainabilityRating: 4,
        category: 'Hooks',
      ),
      SustainableProduct(
        id: '6',
        name: 'Sustainable Bait Container',
        imageUrl: 'assets/images/bait_container.png',
        description:
            'Reusable bait container made from recycled ocean plastic.',
        cost: 280.00,
        buyLink: 'https://example.com/buy/bait_container',
        sustainabilityRating: 3,
        category: 'Accessories',
      ),
      SustainableProduct(
        id: '7',
        name: 'Eco-Friendly Fishing Line',
        imageUrl: 'assets/images/eco_line.png',
        description:
            'Biodegradable fishing line that maintains strength but breaks down after extended exposure.',
        cost: 420.00,
        buyLink: 'https://example.com/buy/eco_line',
        sustainabilityRating: 4,
        category: 'Lines',
      ),
      SustainableProduct(
        id: '8',
        name: 'Solar GPS Fish Finder',
        imageUrl: 'assets/images/solar_gps.png',
        description:
            'Energy-efficient fish finder that uses solar power to reduce battery waste.',
        cost: 3200.00,
        buyLink: 'https://example.com/buy/solar_gps',
        sustainabilityRating: 3,
        category: 'Electronics',
      ),
    ];
  }
}
