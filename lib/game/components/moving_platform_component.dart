import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, ImageRepeat, paintImage;

import '../levels/level_data.dart';

/// Platform yang bergerak bolak-balik antara [MovingPlatformSpec.position]
/// dan titik sejauh [MovingPlatformSpec.travelDistance] di sepanjang
/// [MovingPlatformSpec.axis]. Solid seperti [PlatformComponent] biasa, tapi
/// [currentRect]-nya berubah tiap frame — dipakai
/// GameAnakSoleh.currentSolids() untuk resolusi tabrakan dinamis.
class MovingPlatformComponent extends PositionComponent with HasGameReference {
  MovingPlatformComponent({required this.spec})
      : _origin = spec.position.clone(),
        _useVariantB = (spec.position.x ~/ 200).isEven,
        super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  final MovingPlatformSpec spec;
  final Vector2 _origin;
  final bool _useVariantB;

  double _progress = 0;
  int _direction = 1;

  late final Image _texture;

  Rect get currentRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  Future<void> onLoad() async {
    _texture = await game.images.load(
      _useVariantB ? 'platform/platform_wood_b.png' : 'platform/platform_wood_a.png',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _progress += _direction * spec.speed * dt;
    if (_progress >= spec.travelDistance) {
      _progress = spec.travelDistance;
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
      fit: BoxFit.fitHeight,
      alignment: Alignment.center,
      repeat: ImageRepeat.repeatX,
    );
  }
}
