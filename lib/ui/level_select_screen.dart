import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import 'gameplay_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  static const _levels = [
    (id: 1, title: 'Level 1', subtitle: 'Berangkat Ngaji'),
    (id: 2, title: 'Level 2', subtitle: 'Perjalanan ke TPA'),
  ];

  /// Jumlah total level yang ada di game, sumber kebenaran tunggal supaya
  /// tidak hardcode angka yang sama di layar lain (mis. `LevelResultScreen`).
  static int get totalLevels => _levels.length;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgress>();

    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      appBar: AppBar(title: const Text('Pilih Level'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                for (final level in _levels)
                  _LevelTile(
                    title: level.title,
                    subtitle: level.subtitle,
                    unlocked: progress.isLevelUnlocked(level.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => GameplayScreen(levelId: level.id)),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.title,
    required this.subtitle,
    required this.unlocked,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool unlocked;
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(unlocked ? subtitle : 'Selesaikan level sebelumnya untuk membuka'),
        onTap: unlocked ? onTap : null,
      ),
    );
  }
}
