import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 4 - "Menyebrang dengan Doa": fokus pada doa-doa harian sebelum
/// beraktivitas. Dua segmen lantai atas terpisah (naik-turun-naik-turun) —
/// segmen pertama murni lompat, segmen kedua wajib ladder — supaya ritme
/// vertikalnya terasa beda dari level 1-3.
LevelData buildLevel4() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.doaHarian]),
    3,
  );

  return LevelData(
    id: 4,
    title: 'Menyebrang dengan Doa',
    episode: 1,
    worldWidth: 3600,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Segmen 1: lantai lompat (rise 130).
      PlatformSpec(position: Vector2(1000, groundY - 130), size: Vector2(220, 32)),
      // Segmen 2: lantai ladder (rise 230).
      PlatformSpec(position: Vector2(1900, groundY - 230), size: Vector2(280, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(1900, groundY - 230), size: Vector2(60, 230)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(1500, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2450, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3200, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      // Di lantai lompat segmen 1.
      QuizGateSpec(
        position: Vector2(1080, groundY - 130 - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai ladder segmen 2.
      QuizGateSpec(
        position: Vector2(2000, groundY - 230 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2900, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
    ],
    goalPosition: Vector2(3400, groundY - 210),
  );
}
