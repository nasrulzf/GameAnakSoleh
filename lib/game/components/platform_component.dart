import 'dart:ui';

import 'package:flame/components.dart';

import '../levels/level_data.dart';

/// Platform layang tempat pemain bisa berpijak.
class PlatformComponent extends PositionComponent {
  PlatformComponent({required PlatformSpec spec})
      : super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFC08552);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(6)),
      paint,
    );
  }
}
