import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': '1',
      'name': 'Тапки Раяна Гослінга',
      'price': 8999.0,
      'image': 'assets/ryan_slippers.jpg'
    },
    {
      'id': '2',
      'name': 'Бюст Раяна Гослінга',
      'price': 3199.0,
      'image': 'assets/ryan_bust.jpg'
    },
    {
      'id': '3',
      'name': 'Батарейки',
      'price': 120.0,
      'image': 'assets/battery.jpg'
    },
    {
      'id': '4',
      'name': 'Докімакура Раян Гослінг',
      'price': 120000.0,
      'image': 'assets/Big_RG.webp'
    },
    {
      'id': '5',
      'name': 'Докімакура Друг Раян Гослінг',
      'price': 14000.0,
      'image': 'assets/BigBeer.jpg'
    },
    {
      'id': '6',
      'name': 'Раян Гослінг на застілля (1 Година)',
      'price': 40000.0,
      'image': 'assets/Chill.jpg'
    },
    {
      'id': '7',
      'name': 'Новорічна подушка з Раяном Гослінгом',
      'price': 3000.0,
      'image': 'assets/CristmassRG.jpg'
    },
    {
      'id': '8',
      'name': 'Червоний костюм Раяна Гослінга',
      'price': 21999.0,
      'image': 'assets/RedShweps.jpg'
    },
    {
      'id': '9',
      'name': 'Привітання на замовлення',
      'price': 4999.0,
      'image': 'assets/RGBirthday.jpg'
    },
    {
      'id': '10',
      'name': 'Іграшка "Машинка Раян Гослінг"',
      'price': 799.0,
      'image': 'assets/RGCar.jpg'
    },
    {
      'id': '11',
      'name': 'Подушка "Раян Гослінг Сігма"',
      'price': 2299.0,
      'image': 'assets/RGGeneral.jpg'
    },
    {
      'id': '12',
      'name': 'Іграшка "Раян Гослінг Міньйон"',
      'price': 1299.0,
      'image': 'assets/RGMinion.jpg'
    },
    {
      'id': '13',
      'name': 'Жовтий костюм Раяна Гослінга',
      'price': 22999.0,
      'image': 'assets/Shweps.jpg'
    },
    {
      'id': '14',
      'name': 'Подушка "Справжній Сігма"',
      'price': 9999.0,
      'image': 'assets/TrueRG.jpg'
    },
  ];

  List<Map<String, dynamic>> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final name = product['name'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Каталог товарів'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 219, 223, 224),
      ),
      body: Column(
        children: [
          // Пошукове поле
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Пошук товарів...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'Товарів не знайдено',
                          style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder( // Вдображення товарів (Ліст)
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Draggable<Map<String, dynamic>>(
                        data: product,
                        feedback: Material(
                          child: Container(
                            width: 200,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[800]!.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                              )],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    product['image'],
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _buildProductCard(product),
                        ),
                        child: _buildProductCard(product),
                      );
                    },
                  ),
          ),
          _buildDragTarget(context),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${product['price']} грн',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.drag_handle,
              color: Colors.blueGrey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragTarget(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAccept: (product) async {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.addToCart(
          productId: product['id'],
          name: product['name'],     
          price: product['price'],   
          image: product['image'],   
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name']} додано до кошика'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 120,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? Colors.blueGrey[100] 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty 
                  ? Colors.blueGrey[800]! 
                  : Colors.grey,
              width: 2,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: 36,
                  color: candidateData.isNotEmpty 
                      ? Colors.blueGrey[800] 
                      : Colors.grey[600],
                ),
                SizedBox(height: 8),
                Text(
                  candidateData.isNotEmpty
                      ? 'Відпустіть, щоб додати'
                      : 'Перетягніть товар сюди',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: candidateData.isNotEmpty 
                        ? Colors.blueGrey[800] 
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}