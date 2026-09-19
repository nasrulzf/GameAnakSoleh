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
///
/// [extraQuestions] opsional mendukung "gate ganda" (mis. Level 45): jika
/// diisi, pemain harus menjawab [question] lalu setiap soal di
/// [extraQuestions] berurutan sebelum gate dianggap terpecahkan.
class QuizGateSpec {
  const QuizGateSpec({
    required this.position,
    required this.size,
    required this.question,
    this.extraQuestions,
  });

  final Vector2 position;
  final Vector2 size;
  final QuizQuestion question;
  final List<QuizQuestion>? extraQuestions;
}

/// Tangga interaktif yang bisa dipanjat pemain (naik/turun), berbeda dari
/// dekorasi tangga statis sebelumnya.
class LadderSpec {
  const LadderSpec({required this.position, required this.size});

  final Vector2 position;
  final Vector2 size;
}

/// Sumbu gerak untuk platform/rintangan yang berpindah tempat.
enum PatrolAxis { horizontal, vertical }

/// Platform yang bergerak bolak-balik sejauh [travelDistance] px dari
/// [position] awal, dengan kecepatan [speed] px/detik.
class MovingPlatformSpec {
  const MovingPlatformSpec({
    required this.position,
    required this.size,
    required this.travelDistance,
    this.axis = PatrolAxis.horizontal,
    this.speed = 80,
  });

  final Vector2 position;
  final Vector2 size;
  final PatrolAxis axis;
  final double travelDistance;
  final double speed;
}

/// Platform yang runtuh [crumbleDelaySeconds] detik setelah dipijak, lalu
/// muncul kembali setelah [respawnDelaySeconds] detik.
class CrumblingPlatformSpec {
  const CrumblingPlatformSpec({
    required this.position,
    required this.size,
    this.crumbleDelaySeconds = 0.6,
    this.respawnDelaySeconds = 3,
  });

  final Vector2 position;
  final Vector2 size;
  final double crumbleDelaySeconds;
  final double respawnDelaySeconds;
}

/// Rintangan (solid) yang berpatroli bolak-balik, mirip [ObstacleSpec] tapi
/// bergerak.
class PatrolObstacleSpec {
  const PatrolObstacleSpec({
    required this.position,
    required this.size,
    required this.patrolDistance,
    this.axis = PatrolAxis.horizontal,
    this.speed = 60,
  });

  final Vector2 position;
  final Vector2 size;
  final PatrolAxis axis;
  final double patrolDistance;
  final double speed;
}

/// Definisi satu level: lebar dunia, ground, platform, rintangan, quiz gate,
/// dan posisi goal di akhir level.
class LevelData {
  const LevelData({
    required this.id,
    required this.title,
    required this.episode,
    required this.worldWidth,
    required this.worldHeight,
    required this.groundHeight,
    required this.playerStart,
    required this.platforms,
    required this.obstacles,
    required this.quizGates,
    required this.goalPosition,
    this.timeLimitSeconds,
    this.ladders = const [],
    this.movingPlatforms = const [],
    this.crumblingPlatforms = const [],
    this.patrolObstacles = const [],
  });

  final int id;
  final String title;

  /// Episode 1-5 (10 level/episode) — dipakai untuk grouping di Level Select
  /// dan aturan unlock episode spesial (lihat `GameProgress.isEpisodeClean`).
  final int episode;
  final double worldWidth;
  final double worldHeight;
  final double groundHeight;
  final Vector2 playerStart;
  final List<PlatformSpec> platforms;
  final List<ObstacleSpec> obstacles;
  final List<QuizGateSpec> quizGates;
  final Vector2 goalPosition;

  /// Batas waktu bonus (detik). `null` = tanpa timer (Episode 1-3). Timer
  /// tidak pernah menggagalkan level, hanya mempengaruhi bonus skor.
  final int? timeLimitSeconds;
  final List<LadderSpec> ladders;
  final List<MovingPlatformSpec> movingPlatforms;
  final List<CrumblingPlatformSpec> crumblingPlatforms;
  final List<PatrolObstacleSpec> patrolObstacles;
}
