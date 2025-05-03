import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E7D32), // Темно-зелений
              Color(0xFF37474F), // Синьо-сірий
              Color(0xFF263238), // Темний синьо-сірий
            ],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RG\nSHOP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    height: 0.9, // Відстань між рядками
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}