import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import 'level_select_screen.dart';

class CharacterSelectScreen extends StatelessWidget {
  const CharacterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      appBar: AppBar(title: const Text('Pilih Karakter'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _CharacterCard(
                    gender: CharacterGender.boy,
                    description: 'Faqih',
                  ),
                  _CharacterCard(
                    gender: CharacterGender.girl,
                    description: 'Fathia',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.gender, required this.description});

  final CharacterGender gender;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: () async {
            await context.read<GameProgress>().setGender(gender);
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/characters/${gender.name}_right_idle.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(gender.label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
