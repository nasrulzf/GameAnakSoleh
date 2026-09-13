import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, ImageRepeat, paintImage;

import '../levels/level_data.dart';

/// Tanah datar sepanjang level, digambar dari tekstur rumput+tanah yang
/// di-tile secara horizontal (tinggi tekstur mengikuti tinggi ground,
/// lebar mengikuti rasio asli supaya tidak gepeng).
class GroundComponent extends PositionComponent with HasGameReference {
  GroundComponent({required LevelData level})
      : super(
          position: Vector2(0, level.worldHeight - level.groundHeight),
          size: Vector2(level.worldWidth, level.groundHeight),
          anchor: Anchor.topLeft,
        );

  late final Image _texture;

  @override
  Future<void> onLoad() async {
    _texture = await game.images.load('ground/grass_tile.png');
  }

  @override
  void render(Canvas canvas) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: _texture,
      fit: BoxFit.fitHeight,
      alignment: Alignment.topLeft,
      repeat: ImageRepeat.repeatX,
    );
  }
}
