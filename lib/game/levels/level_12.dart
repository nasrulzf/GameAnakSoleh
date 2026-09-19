import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 12 - "Mengenal Huruf Sambung": belajar huruf hijaiyah sambung.
/// Diakhiri lantai ladder (rise 220) berisi rintangan, gate terakhir, DAN
/// goal — level ini selesai di lantai atas.
LevelData buildLevel12() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.hijaiyahSambung]),
    3,
  );

  return LevelData(
    id: 12,
    title: 'Mengenal Huruf Sambung',
    episode: 2,
    worldWidth: 3700,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Lantai atas final (rise 220, wajib ladder).
      PlatformSpec(position: Vector2(3000, groundY - 220), size: Vector2(500, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(3000, groundY - 220), size: Vector2(60, 220)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(800, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1800, groundY - 40), size: Vector2(40, 40)),
      // Rintangan di lantai atas.
      ObstacleSpec(position: Vector2(3080, groundY - 220 - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(1150, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(2200, groundY - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      // Gate terakhir di lantai atas, sebelum goal.
      QuizGateSpec(
        position: Vector2(3200, groundY - 220 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
    ],
    // Goal di lantai atas.
    goalPosition: Vector2(3340, groundY - 220 - 210),
  );
}
