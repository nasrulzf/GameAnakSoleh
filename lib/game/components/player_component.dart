import 'dart:ui';

import 'package:flame/components.dart';

import '../../app/game_progress.dart';
import '../character_painter.dart';
import '../game_anak_soleh.dart';
import 'goal_component.dart';
import 'quiz_gate_component.dart';

/// Karakter pemain: fisika platformer sederhana (gravitasi, lompat, tabrakan
/// AABB manual terhadap tanah/platform/rintangan/gerbang soal) + gambar
/// tubuh berseragam SD dengan peci (laki-laki) atau kerudung (perempuan).
class PlayerComponent extends PositionComponent with HasGameReference<GameAnakSoleh> {
  PlayerComponent({required this.gender, required Vector2 startPosition})
      : _startPosition = startPosition.clone(),
        super(position: startPosition.clone(), size: Vector2(48, 64), anchor: Anchor.topLeft);

  static const double _speed = 220;
  static const double _gravity = 1600;
  static const double _jumpSpeed = 760;
  static const double _maxFallSpeed = 900;

  final CharacterGender gender;
  final Vector2 _startPosition;
  final Vector2 velocity = Vector2.zero();

  bool movingLeft = false;
  bool movingRight = false;
  bool _grounded = false;
  bool _jumpQueued = false;

  VoidCallback? onReachGoal;
  void Function(QuizGateComponent gate)? onGateBlocked;

  void requestJump() {
    if (_grounded) {
      _jumpQueued = true;
    }
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  void _respawn() {
    position.setFrom(_startPosition);
    velocity.setZero();
    _grounded = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (movingLeft == movingRight) {
      velocity.x = 0;
    } else {
      velocity.x = movingLeft ? -_speed : _speed;
    }

    velocity.y += _gravity * dt;
    if (velocity.y > _maxFallSpeed) velocity.y = _maxFallSpeed;

    if (_jumpQueued && _grounded) {
      velocity.y = -_jumpSpeed;
      _grounded = false;
    }
    _jumpQueued = false;

    final solids = game.currentSolids();

    // Sumbu X.
    position.x += velocity.x * dt;
    position.x = position.x.clamp(0, game.level.worldWidth - size.x);
    var b = bounds;
    for (final solid in solids) {
      if (!b.overlaps(solid.rect)) continue;
      if (velocity.x > 0) {
        position.x = solid.rect.left - size.x;
      } else if (velocity.x < 0) {
        position.x = solid.rect.right;
      }
      b = bounds;
      if (solid.gate != null) {
        onGateBlocked?.call(solid.gate!);
      }
    }

    // Sumbu Y.
    position.y += velocity.y * dt;
    _grounded = false;
    b = bounds;
    for (final solid in solids) {
      if (!b.overlaps(solid.rect)) continue;
      if (velocity.y > 0) {
        position.y = solid.rect.top - size.y;
        velocity.y = 0;
        _grounded = true;
      } else if (velocity.y < 0) {
        position.y = solid.rect.bottom;
        velocity.y = 0;
      }
      b = bounds;
      if (solid.gate != null) {
        onGateBlocked?.call(solid.gate!);
      }
    }

    // Jaga-jaga bila keluar dari batas dunia (seharusnya tidak terjadi karena
    // tidak ada jurang di desain level 1 & 2), kembalikan ke titik start.
    if (position.y > game.level.worldHeight + 200) {
      _respawn();
      return;
    }

    final goalRect = Rect.fromLTWH(
      game.level.goalPosition.x,
      game.level.goalPosition.y,
      kGoalSize.x,
      kGoalSize.y,
    );
    if (bounds.overlaps(goalRect)) {
      onReachGoal?.call();
    }
  }

  @override
  void render(Canvas canvas) {
    paintChildCharacter(
      canvas,
      Size(size.x, size.y),
      gender,
      facingLeft: movingLeft && !movingRight,
    );
  }
}
