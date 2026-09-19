import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../app/game_progress.dart';
import '../audio/sound_service.dart';
import '../quiz/quiz_question.dart';
import 'components/goal_component.dart';
import 'components/ground_component.dart';
import 'components/hills_component.dart';
import 'components/ladder_component.dart';
import 'components/obstacle_component.dart';
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
  });

  final LevelData level;
  final CharacterGender gender;
  final void Function(int levelId) onLevelComplete;

  late final PlayerComponent player;
  late final GoalComponent _door;
  final List<QuizGateComponent> _gates = [];

  /// Dipakai [PlayerComponent] untuk cek overlap tiap frame (peti kunci
  /// tidak lagi solid, lihat [SolidZone]).
  List<QuizGateComponent> get quizGates => _gates;

  /// Soal yang sedang aktif ditampilkan ke pemain (null = tidak ada quiz).
  /// Widget Flutter (QuizOverlay/HudOverlay) mendengarkan ini via
  /// ValueListenableBuilder.
  final ValueNotifier<QuizQuestion?> activeQuestion = ValueNotifier(null);

  QuizGateComponent? _activeGate;
  bool _completed = false;

  /// Parallax background langit (diisi di [onLoad]). Kecepatan scrollnya
  /// diikat ke kecepatan jalan pemain tiap frame di [update], dikalikan
  /// [_skyVelocityFactor] supaya awan & langit terasa bergerak pelan/jauh
  /// saat karakter berjalan, dan diam saat karakter diam.
  Parallax? _sky;
  static const double _skyVelocityFactor = 0.12;

  @override
  Color backgroundColor() => const Color(0xFF8FD3F4);

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
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Awan & langit hanya bergerak selagi karakter berjalan, dan pelan
    // (dikalikan _skyVelocityFactor) supaya terasa jauh di kejauhan.
    _sky?.baseVelocity.x = player.velocity.x * _skyVelocityFactor;
  }

  /// Dikumpulkan tiap frame dari ground + platform + obstacle. Dipakai
  /// [PlayerComponent] untuk resolusi tabrakan AABB.
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
    ];
  }

  void _handleGateBlocked(QuizGateComponent gate) {
    if (_activeGate != null) return;
    _activeGate = gate;
    activeQuestion.value = gate.spec.question;
    pauseEngine();
    SoundService.playQuizTrigger();
  }

  /// Dipanggil dari QuizOverlay saat pemain memilih jawaban ke-[chosenIndex].
  /// Jawaban salah tidak memberi penalti (usia 3-7 tahun) — overlay tetap
  /// tampil sampai pemain menjawab benar. Mengembalikan true bila benar.
  bool answerQuiz(int chosenIndex) {
    final gate = _activeGate;
    final question = activeQuestion.value;
    if (gate == null || question == null) return false;
    final correct = question.isCorrect(chosenIndex);
    if (correct) {
      gate.markSolved();
      _activeGate = null;
      activeQuestion.value = null;
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
    }
    return correct;
  }

  void _handleGoalReached() {
    if (_completed) return;
    _completed = true;
    pauseEngine();
    SoundService.playLevelComplete();
    onLevelComplete(level.id);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    player.movingLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    player.movingRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
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
    super.onRemove();
  }
}
