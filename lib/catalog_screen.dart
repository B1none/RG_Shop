import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CatalogScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {'id': '1', 'name': 'Тапки Раяна Гослінга', 'price': 8999.0},
    {'id': '2', 'name': 'Бюст Раяна Гослінга', 'price': 3199.0},
    {'id': '3', 'name': 'Батарейки', 'price': 120.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Каталог товарів'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Draggable<Map<String, dynamic>>(
                  data: product,
                  feedback: Material(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(product['name'], style: TextStyle(color: Colors.grey)),
                      subtitle: Text('${product['price']} грн', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(product['name']),
                      subtitle: Text('${product['price']} грн'),
                      trailing: Icon(Icons.drag_handle),
                    ),
                  ),
                );
              },
            ),
          ),
          DragTarget<Map<String, dynamic>>(
            onWillAccept: (data) => true,
            onAccept: (product) async {
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              await cartProvider.addToCart(
                product['id'],
                product['name'],
                product['price'],
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product['name']} додано до кошика'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                height: 100,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty 
                      ? Colors.blue[100] 
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: candidateData.isNotEmpty 
                        ? Colors.blue 
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 32,
                        color: candidateData.isNotEmpty 
                            ? Colors.blue 
                            : Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        candidateData.isNotEmpty
                            ? 'Відпустіть, щоб додати'
                            : 'Перетягніть товар сюди',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: candidateData.isNotEmpty 
                              ? Colors.blue 
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}