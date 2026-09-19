import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import '../game/levels/level_registry.dart';
import 'gameplay_screen.dart';
import 'level_select_screen.dart';

class LevelResultScreen extends StatelessWidget {
  const LevelResultScreen({
    super.key,
    required this.levelId,
    required this.score,
    required this.perfect,
  });

  final int levelId;
  final int score;
  final bool perfect;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgress>();
    final nextLevelId = levelId + 1;
    final hasNextLevel =
        kLevelBuilders.containsKey(nextLevelId) && progress.isLevelUnlocked(nextLevelId);
    final bestScore = progress.bestScore[levelId] ?? score;

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
                          const Icon(Icons.emoji_events_rounded, size: 96, color: Color(0xFFFACC15)),
                          const SizedBox(height: 16),
                          Text(
                            'Alhamdulillah, Level $levelId Selesai!',
                            style: GoogleFonts.baloo2(
                              textStyle: Theme.of(context).textTheme.headlineSmall,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (perfect) ...[
                            const SizedBox(height: 8),
                            const Chip(
                              avatar: Icon(Icons.star_rounded, color: Color(0xFFFACC15)),
                              label: Text('Perfect!'),
                              backgroundColor: Colors.white,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Skor: $score',
                            style: GoogleFonts.baloo2(
                              textStyle: Theme.of(context).textTheme.titleMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Skor terbaik: $bestScore',
                            style: GoogleFonts.baloo2(
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (hasNextLevel)
                            FilledButton(
                              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => GameplayScreen(levelId: nextLevelId)),
                                );
                              },
                              child: Text('Lanjut ke Level $nextLevelId'),
                            )
                          else if (!kLevelBuilders.containsKey(nextLevelId))
                            Text(
                              'Episode berikutnya segera hadir!',
                              style: GoogleFonts.baloo2(
                                textStyle: Theme.of(context).textTheme.bodyMedium,
                              ),
                              textAlign: TextAlign.center,
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
