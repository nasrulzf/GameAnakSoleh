import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 11 - "Hari Pertama di TPA": awal Episode 2, memperkenalkan lanjutan
/// huruf hijaiyah. Lantai lompat kecil (rise 140) untuk gate ke-2, goal
/// tetap di tanah.
LevelData buildLevel11() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.hijaiyah]),
    3,
  );

  return LevelData(
    id: 11,
    title: 'Hari Pertama di TPA',
    episode: 2,
    worldWidth: 3800,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      PlatformSpec(position: Vector2(1600, groundY - 140), size: Vector2(220, 32)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2200, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3150, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai lompat.
      QuizGateSpec(
        position: Vector2(1680, groundY - 140 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2700, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
    ],
    goalPosition: Vector2(3550, groundY - 210),
  );
}
