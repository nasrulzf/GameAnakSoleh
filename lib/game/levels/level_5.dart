import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 5 - "Bertemu Ustadz": campuran adab harian & rukun Islam. Sebagian
/// besar level di tanah, tapi diakhiri lantai atas panjang (rise 240) berisi
/// rintangan, gate terakhir, DAN goal — level pertama yang selesai di
/// lantai atas, bukan di tanah.
LevelData buildLevel5() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.adabHarian, QuizCategory.rukunIslam]),
    4,
  );

  return LevelData(
    id: 5,
    title: 'Bertemu Ustadz',
    episode: 1,
    worldWidth: 3900,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Lantai atas panjang menjelang akhir (rise 240, wajib ladder).
      PlatformSpec(position: Vector2(3300, groundY - 240), size: Vector2(500, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(3300, groundY - 240), size: Vector2(60, 240)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2700, groundY - 40), size: Vector2(40, 40)),
      // Rintangan di lantai atas itu sendiri, bukan lagi di tanah.
      ObstacleSpec(position: Vector2(3420, groundY - 240 - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(1950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      // Gate terakhir di lantai atas, sebelum goal.
      QuizGateSpec(
        position: Vector2(3520, groundY - 240 - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
    ],
    // Goal di lantai atas (rise 240) — akhir level ini "di atas", bukan di
    // tanah seperti level-level sebelumnya.
    goalPosition: Vector2(3650, groundY - 240 - 210),
  );
}
