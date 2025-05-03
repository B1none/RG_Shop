import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab1_flutter_app/Other%20Screens/animated_menu.dart';
import '../Other Screens/catalog_screen.dart';
import '../Other Screens/cart_screen.dart';
import '../First screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Підтвердження'),
          content: const Text('Ви дійсно хочете вийти з акаунту?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Вийти'),
            ),
          ],
        ),
      );

      if (shouldLogout == true && mounted) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка при виході: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Головний екран'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Каталог'),
            Tab(text: 'Меню'),
            Tab(text: 'Кошик'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CatalogScreen(),
          AnimatedMenu(),
          CartScreen(),
        ],
      ),
    );
  }
}