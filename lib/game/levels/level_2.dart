import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 2 - "Perjalanan ke TPA": lebih panjang, ada platform layang & lebih
/// banyak rintangan, dengan 3 quiz gate yang sedikit lebih menantang.
LevelData buildLevel2() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([
      QuizCategory.rukunIman,
      QuizCategory.namaNabi,
      QuizCategory.hijaiyah,
      QuizCategory.malaikat,
    ]),
    3,
  );

  return LevelData(
    id: 2,
    title: 'Perjalanan ke TPA',
    worldWidth: 4200,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    // Tinggi platform (<=150) dijaga di bawah tinggi lompat maksimum pemain
    // (~180px, lihat PlayerComponent) supaya tetap bisa dijangkau dari tanah.
    platforms: [
      PlatformSpec(position: Vector2(1100, groundY - 110), size: Vector2(220, 32)),
      PlatformSpec(position: Vector2(1750, groundY - 150), size: Vector2(220, 32)),
      PlatformSpec(position: Vector2(3000, groundY - 130), size: Vector2(220, 32)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(650, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2300, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3600, groundY - 40), size: Vector2(40, 40)),
    ],
    // Tinggi gate (220) sengaja melebihi tinggi lompat maksimum supaya wajib
    // dijawab, bukan dilompati.
    quizGates: [
      QuizGateSpec(
        position: Vector2(1400, groundY - 220),
        size: Vector2(60, 220),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(2600, groundY - 220),
        size: Vector2(60, 220),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(3800, groundY - 220),
        size: Vector2(60, 220),
        question: questions[2],
      ),
    ],
    goalPosition: Vector2(4100, groundY - 120),
  );
}
