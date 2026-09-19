import 'package:flame/components.dart';

import '../../quiz/quiz_bank.dart';
import '../../quiz/quiz_question.dart';
import 'level_data.dart';

/// Level 13 - "Menaiki Tangga Ilmu": tema level ini cocok dengan mekanik
/// ladder — sebuah menara 2 lantai (masing-masing rise 200) yang dipanjat
/// bertingkat lewat 2 ladder bersusun, lalu turun lagi ke tanah untuk gate
/// terakhir. Level pertama dengan 2 lantai atas bertumpuk (bukan
/// berdampingan seperti level 8).
LevelData buildLevel13() {
  const groundY = 720.0 - 80.0;

  final questions = QuizBank.randomPick(
    QuizBank.byCategories([QuizCategory.hijaiyahSambung]),
    4,
  );

  return LevelData(
    id: 13,
    title: 'Menaiki Tangga Ilmu',
    episode: 2,
    worldWidth: 4100,
    worldHeight: 720,
    groundHeight: 80,
    playerStart: Vector2(80, 500),
    platforms: [
      // Menara: lantai 1 (rise 200) lalu lantai 2 (rise 400, di atas lantai 1).
      PlatformSpec(position: Vector2(1500, groundY - 200), size: Vector2(300, 32)),
      PlatformSpec(position: Vector2(1500, groundY - 400), size: Vector2(300, 32)),
    ],
    ladders: [
      LadderSpec(position: Vector2(1500, groundY - 200), size: Vector2(60, 200)),
      LadderSpec(position: Vector2(1500, groundY - 400), size: Vector2(60, 200)),
    ],
    obstacles: [
      ObstacleSpec(position: Vector2(700, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(2300, groundY - 40), size: Vector2(40, 40)),
      ObstacleSpec(position: Vector2(3300, groundY - 40), size: Vector2(40, 40)),
    ],
    quizGates: [
      QuizGateSpec(
        position: Vector2(950, groundY - 70),
        size: Vector2(80, 70),
        question: questions[0],
      ),
      // Di lantai 1 menara.
      QuizGateSpec(
        position: Vector2(1600, groundY - 200 - 70),
        size: Vector2(80, 70),
        question: questions[1],
      ),
      // Di lantai 2 menara (puncak).
      QuizGateSpec(
        position: Vector2(1600, groundY - 400 - 70),
        size: Vector2(80, 70),
        question: questions[2],
      ),
      QuizGateSpec(
        position: Vector2(2800, groundY - 70),
        size: Vector2(80, 70),
        question: questions[3],
      ),
    ],
    goalPosition: Vector2(3850, groundY - 210),
  );
}
