import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import '../game/levels/level_registry.dart';
import 'gameplay_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  /// Jumlah total level yang sudah diimplementasikan — sumber kebenaran
  /// tunggal supaya tidak hardcode angka yang sama di layar lain.
  static int get totalLevels => kLevelMeta.length;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgress>();
    final byEpisode = <int, List<LevelMeta>>{};
    for (final level in kLevelMeta) {
      byEpisode.putIfAbsent(level.episode, () => []).add(level);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      appBar: AppBar(
        title: const Text('Pilih Level'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Center(
                  child: Chip(
                    avatar: const Icon(Icons.star_rounded, color: Color(0xFFFACC15)),
                    label: Text('Total Skor: ${progress.totalHighScore}'),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                for (final episode in byEpisode.keys.toList()..sort())
                  _EpisodeSection(
                    episode: episode,
                    levels: byEpisode[episode]!,
                    progress: progress,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EpisodeSection extends StatelessWidget {
  const _EpisodeSection({required this.episode, required this.levels, required this.progress});

  final int episode;
  final List<LevelMeta> levels;
  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    final episodeTitle = kEpisodeTitles[episode] ?? 'Episode $episode';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              'Episode $episode — $episodeTitle',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          for (final level in levels)
            _LevelTile(
              title: level.title,
              subtitle: level.subtitle,
              unlocked: progress.isLevelUnlocked(level.id),
              bestScore: progress.bestScore[level.id],
              perfect: progress.perfectLevels[level.id] ?? false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GameplayScreen(levelId: level.id)),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.title,
    required this.subtitle,
    required this.unlocked,
    required this.bestScore,
    required this.perfect,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool unlocked;
  final int? bestScore;
  final bool perfect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          unlocked ? Icons.play_circle_fill_rounded : Icons.lock_rounded,
          size: 36,
          color: unlocked ? const Color(0xFF16A34A) : Colors.grey,
        ),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (perfect) ...[
              const SizedBox(width: 6),
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFACC15)),
            ],
          ],
        ),
        subtitle: Text(
          !unlocked
              ? 'Selesaikan level sebelumnya untuk membuka'
              : bestScore != null
                  ? '$subtitle • Skor terbaik: $bestScore'
                  : subtitle,
        ),
        onTap: unlocked ? onTap : null,
      ),
    );
  }
}
