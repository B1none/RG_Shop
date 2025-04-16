import 'package:flutter/material.dart';
import '/database_helper.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Map<String, dynamic>> products = [];

  void loadProducts() async {
    products = await DatabaseHelper.instance.getProducts();
    setState(() {});
  }

  void addProduct(String name) async {
    await DatabaseHelper.instance.insertProduct(name);
    loadProducts();
  }

  void deleteProduct(int id) async {
    await DatabaseHelper.instance.deleteProduct(id);
    loadProducts();
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('Каталог товарів')),
      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Додати товар'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                addProduct(controller.text);
                controller.clear();
              }
            },
            child: Text('Додати'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(products[i]['name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteProduct(products[i]['id']),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
