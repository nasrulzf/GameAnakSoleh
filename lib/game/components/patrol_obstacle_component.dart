import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show BoxFit, ImageRepeat, paintImage;

import '../levels/level_data.dart';

/// Rintangan (solid) yang berpatroli bolak-balik sejauh
/// [PatrolObstacleSpec.patrolDistance] di sepanjang [PatrolObstacleSpec.axis]
/// — mirip [ObstacleComponent] tapi bergerak, sehingga pemain harus mengatur
/// waktu lompatan, bukan cuma melompatinya di posisi tetap.
class PatrolObstacleComponent extends PositionComponent with HasGameReference {
  PatrolObstacleComponent({required this.spec})
      : _origin = spec.position.clone(),
        super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  final PatrolObstacleSpec spec;
  final Vector2 _origin;

  double _progress = 0;
  int _direction = 1;

  late final Image _texture;

  Rect get currentRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  Future<void> onLoad() async {
    _texture = await game.images.load('obstacle/rock.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _progress += _direction * spec.speed * dt;
    if (_progress >= spec.patrolDistance) {
      _progress = spec.patrolDistance;
      _direction = -1;
    } else if (_progress <= 0) {
      _progress = 0;
      _direction = 1;
    }
    if (spec.axis == PatrolAxis.horizontal) {
      position.x = _origin.x + _progress;
    } else {
      position.y = _origin.y + _progress;
    }
  }

  @override
  void render(Canvas canvas) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: _texture,
      fit: BoxFit.contain,
      repeat: ImageRepeat.noRepeat,
    );
  }
}
