import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 7 - "Adab Makan Bersama": campuran adab harian & doa harian seputar
/// makan. Kombinasi staircase lompat (traversal) + 1 lantai ladder pendek
/// berisi gate ke-3 — variasi dari pola ladder-tunggal di level 3-5.
LevelData buildLevel7() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.adabHarian, QuizCategory.doaHarian]),
    4,
  );

  return LevelData(
    id: 7,
    title: 'Adab Makan Bersama',
    episode: 1,
    worldWidth: 4300,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Staircase lompat (rise 90 lalu 160) murni traversal.
      PlatformSpec(position: Vector2(1050, groundY - 90), size: Vector2(220, 32)),
      PlatformSpec(position: Vector2(1330, groundY - 160), size: Vector2(220, 32)),
      // Lantai ladder pendek (rise 210) berisi gate ke-3.
      PlatformSpec(position: Vector2(2500, groundY - 210), size: Vector2(280, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(2500, groundY - 210), size: Vector2(60, 210)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1800, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3100, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3900, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(820, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(2100, groundY - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      // Di lantai ladder.
      QuizGateSpec(
        position: Vector2(2600, groundY - 210 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(3500, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
    ],
    goalPosition: Vector2(4100, groundY - 210),
  );
}
