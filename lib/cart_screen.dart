import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Кошик')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartProvider.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Помилка: ${snapshot.error}'));
          }

          final cartItems = snapshot.data ?? [];

          // Розрахунок загальної суми з урахуванням кількості
          final totalPrice = cartItems.fold<double>(
            0.0,
            (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1))
          );

          return cartItems.isEmpty
              ? Center(child: Text('Кошик порожній'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Dismissible(
                            key: Key(item['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => cartProvider.removeFromCart(item['id']),
                            child: ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                '${item['price']} грн × ${item['quantity']} = ${item['price'] * item['quantity']} грн',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      final newQuantity = item['quantity'] - 1;
                                      cartProvider.updateQuantity(item['id'], newQuantity);
                                    },
                                  ),
                                  Text('${item['quantity']}'),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      final newQuantity = item['quantity'] + 1;
                                      cartProvider.updateQuantity(item['id'], newQuantity);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Загальна сума: ${totalPrice.toStringAsFixed(2)} грн',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ); // <-- Точка с запятой теперь здесь
        },
      ), // Закрывается FutureBuilder
    ); // Закрывается Scaffold
  }
}
