import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 3 - "Adab di Jalan": memperkenalkan kategori soal adab harian saat
/// pemain berjalan menuju TPA. Ladder interaktif pertama di game — pemain
/// panjat ke lantai atas (rise 220, di luar jangkauan lompat) untuk gate
/// ke-2, lalu turun lagi lewat anak tangga sebelum kembali ke tanah.
LevelData buildLevel3() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.adabHarian]),
    3,
  );

  return LevelData(
    id: 3,
    title: 'Adab di Jalan',
    episode: 1,
    worldWidth: 3400,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Lantai atas (rise 220, wajib pakai ladder) tempat gate ke-2.
      PlatformSpec(position: Vector2(1500, groundY - 220), size: Vector2(300, 32)),
      // Anak tangga turun (rise 90) sebelum balik ke tanah.
      PlatformSpec(position: Vector2(1950, groundY - 90), size: Vector2(220, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(1500, groundY - 220), size: Vector2(60, 220)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2350, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2700, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(1000, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai atas — pemain harus panjat ladder untuk mencapainya.
      QuizGateSpec(
        position: Vector2(1650, groundY - 220 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(3050, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
    ],
    goalPosition: Vector2(3200, groundY - 210),
  );
}
