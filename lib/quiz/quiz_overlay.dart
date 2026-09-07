import 'package:flutter/material.dart';

import '../game/game_anak_soleh.dart';
import 'quiz_question.dart';

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
  bool _showWrongHint = false;

  void _handleAnswer(int index) {
    final correct = widget.game.answerQuiz(index);
    if (!correct) {
      setState(() => _showWrongHint = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showWrongHint ? 'Belum tepat, coba lagi ya! 😊' : 'Jawab dulu ya, biar bisa lanjut! 🌟',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < question.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () => _handleAnswer(i),
                        child: Text(question.options[i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
