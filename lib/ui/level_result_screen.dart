import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import 'gameplay_screen.dart';
import 'level_select_screen.dart';

class LevelResultScreen extends StatelessWidget {
  const LevelResultScreen({super.key, required this.levelId});

  final int levelId;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgress>();
    final nextLevelId = levelId + 1;
    final hasNextLevel =
        nextLevelId <= LevelSelectScreen.totalLevels && progress.isLevelUnlocked(nextLevelId);

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
