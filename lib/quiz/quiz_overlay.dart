import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/game_progress.dart';
import '../game/game_anak_soleh.dart';
import 'quiz_question.dart';

/// Warna bingkai kayu & panel krem, khusus untuk popup ini (tidak dipakai di
/// layar lain, lihat requirement.md butir 5).
const _kFrameBrownDark = Color(0xFF9A5A24);
const _kFrameBrownLight = Color(0xFFC9803B);
const _kPanelCream = Color(0xFFFCEBC4);
const _kTextBrown = Color(0xFF6B3B1A);
const _kHintOrange = Color(0xFFF07C1D);
const _kHintRed = Color(0xFFE0392E);

/// Satu warna pastel + warna "bayangan" (lebih gelap, dipakai untuk efek
/// tombol timbul/emboss) untuk salah satu dari 4 opsi jawaban.
class _AnswerColor {
  const _AnswerColor(this.base, this.shadow);

  final Color base;
  final Color shadow;
}

/// Palet warna tombol jawaban, di-assign tetap berdasarkan index opsi
/// (0=biru, 1=ungu, 2=kuning, 3=pink) sesuai mockup.
const _kAnswerColors = [
  _AnswerColor(Color(0xFF5AC1F0), Color(0xFF2E93C4)),
  _AnswerColor(Color(0xFFC08CEE), Color(0xFF9459CC)),
  _AnswerColor(Color(0xFFF3C24D), Color(0xFFD69B22)),
  _AnswerColor(Color(0xFFF48FA8), Color(0xFFDC5F80)),
];
const _kWrongAnswerColor = _AnswerColor(Color(0xFFE9645A), Color(0xFFB63A31));
const _kRetryColor = _AnswerColor(Color(0xFFF6923A), Color(0xFFCE6E1B));

/// Kartu pertanyaan pilihan ganda yang muncul saat pemain menyentuh quiz
/// gate. Menampilkan [QuizQuestion] aktif dari [GameAnakSoleh.activeQuestion].
class QuizOverlay extends StatefulWidget {
  const QuizOverlay({super.key, required this.game, required this.question});

  final GameAnakSoleh game;
  final QuizQuestion question;

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  /// Index opsi yang terakhir dipilih salah, atau null bila belum ada
  /// kesalahan / sudah ditekan "Coba Lagi". Dipakai untuk mewarnai tombol
  /// yang dipilih jadi merah + ikon X (requirement butir 3).
  int? _wrongIndex;

  void _handleAnswer(int index) {
    final correct = widget.game.answerQuiz(index);
    if (!correct) {
      setState(() => _wrongIndex = index);
    }
  }

  void _handleRetry() {
    setState(() => _wrongIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _wrongIndex != null;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: _QuizFrame(
          hasError: hasError,
          question: widget.question,
          wrongIndex: _wrongIndex,
          gender: widget.game.gender,
          onAnswer: _handleAnswer,
          onRetry: _handleRetry,
        ),
      ),
    );
  }
}

class _QuizFrame extends StatelessWidget {
  const _QuizFrame({
    required this.hasError,
    required this.question,
    required this.wrongIndex,
    required this.gender,
    required this.onAnswer,
    required this.onRetry,
  });

  final bool hasError;
  final QuizQuestion question;
  final int? wrongIndex;
  final CharacterGender gender;
  final ValueChanged<int> onAnswer;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kFrameBrownLight, _kFrameBrownDark],
            ),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 18, offset: Offset(0, 10))],
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
            decoration: BoxDecoration(
              color: _kPanelCream,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasError ? 'Aduh, belum tepat! 😥 Coba lagi, yuk!' : 'Jawab dulu ya, biar bisa lanjut! ⭐',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: hasError ? _kHintRed : _kHintOrange,
                  ),
                ),
                const SizedBox(height: 8),
                AutoSizeText(
                  question.question,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 15,
                  style: GoogleFonts.baloo2(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _kTextBrown,
                  ),
                ),
                const SizedBox(height: 18),
                _AnswerGrid(question: question, wrongIndex: wrongIndex, onAnswer: onAnswer),
                if (hasError) ...[
                  const SizedBox(height: 16),
                  _RetryButton(onPressed: onRetry),
                ],
              ],
            ),
          ),
        ),
        const Positioned(top: -6, left: 46, child: _CloudDecor()),
        const Positioned(bottom: 6, right: 54, child: _CloudDecor()),
        const Positioned(top: -22, left: 118, child: _StarDecor(size: 30)),
        const Positioned(top: -8, right: 128, child: _StarDecor(size: 26)),
        const Positioned(bottom: -6, right: 96, child: _StarDecor(size: 24)),
        const Positioned(top: -34, child: _MosqueDecor()),
        const Positioned(top: 26, left: -4, child: _LanternDecor()),
        const Positioned(top: 26, right: -4, child: _LanternDecor()),
        const Positioned(top: -18, right: -14, child: _CloseButton()),
        Positioned(
          left: -34,
          bottom: -12,
          child: _Mascot(gender: gender, worried: hasError),
        ),
      ],
    );
  }
}

class _AnswerGrid extends StatelessWidget {
  const _AnswerGrid({required this.question, required this.wrongIndex, required this.onAnswer});

  final QuizQuestion question;
  final int? wrongIndex;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    Widget buttonAt(int index) {
      final isWrong = wrongIndex == index;
      final colors = isWrong ? _kWrongAnswerColor : _kAnswerColors[index];
      return Expanded(
        child: _AnswerButton(
          label: question.options[index],
          colors: colors,
          isWrong: isWrong,
          onTap: () => onAnswer(index),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [buttonAt(0), const SizedBox(width: 14), buttonAt(1)]),
        const SizedBox(height: 14),
        Row(children: [buttonAt(2), const SizedBox(width: 14), buttonAt(3)]),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.colors,
    required this.isWrong,
    required this.onTap,
  });

  final String label;
  final _AnswerColor colors;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.base,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: colors.shadow, offset: const Offset(0, 5))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              _StrokedText(
                label,
                fontSize: 19,
                strikethrough: isWrong,
              ),
              if (isWrong)
                const Icon(Icons.close_rounded, size: 46, color: Colors.white, shadows: [
                  Shadow(color: _kWrongAnswerColorShadow, blurRadius: 2, offset: Offset(0, 1)),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

const _kWrongAnswerColorShadow = Color(0xFF7A211B);

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: _kRetryColor.base,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _kRetryColor.shadow, offset: const Offset(0, 5))],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StrokedText('Coba Lagi', fontSize: 19),
              SizedBox(width: 8),
              Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label tombol jawaban: teks putih bold dengan outline coklat tipis supaya
/// kontras di semua warna latar pastel (requirement butir 5).
class _StrokedText extends StatelessWidget {
  const _StrokedText(this.text, {required this.fontSize, this.strikethrough = false});

  final String text;
  final double fontSize;
  final bool strikethrough;

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.baloo2(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      decoration: strikethrough ? TextDecoration.lineThrough : null,
      decorationColor: Colors.white,
      decorationThickness: 2,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black26,
          ),
        ),
        Text(text, textAlign: TextAlign.center, style: baseStyle.copyWith(color: Colors.white)),
      ],
    );
  }
}

/// Karakter maskot anak, mengambil sprite idle yang sudah ada sesuai gender
/// pemain. Belum ada aset pose "worried" khusus untuk state salah jawab —
/// sebagai placeholder, sprite normal dimiringkan sedikit + diberi ikon
/// keringat. Follow-up terpisah: minta ilustrasi pose worried yang sesuai
/// mockup (requirement.md butir 7).
class _Mascot extends StatelessWidget {
  const _Mascot({required this.gender, required this.worried});

  final CharacterGender gender;
  final bool worried;

  @override
  Widget build(BuildContext context) {
    final asset = gender == CharacterGender.girl
        ? 'assets/images/characters/girl_right_idle.png'
        : 'assets/images/characters/boy_right_idle.png';
    final sprite = Image.asset(asset, height: 128, filterQuality: FilterQuality.medium);
    return SizedBox(
      height: 148,
      width: 110,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Transform.rotate(angle: worried ? -0.06 : 0, child: sprite),
          if (worried)
            const Positioned(
              top: 6,
              right: 10,
              child: Icon(Icons.water_drop, color: Color(0xFF5AC1F0), size: 22),
            ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE0392E),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
    );
  }
}

class _StarDecor extends StatelessWidget {
  const _StarDecor({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star_rounded, color: const Color(0xFFF6C445), size: size, shadows: const [
      Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
    ]);
  }
}

class _CloudDecor extends StatelessWidget {
  const _CloudDecor();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.cloud_rounded, color: Colors.white, size: 40);
  }
}

class _MosqueDecor extends StatelessWidget {
  const _MosqueDecor();

  @override
  Widget build(BuildContext context) {
    return const Text('🕌', style: TextStyle(fontSize: 46));
  }
}

class _LanternDecor extends StatelessWidget {
  const _LanternDecor();

  @override
  Widget build(BuildContext context) {
    return const Text('🏮', style: TextStyle(fontSize: 30));
  }
}
