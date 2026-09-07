import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../levels/level_data.dart';

/// Gerbang soal: menghalangi jalur sampai pemain menjawab pertanyaannya
/// dengan benar. Digambar sebagai gerbang kayu dengan tanda tanya.
class QuizGateComponent extends PositionComponent {
  QuizGateComponent({required this.spec})
      : super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  final QuizGateSpec spec;

  bool solved = false;

  void markSolved() {
    if (solved) return;
    solved = true;
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final postPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), postPaint);

    final signPaint = Paint()..color = const Color(0xFFFBBF24);
    final signRect = Rect.fromLTWH(size.x * 0.15, size.y * 0.08, size.x * 0.7, size.x * 0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(signRect, const Radius.circular(6)), signPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(color: Color(0xFF78350F), fontSize: 22, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(signRect.center.dx - textPainter.width / 2, signRect.center.dy - textPainter.height / 2),
    );
  }
}
