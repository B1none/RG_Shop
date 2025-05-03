import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Завантажуємо кошик при ініціалізації
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Кошик', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyCart()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item, cartProvider);
                    },
                  ),
          ),
          if (cartItems.isNotEmpty) _buildCheckoutPanel(cartProvider),
        ],
      ),
    );
  }
// При порожньому кошику
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, 
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('Ваш кошик порожній', 
              style: TextStyle(fontSize: 20, color: Colors.grey[600])),
          const SizedBox(height: 10),
          Text('Додайте товари з каталогу', 
              style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        ],
      ),
    );
  }
// Відображення товарів
  Widget _buildCartItem(Map<String, dynamic> item, CartProvider cartProvider) {
    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        cartProvider.removeFromCart(item['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['name']} видалено'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Картинка товару
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item['image'] ?? 'assets/images/placeholder.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              
              // Інформація про товар
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item['price'].toStringAsFixed(2)} грн',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildQuantitySelector(item, cartProvider),
                  ],
                ),
              ),
              
              // Ціна за кількість
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${(item['price'] * item['quantity']).toStringAsFixed(2)} грн',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(Map<String, dynamic> item, CartProvider cartProvider) {
    return Row(
      children: [
        // Кнопка зменшення кількості (-)
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            // Отримуємо поточну кількість та ID елемента кошика
            final currentQuantity = item['quantity'] as int;
            final cartItemId = item['id'] as String;

            // Викликаємо updateQuantity з новою кількістю (поточна - 1)
            // Provider сам видалить товар, якщо нова кількість буде 0
            Provider.of<CartProvider>(context, listen: false)
                .updateQuantity(cartItemId, currentQuantity - 1);
          },
        ),
        // Відображення поточної кількості
        Text('${item['quantity']}'),
        // Кнопка збільшення кількості (+)
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // Отримуємо поточну кількість та ID елемента кошика
            final currentQuantity = item['quantity'] as int;
            final cartItemId = item['id'] as String;

            // Викликаємо updateQuantity з новою кількістю (поточна + 1)
            Provider.of<CartProvider>(context, listen: false)
                .updateQuantity(cartItemId, currentQuantity + 1);
          },
        ),
      ],
    );
  }

  Widget _buildCheckoutPanel(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Всього товарів:', 
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                '${cartProvider.cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int))} шт',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('До сплати:', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '${cartProvider.totalPrice.toStringAsFixed(2)} грн',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox( // Кнопка Оформити Замовлення
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                cartProvider.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Замовлення оформлено!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Оформити замовлення',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}