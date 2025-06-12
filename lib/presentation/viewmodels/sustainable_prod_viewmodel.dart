import 'package:flutter/material.dart';
import '../../models/sustainable_prod.dart';
import '../../../data/sustainable_prod_data.dart';

class SustainableProductsViewModel extends ChangeNotifier {
  List<SustainableProduct> _products = [];
  List<SustainableProduct> get products => _products;

  List<String> categories = [];
  String? selectedCategory;

  SustainableProductsViewModel() {
    _loadProducts();
  }

  void _loadProducts() {
    _products = SustainableProductsData.getSustainableProducts();

    Set<String> uniqueCategories = {'All'};
    for (var product in _products) {
      uniqueCategories.add(product.category);
    }

    categories = uniqueCategories.toList();
    selectedCategory = 'All';
    notifyListeners();
  }

  List<SustainableProduct> getFilteredProducts() {
    if (selectedCategory == null || selectedCategory == 'All') {
      return _products;
    }

    return _products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }
}
