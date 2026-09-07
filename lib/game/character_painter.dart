import 'dart:ui';

import '../app/game_progress.dart';

/// Menggambar karakter anak berseragam SD dengan atribut sesuai [gender]:
/// peci untuk anak laki-laki, kerudung/jilbab untuk anak perempuan, keduanya
/// menggendong tas. Dipakai bersama oleh [PlayerComponent] (in-game) dan
/// preview di layar pemilihan karakter, supaya tampilannya konsisten.
void paintChildCharacter(
  Canvas canvas,
  Size size,
  CharacterGender gender, {
  bool facingLeft = false,
}) {
  final bodyPaint = Paint()..color = const Color(0xFFFFFFFF);
  final bottomPaint = Paint()..color = const Color(0xFF1E3A8A);
  final skinPaint = Paint()..color = const Color(0xFFF4C99B);
  final bagPaint = Paint()..color = const Color(0xFFEF4444);

  canvas.drawRect(Rect.fromLTWH(4, size.height - 22, size.width - 8, 22), bottomPaint);
  canvas.drawRect(Rect.fromLTWH(4, size.height * 0.35, size.width - 8, size.height * 0.4), bodyPaint);

  final bagX = facingLeft ? size.width - 4 : -6.0;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(bagX, size.height * 0.4, 10, 22),
      const Radius.circular(3),
    ),
    bagPaint,
  );

  final headCenter = Offset(size.width / 2, size.height * 0.22);
  canvas.drawCircle(headCenter, size.width * 0.28, skinPaint);

  if (gender == CharacterGender.boy) {
    final peciPaint = Paint()..color = const Color(0xFF111827);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: headCenter.translate(0, -size.height * 0.16),
          width: size.width * 0.48,
          height: size.height * 0.16,
        ),
        const Radius.circular(3),
      ),
      peciPaint,
    );
  } else {
    final hijabPaint = Paint()..color = const Color(0xFFEC4899);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-2, size.height * 0.02, size.width + 4, size.height * 0.36),
        const Radius.circular(12),
      ),
      hijabPaint,
    );
    canvas.drawCircle(headCenter.translate(0, size.height * 0.03), size.width * 0.22, skinPaint);
  }
}
