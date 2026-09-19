import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 20 - "Ujian Kenaikan TPA" (boss Episode 2): soal campuran seluruh
/// kategori Episode 2. Finale yang memakai SEMUA motif lantai sejauh ini —
/// staircase lompat, lantai ladder, platform bergerak — ditutup lantai
/// tertinggi di seluruh Episode 1-2 (rise 320) tempat gate terakhir & goal
/// berada.
LevelData buildLevel20() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([
      QuizCategory.hijaiyah,
      QuizCategory.hijaiyahSambung,
      QuizCategory.harakat,
      QuizCategory.namaSurat,
      QuizCategory.tajwidDasar,
    ]),
    6,
  );

  return LevelData(
    id: 20,
    title: 'Ujian Kenaikan TPA',
    episode: 2,
    worldWidth: 5900,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Staircase lompat (rise 100 lalu 170).
      PlatformSpec(position: Vector2(1400, groundY - 100), size: Vector2(200, 32)),
      PlatformSpec(position: Vector2(1650, groundY - 170), size: Vector2(200, 32)),
      // Lantai ladder 1 (rise 220).
      PlatformSpec(position: Vector2(2700, groundY - 220), size: Vector2(300, 32)),
      // Pulau keberangkatan & kedatangan platform bergerak (rise 150).
      PlatformSpec(position: Vector2(3400, groundY - 150), size: Vector2(200, 32)),
      PlatformSpec(position: Vector2(4300, groundY - 150), size: Vector2(250, 32)),
      // Lantai tertinggi di Episode 1-2 (rise 320, wajib ladder) — goal.
      PlatformSpec(position: Vector2(5000, groundY - 320), size: Vector2(700, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(2700, groundY - 220), size: Vector2(60, 220)),
      LadderSpec(position: Vector2(5000, groundY - 320), size: Vector2(60, 320)),
    ],
    movingPlatforms: [
      MovingPlatformSpec(
        position: Vector2(3650, groundY - 150),
        size: Vector2(140, 32),
        travelDistance: 500,
        speed: 80,
      ),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2200, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(4700, groundY - 40), size: Vector2(40, 40)),
      // Rintangan di lantai tertinggi.
      ObstacleSpec(position: Vector2(5100, groundY - 320 - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di staircase.
      QuizGateSpec(
        position: Vector2(1720, groundY - 170 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      // Di lantai ladder 1.
      QuizGateSpec(
        position: Vector2(2780, groundY - 220 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      // Di pulau keberangkatan.
      QuizGateSpec(
        position: Vector2(3450, groundY - 150 - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
      // Di pulau kedatangan, setelah naik platform bergerak.
      QuizGateSpec(
        position: Vector2(4380, groundY - 150 - 70),
        size: Vector2(80, 70),
        question: questions[4],
      ),
      // Gate terakhir di lantai tertinggi, sebelum goal.
      QuizGateSpec(
        position: Vector2(5250, groundY - 320 - 70),
        size: Vector2(80, 70),
        question: questions[5],
      ),
    ],
    // Goal di lantai tertinggi (rise 320) — finale Episode 2.
    goalPosition: Vector2(5450, groundY - 320 - 210),
  );
}
