import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0.0;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  double get totalPrice => _totalPrice;

  User? get currentUser => _auth.currentUser;

  // Завантаження кошика при ініціалізації
  Future<void> loadCart() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      final cartSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .orderBy('createdAt', descending: true)
          .get();

      _cartItems = cartSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'productId': data['productId'],
          'name': data['name'] ?? 'Без назви',
          'price': (data['price'] as num?)?.toDouble() ?? 0.0,
          'quantity': (data['quantity'] as int?) ?? 1,
          'image': data['image'] ?? 'assets/images/placeholder.png',
          'createdAt': data['createdAt']?.toDate(),
        };
      }).toList();

      _calculateTotalPrice();
      notifyListeners();
    } catch (e) {
      print('Помилка завантаження кошика: $e');
    }
  }

  // Додавання товару в кошик
  Future<void> addToCart({
    required String productId,
    required String name,
    required double price,
    required String image,
  }) async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      // Перевірка на наявність товару в кошику
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item['productId'] == productId,
      );

      if (existingItemIndex != -1) {
        // Оновлення кількості існуючого товару
        await _updateCartItem(
          _cartItems[existingItemIndex]['id'],
          _cartItems[existingItemIndex]['quantity'] + 1,
        );
      } else {
        // Додавання нового товару
        final docRef = await _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .add({
          'productId': productId,
          'name': name,
          'price': price,
          'image': image,
          'quantity': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _cartItems.insert(0, {
          'id': docRef.id,
          'productId': productId,
          'name': name,
          'price': price,
          'image': image,
          'quantity': 1,
          'createdAt': DateTime.now(),
        });

        _calculateTotalPrice();
        notifyListeners();
      }
    } catch (e) {
      print('Помилка додавання товару: $e');
      throw Exception('Не вдалося додати товар до кошика');
    }
  }

  // Видалення товару з кошика (за ID документа Firestore)
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(cartItemId)
          .delete();

      _cartItems.removeWhere((item) => item['id'] == cartItemId);
      _calculateTotalPrice();
      notifyListeners();
    } catch (e) {
      print('Помилка видалення товару: $e');
      throw Exception('Не вдалося видалити товар з кошика');
    }
  }

  // Оновлення кількості товару (або видалення, якщо newQuantity < 1)
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity < 1) {
        // Якщо нова кількість менше 1, видаляємо товар
        await removeFromCart(cartItemId);
        return;
      }

      // Інакше оновлюємо кількість
      await _updateCartItem(cartItemId, newQuantity);
    } catch (e) {
      print('Помилка оновлення кількості: $e');
      throw Exception('Не вдалося оновити кількість товару');
    }
  }

  // Приватний метод для оновлення товару в кошику у Firestore та локально
  Future<void> _updateCartItem(String cartItemId, int quantity) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(cartItemId)
        .update({
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final itemIndex = _cartItems.indexWhere((item) => item['id'] == cartItemId);
    if (itemIndex != -1) {
      _cartItems[itemIndex]['quantity'] = quantity;
      _calculateTotalPrice();
      notifyListeners();
    }
  }

  // Підрахунок загальної суми
  void _calculateTotalPrice() {
    _totalPrice = _cartItems.fold(0.0, (sum, item) {
      return sum + ((item['price'] as num) * (item['quantity'] as int));
    });
  }

  // Очищення кошика після оформлення замовлення
  Future<void> clearCart() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      final batch = _firestore.batch();
      final cartCollection = _firestore
          .collection('users')
          .doc(uid)
          .collection('cart');

      for (final item in _cartItems) {
        batch.delete(cartCollection.doc(item['id']));
      }

      await batch.commit();
      _cartItems.clear();
      _totalPrice = 0.0;
      notifyListeners();
    } catch (e) {
      print('Помилка очищення кошика: $e');
      throw Exception('Не вдалося очистити кошик');
    }
  }
}
