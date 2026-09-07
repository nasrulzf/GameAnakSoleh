import 'dart:ui';

import 'package:flame/components.dart';

import '../levels/level_data.dart';

/// Tanah datar sepanjang level, digambar sebagai strip hijau rumput + coklat tanah.
class GroundComponent extends PositionComponent {
  GroundComponent({required LevelData level})
      : super(
          position: Vector2(0, level.worldHeight - level.groundHeight),
          size: Vector2(level.worldWidth, level.groundHeight),
          anchor: Anchor.topLeft,
        );

  @override
  void render(Canvas canvas) {
    final grassPaint = Paint()..color = const Color(0xFF6ABE4E);
    final dirtPaint = Paint()..color = const Color(0xFF9C6B3E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 14), grassPaint);
    canvas.drawRect(Rect.fromLTWH(0, 14, size.x, size.y - 14), dirtPaint);
  }
}
