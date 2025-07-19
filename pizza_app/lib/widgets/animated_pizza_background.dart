import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedPizzaBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedPizzaBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedPizzaBackground> createState() => _AnimatedPizzaBackgroundState();
}

class _AnimatedPizzaBackgroundState extends State<AnimatedPizzaBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<PizzaIcon> _pizzaIcons = [];
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Crear iconos de pizza aleatorios
    final random = math.Random();
    for (int i = 0; i < 10; i++) {
      _pizzaIcons.add(
        PizzaIcon(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 20 + random.nextDouble() * 30,
          angle: random.nextDouble() * math.pi * 2,
          rotationSpeed: 0.2 + random.nextDouble() * 0.5,
          floatSpeed: 0.2 + random.nextDouble() * 0.3,
          floatOffset: random.nextDouble() * math.pi * 2,
          type: random.nextInt(3), // 0: pizza, 1: queso, 2: tomate
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo con patrón de pizzería
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        
        // Iconos flotantes de pizza
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: _pizzaIcons.map((icon) {
                final floatY = math.sin(_controller.value * math.pi * 2 * icon.floatSpeed + icon.floatOffset) * 20;
                final rotation = _controller.value * math.pi * 2 * icon.rotationSpeed + icon.angle;
                
                return Positioned(
                  left: MediaQuery.of(context).size.width * icon.x,
                  top: MediaQuery.of(context).size.height * icon.y + floatY,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Opacity(
                      opacity: 0.1,
                      child: _buildIcon(icon),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        
        // Contenido principal
        widget.child,
      ],
    );
  }
  
  Widget _buildIcon(PizzaIcon icon) {
    switch (icon.type) {
      case 0:
        return Icon(Icons.local_pizza, size: icon.size, color: Colors.red.shade800);
      case 1:
        return Icon(Icons.circle, size: icon.size, color: Colors.amber.shade700);
      case 2:
        return Icon(Icons.circle, size: icon.size, color: Colors.red.shade600);
      default:
        return Icon(Icons.local_pizza, size: icon.size, color: Colors.red.shade800);
    }
  }
}

class PizzaIcon {
  final double x;
  final double y;
  final double size;
  final double angle;
  final double rotationSpeed;
  final double floatSpeed;
  final double floatOffset;
  final int type;
  
  PizzaIcon({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
    required this.rotationSpeed,
    required this.floatSpeed,
    required this.floatOffset,
    required this.type,
  });
}