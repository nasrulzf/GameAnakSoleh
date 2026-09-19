import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 2 - "Perjalanan ke TPA": lebih panjang, ada platform layang & lebih
/// banyak rintangan, dengan 3 quiz gate yang sedikit lebih menantang.
/// Diperkenalkan lantai tengah (naik lewat staircase lalu turun lagi
/// sebelum goal) — quiz gate ke-2 sengaja ditaruh di lantai tengah supaya
/// pemain benar-benar memakai lantainya, bukan cuma lewat di bawahnya.
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
    episode: 1,
    worldWidth: 4200,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    // Staircase naik ke lantai tengah (rise 110 lalu 150 dari tanah), lalu
    // satu anak tangga turun (rise 70) sebelum kembali ke tanah — semua
    // masih di bawah tinggi lompat maksimum pemain (~180px).
    platforms: [
      PlatformSpec(position: Vector2(1100, groundY - 110), size: Vector2(220, 32)),
      PlatformSpec(position: Vector2(1780, groundY - 150), size: Vector2(260, 32)),
      PlatformSpec(position: Vector2(2150, groundY - 70), size: Vector2(220, 32)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(650, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2500, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3600, groundY - 40), size: Vector2(40, 40)),
    ],
    // Peti kunci duduk di atas tanah/platform (tidak solid, lihat
    // QuizGateComponent) — pemain harus menyentuhnya untuk memicu soal, dan
    // kuncinya baru "didapat" begitu semua peti di level ini terjawab benar
    // (lihat GameAnakSoleh).
    quizGates: [
      QuizGateSpec(
        position: Vector2(750, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai tengah (platform kedua), bukan di tanah.
      QuizGateSpec(
        position: Vector2(1850, groundY - 150 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      QuizGateSpec(
        position: Vector2(2900, groundY - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
    ],
    // Pintu Madrasah (goal) memakai ukuran [kGoalSize]; x digeser secukupnya
    // dari tepi dunia supaya bangunannya tidak terpotong.
    goalPosition: Vector2(4020, groundY - 210),
  );
}
