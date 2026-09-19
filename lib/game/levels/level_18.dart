import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 18 - "Adab Membaca Al-Qur'an": campuran adab harian & nama surat.
/// Sebagian besar di tanah, diakhiri lantai atas panjang (rise 260) berisi
/// rintangan, DUA gate terakhir, dan goal — level ini selesai di lantai
/// atas, mirip level 5/9/12 tapi dengan 2 gate sekaligus di atas.
LevelData buildLevel18() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.adabHarian, QuizCategory.namaSurat]),
    5,
  );

  return LevelData(
    id: 18,
    title: 'Adab Membaca Al-Qur\'an',
    episode: 2,
    worldWidth: 4500,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Lantai atas final (rise 260, wajib ladder).
      PlatformSpec(position: Vector2(3700, groundY - 260), size: Vector2(600, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(3700, groundY - 260), size: Vector2(60, 260)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2700, groundY - 40), size: Vector2(40, 40)),
      // Rintangan di lantai atas.
      ObstacleSpec(position: Vector2(3800, groundY - 260 - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(2100, groundY - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(3100, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      // Dua gate terakhir di lantai atas, sebelum goal.
      QuizGateSpec(
        position: Vector2(3900, groundY - 260 - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      QuizGateSpec(
        position: Vector2(4020, groundY - 260 - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
    ],
    // Goal di lantai atas (rise 260).
    goalPosition: Vector2(4140, groundY - 260 - 210),
  );
}
