import 'package:flutter/material.dart';

class AnimatedMenu extends StatefulWidget {
  @override
  _AnimatedMenuState createState() => _AnimatedMenuState();
}

class _AnimatedMenuState extends State<AnimatedMenu> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Ініціалізація контролера анімації
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Анімація масштабу
    _scaleAnimation = Tween<double>(begin: 1.05, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value, // Параметр масштабування
                child: Image.asset( 
                  'assets/RG_Shop.png',
                  width: 400,
                  height: 400,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            '',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}