import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 8 - "Menolong Teman": adab tolong-menolong, 5 quiz gate. Level
/// terpanjang Episode 1 — 2 lantai ladder terpisah (naik-turun-naik-turun)
/// dengan gate tersebar di kedua lantai, goal tetap di tanah.
LevelData buildLevel8() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.adabHarian]),
    5,
  );

  return LevelData(
    id: 8,
    title: 'Menolong Teman',
    episode: 1,
    worldWidth: 4600,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Lantai ladder 1 (rise 200).
      PlatformSpec(position: Vector2(1300, groundY - 200), size: Vector2(280, 32)),
      // Lantai ladder 2 (rise 230).
      PlatformSpec(position: Vector2(2700, groundY - 230), size: Vector2(280, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(1300, groundY - 200), size: Vector2(60, 200)),
      LadderSpec(position: Vector2(2700, groundY - 230), size: Vector2(60, 230)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(650, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1900, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3300, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(4100, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(850, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai ladder 1.
      QuizGateSpec(
        position: Vector2(1400, groundY - 200 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2200, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      // Di lantai ladder 2.
      QuizGateSpec(
        position: Vector2(2800, groundY - 230 - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      QuizGateSpec(
        position: Vector2(3700, groundY - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
    ],
    goalPosition: Vector2(4420, groundY - 210),
  );
}
