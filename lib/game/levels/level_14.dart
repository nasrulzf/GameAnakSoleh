import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 14 - "Tanda Baca Al-Qur'an": belajar harakat (fathah/kasrah/dhommah/
/// sukun/tanwin). Ritme naik-turun-naik-turun: mulai di platform (rise 120),
/// turun, naik ladder (rise 230), turun, naik lompat (rise 150), turun ke
/// goal — kombinasi motif lompat & ladder paling bervariasi sejauh ini.
LevelData buildLevel14() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.harakat]),
    4,
  );

  return LevelData(
    id: 14,
    title: 'Tanda Baca Al-Qur\'an',
    episode: 2,
    worldWidth: 4400,
    worldHeight: 720,
    groundHeight: 80,
    // Mulai di atas platform start (rise 120), bukan di tanah.
    playerStart: Vector2(80, groundY - 120 - 60),
    platforms: [
      PlatformSpec(position: Vector2(0, groundY - 120), size: Vector2(300, 32)),
      PlatformSpec(position: Vector2(1400, groundY - 230), size: Vector2(350, 32)),
      PlatformSpec(position: Vector2(2700, groundY - 150), size: Vector2(220, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(1400, groundY - 230), size: Vector2(60, 230)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(600, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2200, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3300, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(4000, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      // Di platform start.
      QuizGateSpec(
        position: Vector2(150, groundY - 120 - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai ladder.
      QuizGateSpec(
        position: Vector2(1500, groundY - 230 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      // Di lantai lompat.
      QuizGateSpec(
        position: Vector2(2780, groundY - 150 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(3700, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
    ],
    goalPosition: Vector2(4150, groundY - 210),
  );
}
