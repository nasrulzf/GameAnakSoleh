import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 1 - "Berangkat Ngaji": level tutorial, memperkenalkan gerak & lompat,
/// dengan 2 quiz gate yang mudah. Diakhiri mini-staircase 2 anak tangga
/// (murni lompat, belum pakai tangga panjat) menuju lantai kecil tempat
/// goal berada — pengenalan pertama bahwa level tidak selalu berakhir di
/// tanah.
LevelData buildLevel1() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.rukunIslam, QuizCategory.doaHarian]),
    2,
  );

  return LevelData(
    id: 1,
    title: 'Berangkat Ngaji',
    episode: 1,
    worldWidth: 3200,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Mini-staircase menuju lantai goal (rise 70 lalu 140 dari tanah).
      PlatformSpec(position: Vector2(2500, groundY - 70), size: Vector2(220, 32)),
      PlatformSpec(position: Vector2(2760, groundY - 140), size: Vector2(300, 32)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(1800, groundY - 40), size: Vector2(40, 40)),
    ],
    // Peti kunci duduk di atas tanah (tidak solid, lihat QuizGateComponent) —
    // pemain harus menyentuhnya untuk memicu soal, dan kuncinya baru "didapat"
    // begitu semua peti di level ini terjawab benar (lihat GameAnakSoleh).
    quizGates: [
      QuizGateSpec(
        position: Vector2(1200, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      QuizGateSpec(
        position: Vector2(2200, groundY - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
    ],
    // Pintu Madrasah (goal) memakai ukuran [kGoalSize], bertumpu di ujung
    // platform lantai kedua (rise 140) — bukan lagi selalu di tanah.
    goalPosition: Vector2(2850, groundY - 140 - 210),
  );
}
