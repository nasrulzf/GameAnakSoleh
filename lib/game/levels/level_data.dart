import 'package:flame/components.dart';

import '../../quiz/quiz_question.dart';

/// Platform/tanah tempat pemain berpijak.
class PlatformSpec {
  const PlatformSpec({required this.position, required this.size});

  final Vector2 position;
  final Vector2 size;
}

/// Rintangan sederhana (kotak) yang harus dilompati pemain.
class ObstacleSpec {
  const ObstacleSpec({required this.position, required this.size});

  final Vector2 position;
  final Vector2 size;
}

/// Gerbang soal: menghalangi jalan sampai pemain menjawab benar.
class QuizGateSpec {
  const QuizGateSpec({required this.position, required this.size, required this.question});

  final Vector2 position;
  final Vector2 size;
  final QuizQuestion question;
}

/// Definisi satu level: lebar dunia, ground, platform, rintangan, quiz gate,
/// dan posisi goal di akhir level.
class LevelData {
  const LevelData({
    required this.id,
    required this.title,
    required this.worldWidth,
    required this.worldHeight,
    required this.groundHeight,
    required this.playerStart,
    required this.platforms,
    required this.obstacles,
    required this.quizGates,
    required this.goalPosition,
  });

  final int id;
  final String title;
  final double worldWidth;
  final double worldHeight;
  final double groundHeight;
  final Vector2 playerStart;
  final List<PlatformSpec> platforms;
  final List<ObstacleSpec> obstacles;
  final List<QuizGateSpec> quizGates;
  final Vector2 goalPosition;
}
