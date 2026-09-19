import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 10 - "Ujian Ngaji Pertama" (boss Episode 1): soal campuran seluruh
/// kategori yang sudah dipelajari di Level 1-9. Finale Episode 1: kombinasi
/// staircase lompat + lantai ladder tengah + lantai atas panjang di ujung
/// (rise 280, tertinggi sejauh ini) tempat goal berada — "puncak" perjalanan
/// episode ini.
LevelData buildLevel10() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([
      QuizCategory.rukunIslam,
      QuizCategory.rukunIman,
      QuizCategory.doaHarian,
      QuizCategory.namaNabi,
      QuizCategory.hijaiyah,
      QuizCategory.malaikat,
      QuizCategory.adabHarian,
    ]),
    5,
  );

  return LevelData(
    id: 10,
    title: 'Ujian Ngaji Pertama',
    episode: 1,
    worldWidth: 5500,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Staircase lompat (rise 100 lalu 170) murni traversal.
      PlatformSpec(position: Vector2(1500, groundY - 100), size: Vector2(220, 32)),
      PlatformSpec(position: Vector2(1780, groundY - 170), size: Vector2(220, 32)),
      // Lantai ladder tengah (rise 210) berisi gate ke-3.
      PlatformSpec(position: Vector2(3000, groundY - 210), size: Vector2(280, 32)),
      // Lantai atas final (rise 280, tertinggi di Episode 1) — goal di sini.
      PlatformSpec(position: Vector2(4600, groundY - 280), size: Vector2(700, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(3000, groundY - 210), size: Vector2(60, 210)),
      LadderSpec(position: Vector2(4600, groundY - 280), size: Vector2(60, 280)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2100, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3600, groundY - 40), size: Vector2(40, 40)),
      // Rintangan di lantai atas final.
      ObstacleSpec(position: Vector2(4750, groundY - 280 - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(2500, groundY - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      // Di lantai ladder tengah.
      QuizGateSpec(
        position: Vector2(3100, groundY - 210 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(4000, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      // Gate terakhir di lantai atas final, sebelum goal.
      QuizGateSpec(
        position: Vector2(4900, groundY - 280 - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
    ],
    // Goal di puncak lantai atas final (rise 280) — finale Episode 1.
    goalPosition: Vector2(5100, groundY - 280 - 210),
  );
}
