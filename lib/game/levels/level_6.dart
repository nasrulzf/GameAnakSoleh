import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 6 - "Belajar Wudhu Kecil": adab bersuci sederhana untuk anak.
/// Pemain MULAI di lantai yang agak tinggi (rise 150) lalu turun bertahap
/// ke tanah — arah vertikal kebalikan dari level-level sebelumnya yang
/// selalu mulai dari tanah.
LevelData buildLevel6() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.adabHarian]),
    4,
  );

  return LevelData(
    id: 6,
    title: 'Belajar Wudhu Kecil',
    episode: 1,
    worldWidth: 4100,
    worldHeight: 720,
    groundHeight: 80,
    // Mulai di atas platform start (bukan langsung di tanah).
    playerStart: Vector2(80, groundY - 150 - 60),
    platforms: [
      // Platform start, tinggi (rise 150).
      PlatformSpec(position: Vector2(0, groundY - 150), size: Vector2(300, 32)),
      // Anak tangga turun (rise 70) sebelum ke tanah.
      PlatformSpec(position: Vector2(350, groundY - 70), size: Vector2(220, 32)),
      // Lantai lompat kecil di tengah level (rise 110) untuk gate ke-2.
      PlatformSpec(position: Vector2(1650, groundY - 110), size: Vector2(220, 32)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(650, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2100, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3100, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3650, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      // Gate pertama langsung di platform start.
      QuizGateSpec(
        position: Vector2(150, groundY - 150 - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(1730, groundY - 110 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2650, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(3800, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
    ],
    goalPosition: Vector2(3900, groundY - 210),
  );
}
