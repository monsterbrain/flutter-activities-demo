import 'dart:ui';

import 'package:flutter/material.dart';

class ColoringGame extends StatefulWidget {
  const ColoringGame({super.key});

  @override
  State<ColoringGame> createState() => _ColoringGameState();
}

class _ColoringGameState extends State<ColoringGame> {
  Color selectedColor = Colors.blue;
  double strokeWidth = 10.0;
  List<DrawingPoint?> points = [];

  final List<Color> colors = [
    Colors.pink,
    Colors.red,
    Colors.black,
    Colors.yellow,
    Colors.amber,
    Colors.green,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                points = List.from(points)
                  ..add(
                    DrawingPoint(
                      offset: details.localPosition,
                      paint: Paint()
                        ..color = selectedColor
                        ..strokeWidth = strokeWidth
                        ..strokeCap = StrokeCap.round,
                    ),
                  );
              });
            },
            onPanEnd: (_) => setState(() => points.add(null)),
            child: CustomPaint(
              painter: DrawingPainter(points: points),
              child: Container(),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colors.map((color) => _buildColorChoice(color)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorChoice(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        height: isSelected ? 40 : 30,
        width: isSelected ? 40 : 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  const DrawingPainter({required this.points});
  final List<DrawingPoint?> points;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
            points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
            PointMode.points, [points[i]!.offset], points[i]!.paint);
      } else if (points.length == 1 && points[i] != null) {
        canvas.drawPoints(
            PointMode.points, [points[i]!.offset], points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => oldDelegate.points != points;
}

class DrawingPoint {
  const DrawingPoint({required this.offset, required this.paint});
  final Offset offset;
  final Paint paint;
}
