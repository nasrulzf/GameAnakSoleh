import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show
        Alignment,
        BoxFit,
        FontWeight,
        TextDirection,
        TextPainter,
        TextSpan,
        TextStyle,
        paintImage;

import '../../quiz/quiz_question.dart';
import '../levels/level_data.dart';

/// Peti berisi kunci: pemain cukup menyentuhnya (tidak menghalangi jalan,
/// lihat GameAnakSoleh.currentSolids yang tidak lagi memasukkan peti ini)
/// untuk memicu soal. Jawaban benar "mengambil" kuncinya (peti berubah jadi
/// versi terbuka & kosong) — kunci itulah yang membuka gembok pintu di akhir
/// level begitu semua peti di level terpecahkan (lihat GoalComponent &
/// PlayerComponent.hasKey).
///
/// Mendukung "gate ganda" (mis. Level 45) lewat [QuizGateSpec.extraQuestions]:
/// [currentQuestion] menampilkan soal ke-[_questionIndex], dan
/// [advanceToNextQuestion] dipanggil GameAnakSoleh saat satu soal terjawab
/// benar tapi masih ada soal berikutnya — peti baru [markSolved] setelah
/// seluruh soal di [allQuestions] terjawab benar berurutan.
class QuizGateComponent extends PositionComponent with HasGameReference {
  QuizGateComponent({required this.spec})
      : allQuestions = [spec.question, ...?spec.extraQuestions],
        super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  final QuizGateSpec spec;
  final List<QuizQuestion> allQuestions;
  int _questionIndex = 0;

  bool solved = false;

  late final Image _chestClosed;
  late final Image _chestOpen;
  late final Image _key;

  double _bobPhase = 0;

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  QuizQuestion get currentQuestion => allQuestions[_questionIndex];
  bool get hasMoreQuestions => _questionIndex < allQuestions.length - 1;

  void advanceToNextQuestion() {
    if (hasMoreQuestions) _questionIndex++;
  }

  void markSolved() {
    if (solved) return;
    solved = true;
  }

  @override
  Future<void> onLoad() async {
    _chestClosed = await game.images.load('items/chest_closed.png');
    _chestOpen = await game.images.load('items/chest_open.png');
    _key = await game.images.load('items/key_icon.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobPhase += dt * 2.4;
    _bobPhase %= math.pi * 2;
  }

  @override
  void render(Canvas canvas) {
    final chestRect = Rect.fromLTWH(0, size.y - size.x, size.x, size.x);
    paintImage(
      canvas: canvas,
      rect: chestRect,
      image: solved ? _chestOpen : _chestClosed,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );

    if (solved) return;

    // Kunci melayang & memantul pelan di atas peti supaya terlihat jelas ini
    // yang harus "diambil" dengan menjawab soal dengan benar.
    final bob = math.sin(_bobPhase) * size.x * 0.06;
    final keySize = size.x * 0.55;
    final keyRect = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y - size.x - keySize * 0.55 + bob),
      width: keySize,
      height: keySize,
    );
    paintImage(canvas: canvas, rect: keyRect, image: _key, fit: BoxFit.contain);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: const Color(0xFF78350F),
          fontSize: size.x * 0.32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.x * 0.5 - textPainter.width / 2, keyRect.top - textPainter.height - 2),
    );
  }
}
