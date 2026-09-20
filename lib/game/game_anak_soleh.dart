import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../app/game_progress.dart';
import '../audio/sound_service.dart';
import '../quiz/quiz_question.dart';
import 'components/crumbling_platform_component.dart';
import 'components/goal_component.dart';
import 'components/ground_component.dart';
import 'components/hills_component.dart';
import 'components/ladder_component.dart';
import 'components/moving_platform_component.dart';
import 'components/obstacle_component.dart';
import 'components/patrol_obstacle_component.dart';
import 'components/platform_component.dart';
import 'components/player_component.dart';
import 'components/quiz_gate_component.dart';
import 'components/scenery_component.dart';
import 'levels/level_data.dart';

/// Zona solid yang dipakai fisika [PlayerComponent] untuk resolusi tabrakan
/// terhadap tanah/platform/rintangan. Peti kunci ([QuizGateComponent]) sudah
/// tidak solid — pemain memicunya lewat overlap biasa (lihat
/// [PlayerComponent.update]) supaya bisa disentuh tanpa menghalangi jalan.
class SolidZone {
  const SolidZone(this.rect);

  final Rect rect;
}

/// Game utama untuk satu level. Dibuat ulang setiap kali pemain masuk ke
/// sebuah level (lihat GameplayScreen).
class GameAnakSoleh extends FlameGame with KeyboardEvents {
  GameAnakSoleh({
    required this.level,
    required this.gender,
    required this.onLevelComplete,
    required this.onLevelFailed,
  });

  final LevelData level;
  final CharacterGender gender;
  final void Function(int levelId, int score, bool perfect) onLevelComplete;
  final void Function(int score) onLevelFailed;

  late final PlayerComponent player;
  late final GoalComponent _door;
  final List<QuizGateComponent> _gates = [];
  final List<LadderComponent> _interactiveLadders = [];
  final List<MovingPlatformComponent> _movingPlatforms = [];
  final List<CrumblingPlatformComponent> _crumblingPlatforms = [];
  final List<PatrolObstacleComponent> _patrolObstacles = [];

  /// Dipakai [PlayerComponent] untuk cek overlap tiap frame (peti kunci
  /// tidak lagi solid, lihat [SolidZone]).
  List<QuizGateComponent> get quizGates => _gates;

  /// Tangga interaktif (dari [LevelData.ladders]) yang bisa dipanjat pemain —
  /// berbeda dari tangga dekoratif hardcoded dekat pintu madrasah.
  List<LadderComponent> get ladders => _interactiveLadders;

  /// Soal yang sedang aktif ditampilkan ke pemain (null = tidak ada quiz).
  /// Widget Flutter (QuizOverlay/HudOverlay) mendengarkan ini via
  /// ValueListenableBuilder.
  final ValueNotifier<QuizQuestion?> activeQuestion = ValueNotifier(null);

  /// Nyawa pemain untuk attempt level saat ini (bukan dipersist — reset ke 5
  /// tiap kali GameAnakSoleh dibuat ulang, lihat GameplayScreen). Berkurang
  /// 1 tiap salah jawab; 0 = level gagal (lihat [onLevelFailed]).
  final ValueNotifier<int> hearts = ValueNotifier(5);

  /// Skor attempt saat ini (base + bonus kecepatan + bonus heart + bonus
  /// waktu spesial). Lihat requirements/add-50-level-scenario/requirement.md
  /// Bagian C untuk formula lengkap.
  final ValueNotifier<int> score = ValueNotifier(0);

  /// Sisa waktu bonus (detik, dibulatkan ke atas). Null bila level ini tidak
  /// punya timer (Episode 1-3) — HUD tidak menampilkan apa pun saat null.
  /// Waktu habis TIDAK menggagalkan level, hanya membuat bonus_waktu_spesial
  /// jadi 0 (lihat [_handleGoalReached]).
  final ValueNotifier<int?> remainingSeconds = ValueNotifier(null);

  double? _timeLeftSeconds;
  DateTime? _gateOpenedAt;

  QuizGateComponent? _activeGate;
  bool _completed = false;

  /// Parallax background langit (diisi di [onLoad]). Kecepatan scrollnya
  /// diikat ke kecepatan jalan pemain tiap frame di [update], dikalikan
  /// [_skyVelocityFactor] supaya awan & langit terasa bergerak pelan/jauh
  /// saat karakter berjalan, dan diam saat karakter diam.
  Parallax? _sky;
  static const double _skyVelocityFactor = 0.12;

  /// Tinggi dunia acuan yang dipakai semua [LevelData] (lihat
  /// `worldHeight: 720` di tiap file level). Dipakai untuk menghitung zoom
  /// kamera di [onGameResize] -- tanpa ini, zoom kamera tetap 1.0 (bawaan
  /// Flame) sehingga 1 unit dunia = 1 logical pixel device apa adanya.
  /// Akibatnya tinggi dunia yang terlihat berubah-ubah mengikuti resolusi
  /// logis layar: di device dengan logical height jauh lebih besar dari 720
  /// (mis. karena pengaturan "screen zoom"/density yang lebih rapat seperti
  /// umum di sebagian HP Samsung), karakter & elemen game jadi tampak sangat
  /// kecil karena area dunia yang ditampilkan jauh lebih luas dari yang
  /// didesain.
  static const double _designHeight = 720;

  @override
  Color backgroundColor() => const Color(0xFF8FD3F4);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Kunci tinggi dunia yang terlihat supaya selalu ~[_designHeight] unit,
    // berapa pun resolusi logis layar device -- proporsi karakter terhadap
    // layar & jarak lompat/platform jadi konsisten di semua device.
    if (size.y > 0) {
      camera.viewfinder.zoom = size.y / _designHeight;
    }
  }

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'bg/sky_base.png',
      'bg/sky_clouds.png',
      'ground/grass_tile.png',
      'platform/platform_wood_a.png',
      'platform/platform_wood_b.png',
      'obstacle/rock.png',
      'items/chest_closed.png',
      'items/chest_open.png',
      'items/key_icon.png',
      'buildings/madrasah.png',
      'buildings/lock_star.png',
      'buildings/mosque.png',
      'scenery/house_a.png',
      'scenery/house_b.png',
      'scenery/palm_tree.png',
      'scenery/banana_tree.png',
      'scenery/bush.png',
      'platform/ladder.png',
    ]);

    // Background langit: 2 layer parallax (langit+matahari nyaris diam,
    // awan bergerak sedikit lebih cepat) supaya perjalanan terasa punya
    // kedalaman/jarak, bukan cuma warna statis.
    final skyLayer = await loadParallaxLayer(
      ParallaxImageData('bg/sky_base.png'),
      fill: LayerFill.height,
      alignment: Alignment.topCenter,
      velocityMultiplier: Vector2(0.25, 0),
    );
    final cloudsLayer = await loadParallaxLayer(
      ParallaxImageData('bg/sky_clouds.png'),
      fill: LayerFill.height,
      alignment: Alignment.topCenter,
      velocityMultiplier: Vector2(1, 0),
    );
    _sky = Parallax([skyLayer, cloudsLayer]);
    camera.backdrop.add(ParallaxComponent(parallax: _sky));

    final groundY = level.worldHeight - level.groundHeight;
    world.add(HillsComponent(worldWidth: level.worldWidth, groundY: groundY));
    world.add(SceneryComponent(worldWidth: level.worldWidth, groundY: groundY));
    world.add(GroundComponent(level: level));

    for (final spec in level.platforms) {
      world.add(PlatformComponent(spec: spec));
    }
    for (final spec in level.obstacles) {
      world.add(ObstacleComponent(spec: spec));
    }
    for (final spec in level.quizGates) {
      final gate = QuizGateComponent(spec: spec);
      _gates.add(gate);
      world.add(gate);
    }
    for (final spec in level.movingPlatforms) {
      final platform = MovingPlatformComponent(spec: spec);
      _movingPlatforms.add(platform);
      world.add(platform);
    }
    for (final spec in level.crumblingPlatforms) {
      final platform = CrumblingPlatformComponent(spec: spec);
      _crumblingPlatforms.add(platform);
      world.add(platform);
    }
    for (final spec in level.patrolObstacles) {
      final obstacle = PatrolObstacleComponent(spec: spec);
      _patrolObstacles.add(obstacle);
      world.add(obstacle);
    }
    for (final spec in level.ladders) {
      final ladder = LadderComponent(
        position: spec.position,
        size: spec.size,
        interactive: true,
      );
      _interactiveLadders.add(ladder);
      world.add(ladder);
    }
    _door = GoalComponent(position: level.goalPosition);
    world.add(_door);

    // Tangga dekoratif bersandar di dinding madrasah (lihat
    // full-capture-expectations.jpeg) -- murni visual, lihat LadderComponent.
    final ladderSize = Vector2(118, 170);
    world.add(LadderComponent(
      position: Vector2(level.goalPosition.x - 100, groundY - ladderSize.y),
      size: ladderSize,
    ));

    player = PlayerComponent(gender: gender, startPosition: level.playerStart)
      ..onReachGoal = _handleGoalReached
      ..onGateBlocked = _handleGateBlocked;
    world.add(player);

    camera.follow(player, maxSpeed: double.infinity);
    camera.viewfinder.anchor = Anchor.center;

    score.value = 100 + (level.episode - 1) * 20;
    _timeLeftSeconds = level.timeLimitSeconds?.toDouble();
    remainingSeconds.value = level.timeLimitSeconds;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Awan & langit hanya bergerak selagi karakter berjalan, dan pelan
    // (dikalikan _skyVelocityFactor) supaya terasa jauh di kejauhan.
    _sky?.baseVelocity.x = player.velocity.x * _skyVelocityFactor;

    // Countdown bonus (hanya Episode spesial, lihat LevelData.timeLimitSeconds)
    // — murni memengaruhi skor akhir, tidak pernah menggagalkan level.
    if (_timeLeftSeconds != null) {
      _timeLeftSeconds = (_timeLeftSeconds! - dt).clamp(0, double.infinity);
      remainingSeconds.value = _timeLeftSeconds!.ceil();
    }
  }

  /// Dikumpulkan tiap frame dari ground + platform + obstacle (statis &
  /// dinamis). Dipakai [PlayerComponent] untuk resolusi tabrakan AABB.
  List<SolidZone> currentSolids() {
    final groundRect = Rect.fromLTWH(
      0,
      level.worldHeight - level.groundHeight,
      level.worldWidth,
      level.groundHeight,
    );
    return [
      SolidZone(groundRect),
      for (final p in level.platforms)
        SolidZone(Rect.fromLTWH(p.position.x, p.position.y, p.size.x, p.size.y)),
      for (final o in level.obstacles)
        SolidZone(Rect.fromLTWH(o.position.x, o.position.y, o.size.x, o.size.y)),
      for (final p in _movingPlatforms) SolidZone(p.currentRect),
      for (final c in _crumblingPlatforms)
        if (c.isSolidNow) SolidZone(c.currentRect),
      for (final o in _patrolObstacles) SolidZone(o.currentRect),
    ];
  }

  void _handleGateBlocked(QuizGateComponent gate) {
    if (_activeGate != null) return;
    _activeGate = gate;
    activeQuestion.value = gate.currentQuestion;
    _gateOpenedAt = DateTime.now();
    pauseEngine();
    SoundService.playQuizTrigger();
  }

  /// Dipanggil dari QuizOverlay saat pemain memilih jawaban ke-[chosenIndex].
  /// Jawaban salah mengurangi [hearts] (lihat requirement Bagian B) — popup
  /// tetap tampil sampai pemain menjawab benar, tidak pernah mem-block
  /// lanjut. Mengembalikan true bila benar.
  bool answerQuiz(int chosenIndex) {
    final gate = _activeGate;
    final question = activeQuestion.value;
    if (gate == null || question == null) return false;
    final correct = question.isCorrect(chosenIndex);
    if (correct) {
      final elapsedSeconds = _gateOpenedAt == null
          ? 0.0
          : DateTime.now().difference(_gateOpenedAt!).inMilliseconds / 1000;
      final speedBonus = math.max(20, 100 - (elapsedSeconds * 5).round());
      score.value += speedBonus;

      if (gate.hasMoreQuestions) {
        // Gate ganda (lihat QuizGateSpec.extraQuestions): tampilkan soal
        // berikutnya di gate yang sama, belum markSolved dulu.
        gate.advanceToNextQuestion();
        activeQuestion.value = gate.currentQuestion;
        _gateOpenedAt = DateTime.now();
        SoundService.playAnswerCorrect();
        return true;
      }

      gate.markSolved();
      _activeGate = null;
      activeQuestion.value = null;
      _gateOpenedAt = null;
      resumeEngine();
      SoundService.playAnswerCorrect();
      // Begitu semua peti di level ini terpecahkan, kuncinya "didapat":
      // tampilkan ikon kunci di atas karakter dan buka gembok pintu akhir.
      if (_gates.every((g) => g.solved)) {
        player.hasKey = true;
        _door.unlock();
      }
    } else {
      SoundService.playAnswerWrong();
      hearts.value -= 1;
      if (hearts.value <= 0) {
        onLevelFailed(score.value);
      }
    }
    return correct;
  }

  void _handleGoalReached() {
    if (_completed) return;
    _completed = true;
    pauseEngine();
    SoundService.playLevelComplete();

    final heartBonus = hearts.value * 30;
    final timeBonus =
        (level.timeLimitSeconds != null && (_timeLeftSeconds ?? 0) > 0) ? 300 : 0;
    score.value += heartBonus + timeBonus;
    final perfect = hearts.value == 5;

    onLevelComplete(level.id, score.value, perfect);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    player.movingLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    player.movingRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    // Naik/turun tangga interaktif (lihat LadderComponent.interactive) —
    // hanya berefek saat pemain sedang overlap tangga (lihat
    // PlayerComponent.update).
    player.movingUp = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);
    player.movingDown = keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS);
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.keyW)) {
      player.requestJump();
    }
    return KeyEventResult.handled;
  }

  @override
  void onRemove() {
    activeQuestion.dispose();
    hearts.dispose();
    score.dispose();
    remainingSeconds.dispose();
    super.onRemove();
  }
}
