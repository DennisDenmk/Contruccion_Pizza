import 'package:flutter/material.dart';
import 'dart:math' as math;

class PizzaLoading extends StatefulWidget {
  final double size;
  final Color color;

  const PizzaLoading({
    Key? key,
    this.size = 100.0,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  State<PizzaLoading> createState() => _PizzaLoadingState();
}

class _PizzaLoadingState extends State<PizzaLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107), // Color de masa
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CustomPaint(
              painter: PizzaPainter(color: widget.color),
            ),
          ),
        );
      },
    );
  }
}

class PizzaPainter extends CustomPainter {
  final Color color;

  PizzaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Dibujar las líneas de corte de la pizza
    final paint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Dibujar 8 porciones
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        paint,
      );
    }
    
    // Dibujar pepperoni
    final pepperoniPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Posiciones aleatorias pero fijas para los pepperoni
    final pepperoniPositions = [
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.4),
      Offset(center.dx + radius * 0.4, center.dy - radius * 0.2),
      Offset(center.dx - radius * 0.1, center.dy + radius * 0.3),
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.4),
      Offset(center.dx - radius * 0.4, center.dy - radius * 0.1),
    ];
    
    for (final position in pepperoniPositions) {
      canvas.drawCircle(position, radius * 0.1, pepperoniPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}