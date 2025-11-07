
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../style/palette.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

// A data class for the prayer items
class Prayer {
  final String name;
  final IconData icon;

  Prayer({required this.name, required this.icon});
}

class PrayerSequenceGame extends StatefulWidget {
  const PrayerSequenceGame({super.key});

  @override
  State<PrayerSequenceGame> createState() => _PrayerSequenceGameState();
}

class _PrayerSequenceGameState extends State<PrayerSequenceGame> {
  // The correct order of prayers
  static const List<String> _correctOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  // The list of prayer objects
  final List<Prayer> _prayerItems = [
    Prayer(name: 'Fajr', icon: Icons.wb_sunny_outlined),
    Prayer(name: 'Dhuhr', icon: Icons.wb_sunny_outlined),
    Prayer(name: 'Asr', icon: Icons.wb_sunny_outlined),
    Prayer(name: 'Maghrib', icon: Icons.nightlight_round_outlined),
    Prayer(name: 'Isha', icon: Icons.nightlight_round_outlined),
  ];

  // The shuffled list that the user interacts with
  late List<Prayer> _shuffledPrayers;

  // To track which items are correctly placed
  late List<bool> _isCorrectlyPlaced;

  bool _isGameWon = false;

  @override
  void initState() {
    super.initState();
    _shuffledPrayers = List.from(_prayerItems)..shuffle();
    _isCorrectlyPlaced = List.generate(_prayerItems.length, (index) => false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOrder();
    });
  }

  void _checkOrder() {
    if (!mounted) return;

    bool allCorrect = true;
    for (int i = 0; i < _shuffledPrayers.length; i++) {
      if (_shuffledPrayers[i].name == _correctOrder[i]) {
        if (!_isCorrectlyPlaced[i]) {
          setState(() {
            _isCorrectlyPlaced[i] = true;
          });
        }
      } else {
        if (_isCorrectlyPlaced[i]) {
          setState(() {
            _isCorrectlyPlaced[i] = false;
          });
        }
        allCorrect = false;
      }
    }

    if (allCorrect && !_isGameWon) {
      setState(() {
        _isGameWon = true;
      });
      _winGame();
    }
  }

  void _winGame() {
    final levelState = context.read<LevelState>();
    levelState.setProgress(levelState.goal);
    levelState.evaluate();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: const Color(0xFF3AA2B2), // Soft teal like the image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny, color: Colors.yellow[600], size: 30),
            const SizedBox(width: 8),
            const Text(
              '5 Daily Prayers',
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              buildDefaultDragHandles: false,
              onReorder: (int oldIndex, int newIndex) {
                if (_isGameWon) return;
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Prayer item = _shuffledPrayers.removeAt(oldIndex);
                  _shuffledPrayers.insert(newIndex, item);

                  // Reorder the correctness tracker as well
                  final bool correctStatus = _isCorrectlyPlaced.removeAt(oldIndex);
                  _isCorrectlyPlaced.insert(newIndex, correctStatus);
                });
                _checkOrder();
              },
              children: List.generate(_shuffledPrayers.length, (index) {
                final prayer = _shuffledPrayers[index];
                final isCorrect = _isCorrectlyPlaced[index];

                return ReorderableDragStartListener(
                  key: ValueKey(prayer.name),
                  index: index,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    color: isCorrect ? Colors.green.shade100 : const Color(0xFFFEF9E7), // Cream color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: const Color(0xFF6D4C41), width: 2), // Brown outline
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      leading: Icon(prayer.icon, color: prayer.icon == Icons.wb_sunny_outlined ? Colors.orange : Colors.blue.shade800, size: 30),
                      title: Text(
                        prayer.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6D4C41), // Brown text
                        ),
                      ),
                      trailing: isCorrect
                          ? Icon(Icons.check_circle, color: Colors.green.shade700, size: 30)
                          : const Icon(Icons.pan_tool),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
