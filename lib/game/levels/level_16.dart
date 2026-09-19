import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 16 - "Mengenal Tajwid Dasar": staircase lompat PANJANG (4 anak
/// tangga, tiap hop <=110px dari pijakan sebelumnya, aman di bawah batas
/// lompat) yang secara total naik hampir 400px dari tanah — murni lompat
/// berturutan, tanpa ladder, membuktikan staircase bisa jadi setinggi
/// lantai ladder kalau disusun bertahap. Turun lagi (jatuh bebas) sebelum
/// gate & goal terakhir di tanah.
LevelData buildLevel16() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.tajwidDasar]),
    5,
  );

  return LevelData(
    id: 16,
    title: 'Mengenal Tajwid Dasar',
    episode: 2,
    worldWidth: 4800,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      PlatformSpec(position: Vector2(1000, groundY - 90), size: Vector2(200, 32)),
      PlatformSpec(position: Vector2(1250, groundY - 200), size: Vector2(200, 32)),
      PlatformSpec(position: Vector2(1500, groundY - 300), size: Vector2(200, 32)),
      PlatformSpec(position: Vector2(1750, groundY - 390), size: Vector2(200, 32)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      // Rintangan di puncak staircase.
      ObstacleSpec(position: Vector2(1830, groundY - 390 - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3000, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(4000, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      // Di tiap anak tangga staircase.
      QuizGateSpec(
        position: Vector2(1050, groundY - 90 - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(1300, groundY - 200 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(1550, groundY - 300 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(2500, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      QuizGateSpec(
        position: Vector2(3500, groundY - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
    ],
    goalPosition: Vector2(4500, groundY - 210),
  );
}
