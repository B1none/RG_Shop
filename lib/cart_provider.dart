import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return [];

      final cartSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();

      return cartSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Без назви',
          'price': (data['price'] as num?)?.toDouble() ?? 0.0,
          'quantity': (data['quantity'] as int?) ?? 1, // Додано значення за замовчуванням
        };
      }).toList();
    } catch (e) {
      print('Помилка отримання товарів: $e');
      return [];
    }
  }

  Future<void> addToCart(String productId, String name, double price) async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      // Перевіряємо чи товар вже є в кошику
      final existingItem = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Якщо товар є - збільшуємо кількість
        await existingItem.docs.first.reference.update({
          'quantity': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Якщо товару немає - додаємо новий
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .add({
          'productId': productId,
          'name': name,
          'price': price,
          'quantity': 1, // Додаємо поле quantity
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
    } catch (e) {
      print('Помилка додавання товару: $e');
    }
  }

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

      notifyListeners();
    } catch (e) {
      print('Помилка видалення товару: $e');
    }
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return;

      if (newQuantity > 0) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc(cartItemId)
            .update({
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await removeFromCart(cartItemId);
      }

      notifyListeners();
    } catch (e) {
      print('Помилка оновлення кількості: $e');
    }
  }
}