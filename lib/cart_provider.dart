import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(String name, double price) {
    _cartItems.add({'name': name, 'price': price});
    notifyListeners();
  }

  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item['price']);
}
