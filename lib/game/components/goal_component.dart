import 'dart:ui';

import 'package:flame/components.dart';

/// Ukuran area goal, dipakai juga oleh PlayerComponent untuk cek overlap.
final Vector2 kGoalSize = Vector2(56, 120);

/// Tiang bendera penanda akhir level.
class GoalComponent extends PositionComponent {
  GoalComponent({required Vector2 position})
      : super(position: position.clone(), size: kGoalSize.clone(), anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final polePaint = Paint()..color = const Color(0xFF57534E);
    canvas.drawRect(Rect.fromLTWH(size.x * 0.45, 0, size.x * 0.1, size.y), polePaint);

    final flagPaint = Paint()..color = const Color(0xFF22C55E);
    final path = Path()
      ..moveTo(size.x * 0.55, 4)
      ..lineTo(size.x, size.y * 0.18)
      ..lineTo(size.x * 0.55, size.y * 0.32)
      ..close();
    canvas.drawPath(path, flagPaint);
  }
}
