// lib/data/sustainable_products_data.dart
import '../models/sustainable_prod.dart';

class SustainableProductsData {
  static List<SustainableProduct> getSustainableProducts() {
    return [
      SustainableProduct(
        id: '1',
        name: 'Biodegradable Fishing Net',
        imageUrl: 'assets/images/fishing_net.jpg',
        description:
            'Made from natural fibers that decompose within 2 years if lost at sea, reducing ghost fishing impact.',
        cost: 1200.00,
        buyLink: 'https://example.com/buy/biodegradable_net',
        sustainabilityRating: 5,
        category: 'Nets',
      ),

      SustainableProduct(
        id: '3',
        name: 'Escape Gap Trap',
        imageUrl: 'assets/images/escape_gap.jpg',
        description:
            'Allows juvenile fish and non-target species to escape, improving selectivity.',
        cost: 1500.00,
        buyLink: 'https://example.com/buy/escape_gap_trap',
        sustainabilityRating: 5,
        category: 'Traps',
      ),

      SustainableProduct(
        id: '5',
        name: 'Circle Hooks Set',
        imageUrl: 'assets/images/hook_set.jpg',
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
        imageUrl: 'assets/images/bait_container.jpg',
        description:
            'Reusable bait container made from recycled ocean plastic.',
        cost: 280.00,
        buyLink: 'https://example.com/buy/bait_container',
        sustainabilityRating: 3,
        category: 'Accessories',
      ),
    ];
  }
}
