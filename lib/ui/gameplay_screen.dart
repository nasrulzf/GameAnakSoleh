import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import '../game/game_anak_soleh.dart';
import '../game/hud_overlay.dart';
import '../game/levels/level_1.dart';
import '../game/levels/level_2.dart';
import '../quiz/quiz_overlay.dart';
import 'level_result_screen.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final GameAnakSoleh _game;

  @override
  void initState() {
    super.initState();
    final gender = context.read<GameProgress>().gender ?? CharacterGender.boy;
    final level = widget.levelId == 1 ? buildLevel1() : buildLevel2();
    _game = GameAnakSoleh(level: level, gender: gender, onLevelComplete: _handleLevelComplete);
  }

  void _handleLevelComplete(int levelId) {
    final progress = context.read<GameProgress>();
    scheduleMicrotask(() async {
      await progress.completeLevel(levelId);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LevelResultScreen(levelId: levelId)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          Positioned.fill(
            child: ValueListenableBuilder(
              valueListenable: _game.activeQuestion,
              builder: (context, question, child) {
                if (question == null) return child!;
                return QuizOverlay(game: _game, question: question);
              },
              child: HudOverlay(game: _game),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: SafeArea(
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
