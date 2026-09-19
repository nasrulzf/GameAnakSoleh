import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 19 - "Lomba Hafalan Kecil": campuran nama surat & hijaiyah, 6 quiz
/// gate. Menggabungkan KEDUA motif lantai atas dalam satu level — satu
/// lantai lompat (2 gate sekaligus) dan satu lantai ladder terpisah — bukan
/// cuma satu motif seperti level-level sebelumnya.
LevelData buildLevel19() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.namaSurat, QuizCategory.hijaiyah]),
    6,
  );

  return LevelData(
    id: 19,
    title: 'Lomba Hafalan Kecil',
    episode: 2,
    worldWidth: 5000,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Lantai lompat (rise 140) berisi 2 gate sekaligus.
      PlatformSpec(position: Vector2(1400, groundY - 140), size: Vector2(300, 32)),
      // Lantai ladder terpisah (rise 230).
      PlatformSpec(position: Vector2(2600, groundY - 230), size: Vector2(350, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(2600, groundY - 230), size: Vector2(60, 230)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2100, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3300, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(4100, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Dua gate di lantai lompat.
      QuizGateSpec(
        position: Vector2(1450, groundY - 140 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(1580, groundY - 140 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      // Di lantai ladder.
      QuizGateSpec(
        position: Vector2(2700, groundY - 230 - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      QuizGateSpec(
        position: Vector2(3700, groundY - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
      QuizGateSpec(
        position: Vector2(4500, groundY - 70),
        size: Vector2(80, 70),
        question: questions[5],
      ),
    ],
    goalPosition: Vector2(4750, groundY - 210),
  );
}
