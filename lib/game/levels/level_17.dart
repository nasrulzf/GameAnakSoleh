import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 17 - "Melompati Rintangan Ilmu": memperkenalkan platform bergerak
/// horizontal — dua "pulau" melayang (rise 130, sejajar tinggi) dihubungkan
/// bukan lewat staircase statis, tapi lewat platform yang bolak-balik;
/// pemain harus menunggu & melompat saat platformnya dekat. Pengalaman
/// timing yang belum pernah ada di level manapun sebelumnya.
LevelData buildLevel17() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.harakat, QuizCategory.tajwidDasar]),
    5,
  );

  return LevelData(
    id: 17,
    title: 'Melompati Rintangan Ilmu',
    episode: 2,
    worldWidth: 4600,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Pulau keberangkatan & kedatangan (sejajar tinggi, rise 130).
      PlatformSpec(position: Vector2(1300, groundY - 130), size: Vector2(200, 32)),
      PlatformSpec(position: Vector2(2200, groundY - 130), size: Vector2(250, 32)),
      // Lantai lompat kecil menjelang goal (rise 150).
      PlatformSpec(position: Vector2(3600, groundY - 150), size: Vector2(220, 32)),
    ],
    movingPlatforms: [
      MovingPlatformSpec(
        position: Vector2(1550, groundY - 130),
        size: Vector2(140, 32),
        travelDistance: 500,
        speed: 80,
      ),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3500, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di pulau keberangkatan.
      QuizGateSpec(
        position: Vector2(1360, groundY - 130 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      // Di pulau kedatangan, setelah naik platform bergerak.
      QuizGateSpec(
        position: Vector2(2280, groundY - 130 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(3100, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      QuizGateSpec(
        position: Vector2(3680, groundY - 150 - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
    ],
    goalPosition: Vector2(4300, groundY - 210),
  );
}
