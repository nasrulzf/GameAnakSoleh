import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 15 - "Surat-Surat Pendek": belajar nama & fakta dasar surat pendek
/// Juz Amma. Satu lantai ladder di tengah (rise 210) untuk gate ke-2, lalu
/// turun kembali ke tanah untuk sisa gate dan goal.
LevelData buildLevel15() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.namaSurat]),
    4,
  );

  return LevelData(
    id: 15,
    title: 'Surat-Surat Pendek',
    episode: 2,
    worldWidth: 4600,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      PlatformSpec(position: Vector2(1600, groundY - 210), size: Vector2(350, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(1600, groundY - 210), size: Vector2(60, 210)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2400, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3400, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(4200, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(1000, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai ladder.
      QuizGateSpec(
        position: Vector2(1700, groundY - 210 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2900, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(3900, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
    ],
    goalPosition: Vector2(4350, groundY - 210),
  );
}
