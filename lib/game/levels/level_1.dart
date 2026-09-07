import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 1 - "Berangkat Ngaji": level tutorial, memperkenalkan gerak & lompat,
/// dengan 2 quiz gate yang mudah.
LevelData buildLevel1() {
  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.rukunIslam, QuizCategory.doaHarian]),
    2,
  );

  return LevelData(
    id: 1,
    title: 'Berangkat Ngaji',
    worldWidth: 3200,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: const [], // level 1 tidak pakai platform layang, hanya ground
    obstacles: [
      ObstacleSpec(position: Vector2(900, 720 - 80 - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1900, 720 - 80 - 40), size: Vector2(40, 40)),
    ],
    // Tinggi gate (220) sengaja melebihi tinggi lompat maksimum pemain
    // (~180px, lihat PlayerComponent) supaya gate tidak bisa dilompati dan
    // pemain wajib menjawab soal untuk lewat.
    quizGates: [
      QuizGateSpec(
        position: Vector2(1400, 720 - 80 - 220),
        size: Vector2(60, 220),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(2500, 720 - 80 - 220),
        size: Vector2(60, 220),
        question: questions[1],
      ),
    ],
    goalPosition: Vector2(3100, 720 - 80 - 120),
  );
}
