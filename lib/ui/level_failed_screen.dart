import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gameplay_screen.dart';
import 'level_select_screen.dart';

/// Ditampilkan saat heart pemain habis (lihat GameAnakSoleh.answerQuiz &
/// requirements/add-50-level-scenario/requirement.md Bagian B). Progress
/// campaign TIDAK berkurang — hanya attempt level ini yang diulang dari
/// awal (heart kembali 5).
class LevelFailedScreen extends StatelessWidget {
  const LevelFailedScreen({super.key, required this.levelId, required this.score});

  final int levelId;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite_border_rounded,
                            size: 96,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Yuk Coba Lagi!',
                            style: GoogleFonts.baloo2(
                              textStyle: Theme.of(context).textTheme.headlineSmall,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kamu pasti bisa! 💪',
                            style: GoogleFonts.baloo2(
                              textStyle: Theme.of(context).textTheme.bodyLarge,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Skor yang terkumpul: $score',
                            style: GoogleFonts.baloo2(
                              textStyle: Theme.of(context).textTheme.titleMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton(
                            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => GameplayScreen(levelId: levelId)),
                              );
                            },
                            child: const Text('Ulangi Level'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                              );
                            },
                            child: const Text('Pilih Level'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
