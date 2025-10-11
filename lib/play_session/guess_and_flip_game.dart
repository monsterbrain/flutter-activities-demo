
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

import '../game_internals/level_state.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class GuessAndFlipGame extends StatefulWidget {
  const GuessAndFlipGame({Key? key}) : super(key: key);

  @override
  _GuessAndFlipGameState createState() => _GuessAndFlipGameState();
}

class _GuessAndFlipGameState extends State<GuessAndFlipGame> {
  final List<Map<String, String>> _flashCards = const [
    {'flag': '🇺🇸', 'country': 'United States'},
    {'flag': '🇨🇦', 'country': 'Canada'},
    {'flag': '🇲🇽', 'country': 'Mexico'},
    {'flag': '🇧🇷', 'country': 'Brazil'},
    {'flag': '🇦🇷', 'country': 'Argentina'},
    {'flag': '🇬🇧', 'country': 'United Kingdom'},
    {'flag': '🇫🇷', 'country': 'France'},
    {'flag': '🇩🇪', 'country': 'Germany'},
    {'flag': '🇮🇹', 'country': 'Italy'},
    {'flag': '🇪🇸', 'country': 'Spain'},
    {'flag': '🇯🇵', 'country': 'Japan'},
    {'flag': '🇨🇳', 'country': 'China'},
    {'flag': '🇮🇳', 'country': 'India'},
    {'flag': '🇦🇺', 'country': 'Australia'},
    {'flag': '🇿🇦', 'country': 'South Africa'},
  ];

  late PageController _pageController;
  double _currentPage = 0.0;
  final List<bool> _isFlipped = List.filled(15, false);
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapCount++;
    if (_tapCount == 3) {
      context.read<LevelState>().onWin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _flashCards.length,
              itemBuilder: (context, index) {
                final scale = 1.0 - (_currentPage - index).abs() * 0.3;
                return Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFlipped[index] = !_isFlipped[index];
                      });
                      _handleTap();
                    },
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(
                          begin: 0, end: _isFlipped[index] ? math.pi : 0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double val, _) {
                        final isFlipped = val >= math.pi / 2;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateY(val),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: isFlipped
                                  ? (Matrix4.identity()..rotateY(math.pi))
                                  : Matrix4.identity(),
                              child: Center(
                                child: isFlipped
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            _flashCards[index]['country']!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : FractionallySizedBox(
                                        widthFactor: 0.5,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            _flashCards[index]['flag']!,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Guess the country of the flag. Tap to flip.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
