
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/level_state.dart';

class MatchingGame extends StatefulWidget {
  const MatchingGame({super.key});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  final GlobalKey _stackKey = GlobalKey();
  final List<GlobalKey> _vehicleKeys = List.generate(3, (_) => GlobalKey());
  final List<GlobalKey> _nameKeys = List.generate(3, (_) => GlobalKey());
  final List<String> _vehicles = ['🚗', '🚌', '🚲'];
  final List<String> _vehicleNames = ['Car', 'Bus', 'Bike'];
  String? _selectedVehicle;
  Offset? _startPoint;
  Offset? _endPoint;
  final List<List<Offset>> _lines = [];
  final List<bool> _isMatched = [false, false, false];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _vehicleNames.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final levelState = context.watch<LevelState>();

    return Stack(
      key: _stackKey,
      children: [
        Column(
          children: [
            const Text(
              'Match the Vehicles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: _vehicles.asMap().entries.map((entry) {
                int index = entry.key;
                String vehicle = entry.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVehicle = vehicle;
                      final RenderBox stackBox = _stackKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final RenderBox vehicleBox = _vehicleKeys[index]
                          .currentContext!
                          .findRenderObject() as RenderBox;
                      _startPoint = stackBox.globalToLocal(vehicleBox
                          .localToGlobal(vehicleBox.size.center(Offset.zero)));
                    });
                  },
                  child: Container(
                    key: _vehicleKeys[index],
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedVehicle == vehicle
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      vehicle,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                );
              }).toList(),
            ),
            Column(
              children: _vehicleNames.asMap().entries.map((entry) {
                int index = entry.key;
                String name = entry.value;
                return GestureDetector(
                  onTap: () {
                    if (_selectedVehicle != null && !_isMatched[index]) {
                      int correctIndex = _vehicles.indexOf(_selectedVehicle!);
                      if (_vehicleNames[index] ==
                          ['Car', 'Bus', 'Bike'][correctIndex]) {
                        setState(() {
                          final RenderBox stackBox = _stackKey.currentContext!
                              .findRenderObject() as RenderBox;
                          final RenderBox nameBox = _nameKeys[index]
                              .currentContext!
                              .findRenderObject() as RenderBox;
                          _endPoint = stackBox.globalToLocal(nameBox
                              .localToGlobal(nameBox.size.center(Offset.zero)));
                          _lines.add([_startPoint!, _endPoint!]);
                          _isMatched[index] = true;
                          _score++;
                          _selectedVehicle = null;
                          _startPoint = null;
                          _endPoint = null;
                        });

                        levelState.setProgress(_score);

                        if (_score == _vehicles.length) {
                          levelState.evaluate();
                        }
                      }
                    }
                  },
                  child: Container(
                    key: _nameKeys[index],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isMatched[index] ? Colors.grey : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        CustomPaint(
          painter: LinePainter(lines: _lines),
          child: Container(),
        ),
      ],
    );
  }
}

class LinePainter extends CustomPainter {
  final List<List<Offset>> lines;

  LinePainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var line in lines) {
      if (line.length == 2) {
        final path = Path();
        path.moveTo(line[0].dx, line[0].dy);
        final controlPoint1 = Offset(line[0].dx + (line[1].dx - line[0].dx) * 0.5, line[0].dy);
        final controlPoint2 = Offset(line[1].dx - (line[1].dx - line[0].dx) * 0.5, line[1].dy);
        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, line[1].dx, line[1].dy);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.lines != lines;
  }
}
