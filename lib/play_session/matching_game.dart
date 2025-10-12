
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/level_state.dart';

class MatchingGame extends StatefulWidget {
  const MatchingGame({super.key});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  final List<String> _vehicles = ['🚗', '🚌', '🚲'];
  final List<String> _vehicleNames = ['Car', 'Bus', 'Bike'];
  String? _selectedVehicle;
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

    return Column(
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
              children: _vehicles.map((vehicle) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVehicle = vehicle;
                    });
                  },
                  child: Container(
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
                      if (_vehicleNames[index] == ['Car', 'Bus', 'Bike'][correctIndex]) {
                        setState(() {
                          _isMatched[index] = true;
                          _score++;
                          _selectedVehicle = null;
                        });

                        levelState.setProgress(_score);

                        if (_score == _vehicles.length) {
                          levelState.evaluate();
                        }
                      }
                    }
                  },
                  child: Container(
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
      ],
    );
  }
}
