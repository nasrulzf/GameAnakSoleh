import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show BoxFit, ImageRepeat, paintImage;

import '../levels/level_data.dart';

/// Rintangan batu kecil di atas tanah yang wajib dilompati pemain.
class ObstacleComponent extends PositionComponent with HasGameReference {
  ObstacleComponent({required ObstacleSpec spec})
      : super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  late final Image _texture;

  @override
  Future<void> onLoad() async {
    _texture = await game.images.load('obstacle/rock.png');
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
