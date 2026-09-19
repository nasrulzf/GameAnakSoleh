import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 9 - "Pulang Sebelum Maghrib": campuran doa harian & rukun iman,
/// 5 quiz gate. Diakhiri lantai atas panjang (rise 250) berisi rintangan,
/// gate terakhir, DAN goal — level kedua (setelah Level 5) yang selesai di
/// lantai atas.
LevelData buildLevel9() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.doaHarian, QuizCategory.rukunIman]),
    5,
  );

  return LevelData(
    id: 9,
    title: 'Pulang Sebelum Maghrib',
    episode: 1,
    worldWidth: 4900,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Lantai lompat kecil di tengah (rise 130), untuk gate ke-2.
      PlatformSpec(position: Vector2(1400, groundY - 130), size: Vector2(220, 32)),
      // Lantai atas final (rise 250, wajib ladder).
      PlatformSpec(position: Vector2(4200, groundY - 250), size: Vector2(500, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(4200, groundY - 250), size: Vector2(60, 250)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(650, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1950, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2900, groundY - 40), size: Vector2(40, 40)),
      // Rintangan di lantai atas.
      ObstacleSpec(position: Vector2(4320, groundY - 250 - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(900, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai lompat tengah.
      QuizGateSpec(
        position: Vector2(1480, groundY - 130 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2400, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(3300, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      // Gate terakhir di lantai atas, sebelum goal.
      QuizGateSpec(
        position: Vector2(4420, groundY - 250 - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
    ],
    // Goal di lantai atas (rise 250).
    goalPosition: Vector2(4530, groundY - 250 - 210),
  );
}
