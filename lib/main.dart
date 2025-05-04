import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Other Screens/cart_provider.dart';
import 'First screens/login_screen.dart';
import 'First screens/home_screen.dart';
import 'First screens/splash_screen.dart'; // Додано імпорт сплеш-скріна

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RG Shop',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey, // Оновлена основна тема
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(), // Сплеш-скрін як початковий екран
        routes: {
          '/splash': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
        },
        onGenerateRoute: (settings) {
          // Обробка неіснуючих маршрутів
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text('Сторінка не знайдена'),
              ),
            ),
          );
        },
      ),
    );
  }
}