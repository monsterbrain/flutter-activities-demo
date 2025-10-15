
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/level_state.dart';

class MatchingGame extends StatefulWidget {
  const MatchingGame({super.key});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  // Game data
  final List<String> _vehicles = ['🚗', '🚌', '🚲'];
  final List<String> _originalVehicleNames = ['Car', 'Bus', 'Bike'];
  late List<String> _shuffledVehicleNames;

  // State variables
  String? _selectedVehicle;
  final List<int?> _vehicleNameMatchState = [null, null, null]; // null=unmatched, vehicleIndex=matched
  int _score = 0;
  final List<List<int>> _matchedPairsIndices = []; // [[vehicleIndex, shuffledNameIndex], ...]

  // Keys for positioning
  final List<GlobalKey> _vehicleIconKeys = List.generate(3, (_) => GlobalKey());
  final List<GlobalKey> _vehicleNameKeys = List.generate(3, (_) => GlobalKey());
  final GlobalKey _paintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _shuffledVehicleNames = List.from(_originalVehicleNames)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final levelState = context.watch<LevelState>();

    return Stack(
      key: _paintKey,
      children: [
        // The game UI
        Column(
          children: [
            const Text(
              'Match the Vehicles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Vehicle Icons Column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _vehicles.asMap().entries.map((entry) {
                      int index = entry.key;
                      String vehicle = entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVehicle = vehicle;
                          });
                        },
                        child: Container(
                          key: _vehicleIconKeys[index],
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedVehicle == vehicle
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Text(vehicle, style: const TextStyle(fontSize: 40)),
                        ),
                      );
                    }).toList(),
                  ),
                  // Vehicle Names Column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _shuffledVehicleNames.asMap().entries.map((entry) {
                      int shuffledIndex = entry.key;
                      String name = entry.value;
                      bool isMatched = _vehicleNameMatchState[shuffledIndex] != null;

                      return GestureDetector(
                        onTap: () => _handleNameTap(name, shuffledIndex, levelState),
                        child: Container(
                          key: _vehicleNameKeys[shuffledIndex],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMatched ? Colors.green.withOpacity(0.3) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(name, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Custom painter for drawing lines, wrapped in an IgnorePointer
        IgnorePointer(
          child: CustomPaint(
            painter: LinePainter(
              paintKey: _paintKey,
              vehicleIconKeys: _vehicleIconKeys,
              vehicleNameKeys: _vehicleNameKeys,
              matchedPairs: _matchedPairsIndices,
            ),
            size: Size.infinite,
          ),
        )
      ],
    );
  }

  void _handleNameTap(String name, int shuffledIndex, LevelState levelState) {
    // Don't do anything if a vehicle isn't selected or the name is already matched
    if (_selectedVehicle == null || _vehicleNameMatchState[shuffledIndex] != null) return;

    int correctVehicleIndex = _originalVehicleNames.indexOf(name);
    if (_vehicles[correctVehicleIndex] == _selectedVehicle) {
      // It's a match!
      setState(() {
        _score++;
        _vehicleNameMatchState[shuffledIndex] = correctVehicleIndex;
        _matchedPairsIndices.add([correctVehicleIndex, shuffledIndex]);
        _selectedVehicle = null; // Reset selection

        levelState.setProgress(_score);
        if (_score == _vehicles.length) {
          levelState.evaluate();
        }
      });
    }
  }
}

class LinePainter extends CustomPainter {
  final GlobalKey paintKey;
  final List<GlobalKey> vehicleIconKeys;
  final List<GlobalKey> vehicleNameKeys;
  final List<List<int>> matchedPairs; // [[vehicleIndex, shuffledNameIndex], ...]

  LinePainter({
    required this.paintKey,
    required this.vehicleIconKeys,
    required this.vehicleNameKeys,
    required this.matchedPairs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0;

    final paintRenderBox = paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (paintRenderBox == null) return;

    for (final pair in matchedPairs) {
      final vehicleIndex = pair[0];
      final nameIndex = pair[1];

      final iconKey = vehicleIconKeys[vehicleIndex];
      final nameKey = vehicleNameKeys[nameIndex];

      final iconRenderBox = iconKey.currentContext?.findRenderObject() as RenderBox?;
      final nameRenderBox = nameKey.currentContext?.findRenderObject() as RenderBox?;

      if (iconRenderBox != null && nameRenderBox != null) {
        // Get the center of the icon widget in global coordinates
        final iconCenter = iconRenderBox.localToGlobal(iconRenderBox.size.center(Offset.zero));
        // Get the center of the name widget in global coordinates
        final nameCenter = nameRenderBox.localToGlobal(nameRenderBox.size.center(Offset.zero));

        // Convert the global coordinates to the local coordinate system of the CustomPaint widget
        final localIconCenter = paintRenderBox.globalToLocal(iconCenter);
        final localNameCenter = paintRenderBox.globalToLocal(nameCenter);

        canvas.drawLine(localIconCenter, localNameCenter, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    // Repaint whenever the matched pairs change
    return oldDelegate.matchedPairs != matchedPairs;
  }
}
