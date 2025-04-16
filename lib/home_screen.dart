import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'animated_menu.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Головний екран'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart), text: 'Каталог'),
              Tab(icon: Icon(Icons.menu), text: 'Меню'),
              Tab(icon: Icon(Icons.shopping_basket), text: 'Кошик'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CatalogScreen(),
            AnimatedMenu(),
            CartScreen(),
          ],
        ),
      ),
    );
  }
}