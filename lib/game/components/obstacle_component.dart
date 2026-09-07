import 'dart:ui';

import 'package:flame/components.dart';

import '../levels/level_data.dart';

/// Rintangan kecil di atas tanah yang harus dilompati pemain.
class ObstacleComponent extends PositionComponent {
  ObstacleComponent({required ObstacleSpec spec})
      : super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF7C3AED);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
  }
}
