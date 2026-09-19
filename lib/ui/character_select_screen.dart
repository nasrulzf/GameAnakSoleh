import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import '../audio/sound_service.dart';
import 'level_select_screen.dart';

/// Layar pilih karakter bergaya "game" — lihat
/// requirements/ui-enhancement-player-selection/requirement.md untuk acuan
/// desain lengkap (judul bubble-text, tombol glossy, kartu beranimasi).
class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen>
    with SingleTickerProviderStateMixin {
  CharacterGender? _selectedGender;
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();
    _selectedGender = context.read<GameProgress>().gender;
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _selectGender(CharacterGender gender) {
    setState(() => _selectedGender = gender == _selectedGender ? _selectedGender : gender);
  }

  Future<void> _confirm() async {
    final gender = _selectedGender;
    if (gender == null) return;
    final gameProgress = context.read<GameProgress>();
    SoundService.playGameStart();
    await Future.delayed(const Duration(milliseconds: 150));
    await gameProgress.setGender(gender);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgress>();
    final introCurve = CurvedAnimation(parent: _introController, curve: Curves.easeOutBack);

    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _GlossyCircleButton(
                    icon: Icons.arrow_back_rounded,
                    size: 52,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: FadeTransition(
                      opacity: introCurve,
                      child: ScaleTransition(
                        scale: Tween(begin: 0.9, end: 1.0).animate(introCurve),
                        child: const Center(child: _BubbleTitle('Pilih Karakter')),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: introCurve,
                    child: _StarBadge(score: progress.totalHighScore),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _CharacterCard(
                        gender: CharacterGender.boy,
                        name: 'Faqih',
                        selected: _selectedGender == CharacterGender.boy,
                        dimmed: _selectedGender != null && _selectedGender != CharacterGender.boy,
                        onTap: () => _selectGender(CharacterGender.boy),
                      ),
                      _CharacterCard(
                        gender: CharacterGender.girl,
                        name: 'Fathia',
                        selected: _selectedGender == CharacterGender.girl,
                        dimmed: _selectedGender != null && _selectedGender != CharacterGender.girl,
                        onTap: () => _selectGender(CharacterGender.girl),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28, top: 4),
              child: _ConfirmButton(enabled: _selectedGender != null, onTap: _confirm),
            ),
          ],
        ),
      ),
    );
  }
}

/// Judul dengan efek bubble-letter: outline coklat di belakang, fill
/// krem/kuning di depan — dipakai sekali saja di layar ini.
class _BubbleTitle extends StatelessWidget {
  const _BubbleTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.baloo2(fontSize: 30, fontWeight: FontWeight.w800);
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = const Color(0xFF6B4226),
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(color: const Color(0xFFFFE9A8)),
        ),
      ],
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 20),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1E3A8A)),
          ),
        ],
      ),
    );
  }
}

/// Tombol bulat glossy generik (dipakai back & sebagai basis tombol
/// konfirmasi) dengan feedback tekan scale-down.
class _GlossyCircleButton extends StatefulWidget {
  const _GlossyCircleButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  State<_GlossyCircleButton> createState() => _GlossyCircleButtonState();
}

class _GlossyCircleButtonState extends State<_GlossyCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF7ED957), Color(0xFF3FA65A)],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 4))],
          ),
          child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.5),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.enabled
        ? const [Color(0xFF8EE666), Color(0xFF3FA65A)]
        : const [Color(0xFFC7C7C7), Color(0xFF9E9E9E)];

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (widget.enabled) ..._buildSparkles(),
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradientColors,
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: widget.enabled
                      ? const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 5))]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Color(0xFFFACC15), size: 40),
                    Text(
                      'PILIH!',
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    const positions = [
      Alignment(-0.95, -0.75),
      Alignment(0.95, -0.6),
      Alignment(0.8, 0.9),
    ];
    return [
      for (var i = 0; i < positions.length; i++)
        AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, _) {
            final t = (_sparkleController.value + i * 0.33) % 1.0;
            final opacity = 0.4 + 0.6 * math.sin(t * math.pi);
            return Align(
              alignment: positions[i],
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 20),
              ),
            );
          },
        ),
    ];
  }
}

class _CharacterCard extends StatefulWidget {
  const _CharacterCard({
    required this.gender,
    required this.name,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final CharacterGender gender;
  final String name;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  State<_CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<_CharacterCard> with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _selectController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.selected) _selectController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _CharacterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _selectController.forward(from: 0);
    } else if (!widget.selected && oldWidget.selected) {
      _selectController.reverse();
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBoy = widget.gender == CharacterGender.boy;
    final selectedColors = isBoy
        ? const [Color(0xFFDFF7C4), Color(0xFFA8E58C)]
        : const [Color(0xFFFFD9EC), Color(0xFFFFA9CF)];

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: widget.dimmed ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedBuilder(
          animation: _selectController,
          builder: (context, child) {
            // Pulse naik lalu turun (1.0 -> 1.08 -> 1.0) mengikuti kurva sinus
            // dari nilai controller linear 0..1 — dipilih daripada
            // TweenSequence+Curves.elasticOut karena kurva itu overshoot di
            // luar rentang [0,1] yang membuat TweenSequence.evaluate assert.
            final scale = 1.0 + 0.08 * math.sin(_selectController.value * math.pi);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 220,
            height: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.selected ? null : Colors.white,
              gradient: widget.selected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: selectedColors,
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
              ],
              border: widget.selected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.black12, width: 1),
            ),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _idleController,
                    builder: (context, child) {
                      final bob = math.sin(_idleController.value * math.pi) * 6;
                      return Transform.translate(offset: Offset(0, -bob), child: child);
                    },
                    child: Image.asset(
                      'assets/images/characters/${widget.gender.name}_right_idle.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.gender.label,
                  style: GoogleFonts.baloo2(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  widget.name,
                  style: GoogleFonts.baloo2(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
