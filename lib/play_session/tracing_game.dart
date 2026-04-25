
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracing_game/tracing_game.dart';

import '../game_internals/level_state.dart';

class TracingGameScreen extends StatefulWidget {
  const TracingGameScreen({super.key});

  @override
  State<TracingGameScreen> createState() => _TracingGameScreenState();
}

class _TracingGameScreenState extends State<TracingGameScreen> {
  @override
  Widget build(BuildContext context) {
    final levelState = context.watch<LevelState>();

    return TracingCharsGame(
      showAnchor: true,
      traceShapeModel: [
        TraceCharsModel(chars: [
          TraceCharModel(
            char: 'A',
            traceShapeOptions:
                const TraceShapeOptions(innerPaintColor: Colors.orange),
          ),
          TraceCharModel(
            char: 'B',
            traceShapeOptions:
                const TraceShapeOptions(innerPaintColor: Colors.orange),
          ),
        ])
      ],
      onGameFinished: (int screenIndex) async {
        levelState.setProgress(levelState.goal);
      },
    );
  }
}
