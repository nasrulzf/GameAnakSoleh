import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../app/game_progress.dart';
import '../quiz/quiz_question.dart';
import 'components/goal_component.dart';
import 'components/ground_component.dart';
import 'components/obstacle_component.dart';
import 'components/platform_component.dart';
import 'components/player_component.dart';
import 'components/quiz_gate_component.dart';
import 'levels/level_data.dart';

/// Zona solid yang dipakai fisika [PlayerComponent] untuk resolusi tabrakan.
/// [gate] terisi bila zona ini berasal dari sebuah [QuizGateComponent] yang
/// belum terpecahkan, supaya player tahu harus memicu quiz.
class SolidZone {
  const SolidZone(this.rect, {this.gate});

  final Rect rect;
  final QuizGateComponent? gate;
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
  final List<QuizGateComponent> _gates = [];

  /// Soal yang sedang aktif ditampilkan ke pemain (null = tidak ada quiz).
  /// Widget Flutter (QuizOverlay/HudOverlay) mendengarkan ini via
  /// ValueListenableBuilder.
  final ValueNotifier<QuizQuestion?> activeQuestion = ValueNotifier(null);

  QuizGateComponent? _activeGate;
  bool _completed = false;

  @override
  Color backgroundColor() => const Color(0xFF8FD3F4);

  @override
  Future<void> onLoad() async {
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
    world.add(GoalComponent(position: level.goalPosition));

    player = PlayerComponent(gender: gender, startPosition: level.playerStart)
      ..onReachGoal = _handleGoalReached
      ..onGateBlocked = _handleGateBlocked;
    world.add(player);

    camera.follow(player, maxSpeed: double.infinity);
    camera.viewfinder.anchor = Anchor.center;
  }

  /// Dikumpulkan tiap frame dari ground + platform + obstacle + gate yang
  /// belum solved. Dipakai [PlayerComponent] untuk resolusi tabrakan AABB.
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
      for (final g in _gates)
        if (!g.solved)
          SolidZone(
            Rect.fromLTWH(g.spec.position.x, g.spec.position.y, g.spec.size.x, g.spec.size.y),
            gate: g,
          ),
    ];
  }

  void _handleGateBlocked(QuizGateComponent gate) {
    if (_activeGate != null) return;
    _activeGate = gate;
    activeQuestion.value = gate.spec.question;
    pauseEngine();
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
    }
    return correct;
  }

  void _handleGoalReached() {
    if (_completed) return;
    _completed = true;
    pauseEngine();
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
