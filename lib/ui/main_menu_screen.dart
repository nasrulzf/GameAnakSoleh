import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import 'character_select_screen.dart';
import 'level_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgress>();

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
                          const Icon(Icons.mosque_rounded, size: 96, color: Color(0xFF1E3A8A)),
                          const SizedBox(height: 12),
                          Text(
                            'Game Anak Sholeh',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: const Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Petualangan seru berangkat ngaji sambil belajar Islam!',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          FilledButton(
                            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => progress.gender == null
                                      ? const CharacterSelectScreen()
                                      : const LevelSelectScreen(),
                                ),
                              );
                            },
                            child: const Text('Mulai Bermain'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CharacterSelectScreen()),
                              );
                            },
                            child: const Text('Ganti Karakter'),
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
