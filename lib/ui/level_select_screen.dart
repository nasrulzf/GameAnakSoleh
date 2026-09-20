import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import '../game/levels/level_registry.dart';
import 'gameplay_screen.dart';

/// Layar "Peta Petualangan" — jalur berkelok berisi node per level,
/// dikelompokkan per episode lewat signpost kayu-emas. Lihat
/// requirements/ui-enhancement-level-selection/requirement.md untuk acuan
/// desain lengkap (palet warna, state node, formula posisi jalur).
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
    final episodesWithLevels = byEpisode.keys.toList()..sort();
    final upcomingEpisodes = kEpisodeTitles.keys.where((e) => !byEpisode.containsKey(e)).toList()
      ..sort();

    // Level "current" = level pertama yang sudah terbuka tapi belum pernah
    // dimainkan (belum ada bestScore) — dipakai untuk menandai "kamu di
    // sini" dengan cincin pulsa & sprite karakter.
    int? currentLevelId;
    for (final level in kLevelMeta) {
      if (progress.isLevelUnlocked(level.id) && progress.bestScore[level.id] == null) {
        currentLevelId = level.id;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  _GlossyCircleButton(
                    icon: Icons.arrow_back_rounded,
                    size: 46,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: _TitleRibbon('Pilih Level'),
                    ),
                  ),
                  _StarBadge(score: progress.totalHighScore),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      for (final episode in episodesWithLevels)
                        _EpisodeSection(
                          episode: episode,
                          levels: byEpisode[episode]!,
                          progress: progress,
                          currentLevelId: currentLevelId,
                        ),
                      for (final episode in upcomingEpisodes)
                        _ComingSoonSignpost(episode: episode),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeSection extends StatelessWidget {
  const _EpisodeSection({
    required this.episode,
    required this.levels,
    required this.progress,
    required this.currentLevelId,
  });

  final int episode;
  final List<LevelMeta> levels;
  final GameProgress progress;
  final int? currentLevelId;

  @override
  Widget build(BuildContext context) {
    final episodeTitle = kEpisodeTitles[episode] ?? 'Episode $episode';
    final perfectCount = levels.where((l) => progress.perfectLevels[l.id] == true).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EpisodeSignpost(
            iconAsset: episode <= 2
                ? 'assets/images/buildings/madrasah.png'
                : 'assets/images/buildings/mosque.png',
            eyebrow: 'Episode $episode',
            title: episodeTitle,
            subtitle: '⭐ $perfectCount/${levels.length} sempurna',
          ),
          _EpisodePath(levels: levels, progress: progress, currentLevelId: currentLevelId),
        ],
      ),
    );
  }
}

class _ComingSoonSignpost extends StatelessWidget {
  const _ComingSoonSignpost({required this.episode});

  final int episode;

  @override
  Widget build(BuildContext context) {
    final episodeTitle = kEpisodeTitles[episode] ?? 'Episode $episode';
    final isSpecial = episode >= 4;
    final subtitle = isSpecial
        ? '🔒 Selesaikan Episode ${episode - 3}–${episode - 1} sempurna'
        : '🚧 Segera hadir';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _EpisodeSignpost(
        iconAsset: 'assets/images/buildings/mosque.png',
        eyebrow: 'Episode $episode${isSpecial ? ' ⭐' : ''}',
        title: episodeTitle,
        subtitle: subtitle,
        locked: true,
      ),
    );
  }
}

class _EpisodeSignpost extends StatelessWidget {
  const _EpisodeSignpost({
    required this.iconAsset,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.locked = false,
  });

  final String iconAsset;
  final String eyebrow;
  final String title;
  final String subtitle;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final woodColors = locked
        ? const [Color(0xFF8A8F94), Color(0xFF5F656B)]
        : const [Color(0xFFC08A46), Color(0xFF8A5A28)];
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: woodColors,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: locked ? const Color(0xFFC7CDD2) : const Color(0xFFF5C542), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Opacity(
            opacity: locked ? 0.7 : 1.0,
            child: ColorFiltered(
              colorFilter: locked
                  ? const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ])
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Image.asset(iconAsset, width: 40, height: 40, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: GoogleFonts.baloo2(
                    color: const Color(0xFFFFE08A),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.baloo2(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Jalur berkelok berisi node level, posisi dihitung deterministik dari
/// index level dalam episode (bukan hardcode per level) supaya otomatis
/// bekerja untuk episode berapa pun jumlah levelnya.
class _EpisodePath extends StatelessWidget {
  const _EpisodePath({required this.levels, required this.progress, required this.currentLevelId});

  final List<LevelMeta> levels;
  final GameProgress progress;
  final int? currentLevelId;

  static const _width = 300.0;
  static const _centerX = 150.0;
  static const _amplitude = 85.0;
  static const _startY = 52.0;
  static const _stepY = 104.0;
  static const _nodeSize = 56.0;

  static Offset _centerFor(int index) {
    final dx = _amplitude * math.sin(index * 0.8);
    return Offset(_centerX + dx, _startY + index * _stepY);
  }

  @override
  Widget build(BuildContext context) {
    final centers = [for (var i = 0; i < levels.length; i++) _centerFor(i)];
    final height = centers.last.dy + _nodeSize / 2 + 24;

    return Center(
      child: SizedBox(
        width: _width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _TrailPainter(centers))),
            for (var i = 0; i < levels.length; i++)
              Positioned(
                left: centers[i].dx - _nodeSize / 2,
                top: centers[i].dy - _nodeSize / 2,
                width: _nodeSize,
                height: _nodeSize,
                child: _LevelNode(
                  level: levels[i],
                  progress: progress,
                  isCurrent: levels[i].id == currentLevelId,
                  isBoss: i == levels.length - 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter(this.centers);

  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    if (centers.length < 2) return;
    final path = Path()..moveTo(centers.first.dx, centers.first.dy);
    for (final point in centers.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final shadowPaint = Paint()
      ..color = const Color(0xFF93672F).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final trailPaint = Paint()
      ..color = const Color(0xFFD9AE6C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) => oldDelegate.centers != centers;
}

enum _NodeState { locked, playable, current, done, perfect }

class _LevelNode extends StatefulWidget {
  const _LevelNode({
    required this.level,
    required this.progress,
    required this.isCurrent,
    required this.isBoss,
  });

  final LevelMeta level;
  final GameProgress progress;
  final bool isCurrent;
  final bool isBoss;

  @override
  State<_LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<_LevelNode> with TickerProviderStateMixin {
  late final AnimationController _loopController;
  late final AnimationController _shakeController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      if (reduceMotion) {
        _loopController.stop();
      } else if (!_loopController.isAnimating) {
        _loopController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _loopController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  _NodeState get _state {
    final unlocked = widget.progress.isLevelUnlocked(widget.level.id);
    if (!unlocked) return _NodeState.locked;
    if (widget.progress.perfectLevels[widget.level.id] == true) return _NodeState.perfect;
    if (widget.progress.bestScore[widget.level.id] != null) return _NodeState.done;
    if (widget.isCurrent) return _NodeState.current;
    return _NodeState.playable;
  }

  void _handleTap() {
    final state = _state;
    if (state == _NodeState.locked) {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selesaikan level sebelumnya untuk membuka level ini 🔒'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameplayScreen(levelId: widget.level.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loopController, _shakeController]),
        builder: (context, child) {
          final shake = math.sin(_shakeController.value * math.pi * 4) * (1 - _shakeController.value) * 6;
          return Transform.translate(offset: Offset(shake, 0), child: child);
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (state == _NodeState.current) _buildPulseRing(),
            _buildCircle(state),
            if (state == _NodeState.perfect) _buildStarsBadge(),
            if (state == _NodeState.current) _buildCharacterMarker(),
            if (widget.isBoss)
              Positioned(
                bottom: -16,
                child: Text(
                  '👑',
                  style: TextStyle(fontSize: 14, color: Colors.amber.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseRing() {
    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, _) {
        final t = _loopController.value;
        return Opacity(
          opacity: (1 - t) * 0.9,
          child: Transform.scale(
            scale: 0.85 + t * 0.5,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7ED957), width: 3),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircle(_NodeState state) {
    final List<Color> gradient;
    final Color textColor;
    switch (state) {
      case _NodeState.locked:
        gradient = const [Color(0xFFB7C0C7), Color(0xFF8B96A0)];
        textColor = Colors.white;
      case _NodeState.playable:
      case _NodeState.current:
        gradient = const [Color(0xFF7ED957), Color(0xFF3FA65A)];
        textColor = Colors.white;
      case _NodeState.done:
      case _NodeState.perfect:
        gradient = const [Color(0xFFFFE08A), Color(0xFFF5C542)];
        textColor = const Color(0xFF5B3E00);
    }

    final circle = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: gradient),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 3),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: state == _NodeState.locked
          ? Image.asset('assets/images/buildings/lock_star.png', width: 28, height: 28)
          : Text(
              '${widget.level.id}',
              style: GoogleFonts.baloo2(fontWeight: FontWeight.w700, fontSize: 19, color: textColor),
            ),
    );

    if (state != _NodeState.perfect) return circle;

    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, child) {
        final glow = 0.4 + 0.6 * _loopController.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: const Color(0xFFF5C542).withValues(alpha: glow), blurRadius: 10, spreadRadius: 1),
            ],
          ),
          child: child,
        );
      },
      child: circle,
    );
  }

  Widget _buildStarsBadge() {
    return const Positioned(
      top: -15,
      child: Text('⭐⭐⭐', style: TextStyle(fontSize: 11)),
    );
  }

  Widget _buildCharacterMarker() {
    final gender = widget.progress.gender?.name ?? 'boy';
    return Positioned(
      right: -30,
      bottom: -6,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.asset('assets/images/characters/${gender}_right_idle.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _TitleRibbon extends StatelessWidget {
  const _TitleRibbon(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F6B5C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5C542), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.baloo2(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  const _StarBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 18),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1E3A8A)),
          ),
        ],
      ),
    );
  }
}

/// Tombol bulat glossy generik dengan feedback tekan scale-down — sama pola
/// seperti yang dipakai CharacterSelectScreen.
class _GlossyCircleButton extends StatefulWidget {
  const _GlossyCircleButton({required this.icon, required this.size, required this.onTap});

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
