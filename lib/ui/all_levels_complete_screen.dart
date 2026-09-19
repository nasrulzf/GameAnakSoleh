import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import 'gameplay_screen.dart';
import 'level_select_screen.dart';
import 'main_menu_screen.dart';

/// Layar perayaan khusus yang tampil saat pemain menamatkan **seluruh** level
/// yang ada (bukan sekadar satu level), lihat requirement.md.
///
/// Semua dekorasi (pita, confetti, bendera, balon, kilauan piala) digambar
/// lewat kode (`CustomPainter`/`ClipPath`/gradient) alih-alih aset PNG baru —
/// requirement.md secara eksplisit membolehkan pendekatan ini ("render manual
/// ... jika lebih praktis daripada bikin PNG").
class AllLevelsCompleteScreen extends StatelessWidget {
  const AllLevelsCompleteScreen({super.key, required this.levelId});

  /// Level terakhir yang baru diselesaikan pemain, dipakai tombol "Ulangi".
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final gender = context.watch<GameProgress>().gender ?? CharacterGender.boy;

    return Scaffold(
      backgroundColor: const Color(0xFF7FCBEF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              const Positioned.fill(child: _SkyGradient()),
              Positioned(
                top: -h * 0.18,
                right: -w * 0.06,
                child: _SunGlow(size: w * 0.3),
              ),
              Positioned.fill(child: CustomPaint(painter: _HillsPainter())),
              Positioned.fill(
                child: IgnorePointer(child: CustomPaint(painter: _ConfettiPainter())),
              ),
              Positioned(
                top: 0,
                left: 0,
                width: w * 0.34,
                height: h * 0.4,
                child: IgnorePointer(child: CustomPaint(painter: _BuntingPainter(flip: false))),
              ),
              Positioned(
                top: 0,
                right: 0,
                width: w * 0.34,
                height: h * 0.4,
                child: IgnorePointer(child: CustomPaint(painter: _BuntingPainter(flip: true))),
              ),
              Positioned(
                top: h * 0.16,
                left: w * 0.02,
                child: const _Balloon(color: Color(0xFFF3C24D), size: 46, stringLength: 46),
              ),
              Positioned(
                top: h * 0.42,
                left: w * 0.015,
                child: const _Balloon(color: Color(0xFFC08CEE), size: 40, stringLength: 40),
              ),
              Positioned(
                top: h * 0.08,
                right: w * 0.14,
                child: const _Balloon(color: Color(0xFFE0392E), size: 44, stringLength: 50),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.012),
                  child: Column(
                    children: [
                      _TitleBlock(width: math.min(w * 0.94, 640)),
                      const SizedBox(height: 4),
                      Expanded(child: _HeroRow(gender: gender)),
                      const SizedBox(height: 4),
                      _BottomBar(levelId: levelId),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Background: langit, matahari, bukit, confetti, bendera, balon.
// ---------------------------------------------------------------------------

class _SkyGradient extends StatelessWidget {
  const _SkyGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF62BFF5), Color(0xFFA6E3FB)],
        ),
      ),
    );
  }
}

class _SunGlow extends StatelessWidget {
  const _SunGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFF7C2).withValues(alpha: 0.95),
            const Color(0xFFFFE985).withValues(alpha: 0.35),
            const Color(0xFFFFE985).withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// Bukit hijau dua lapis mengikuti gaya `hills_component.dart` di dunia
/// gameplay (lihat requirement.md), digambar langsung dengan `Canvas` karena
/// layar ini murni Flutter widget (bukan komponen Flame).
class _HillsPainter extends CustomPainter {
  const _HillsPainter();

  Path _buildHill(Size size, double baseFraction, double amplitude, double frequency, double phase) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 16) {
      final y = size.height * baseFraction - amplitude * (0.5 + 0.5 * math.sin(x * frequency + phase));
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _buildHill(size, 0.74, size.height * 0.09, 2 * math.pi / 260, 0.4),
      Paint()..color = const Color(0xFF4E9F3E),
    );
    canvas.drawPath(
      _buildHill(size, 0.84, size.height * 0.1, 2 * math.pi / 200, 2.1),
      Paint()..color = const Color(0xFF6FC24C),
    );
  }

  @override
  bool shouldRepaint(covariant _HillsPainter oldDelegate) => false;
}

const _kConfettiColors = [
  Color(0xFFE0392E),
  Color(0xFFF3C24D),
  Color(0xFF6FC24C),
  Color(0xFF5AC1F0),
  Color(0xFFC08CEE),
];

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.dx,
    required this.dy,
    required this.angle,
    required this.size,
    required this.color,
  });

  final double dx;
  final double dy;
  final double angle;
  final double size;
  final Color color;
}

/// Posisi/rotasi/warna confetti di-generate sekali dengan seed tetap (bukan
/// per-frame) supaya taburannya tidak berubah tiap rebuild, sesuai catatan
/// aset di requirement.md.
final List<_ConfettiPiece> _kConfettiPieces = _generateConfetti();

List<_ConfettiPiece> _generateConfetti() {
  final random = math.Random(7);
  return List.generate(48, (index) {
    return _ConfettiPiece(
      dx: random.nextDouble(),
      dy: random.nextDouble() * 0.82,
      angle: random.nextDouble() * math.pi * 2,
      size: 6 + random.nextDouble() * 7,
      color: _kConfettiColors[random.nextInt(_kConfettiColors.length)],
    );
  });
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in _kConfettiPieces) {
      canvas.save();
      canvas.translate(piece.dx * size.width, piece.dy * size.height);
      canvas.rotate(piece.angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
        Paint()..color = piece.color,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}

/// Rangkaian bendera segitiga (bunting flag) melengkung dari pojok atas layar
/// ke arah tengah, mengikuti mockup. `flip` untuk versi cermin di sisi kanan.
class _BuntingPainter extends CustomPainter {
  const _BuntingPainter({required this.flip});

  final bool flip;

  static const _colors = [
    Color(0xFFE0392E),
    Color(0xFFF3C24D),
    Color(0xFF6FC24C),
    Color(0xFF5AC1F0),
    Color(0xFFC08CEE),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final start = flip ? Offset(size.width, 0) : Offset.zero;
    final control = Offset(size.width * (flip ? 0.7 : 0.3), size.height * 0.1);
    final end = Offset(size.width * 0.5, size.height);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    final metric = path.computeMetrics().first;
    const flagCount = 8;
    final flagWidth = size.width * 0.075;
    final flagHeight = size.height * 0.075;
    for (int i = 1; i < flagCount; i++) {
      final t = i / flagCount;
      final tangent = metric.getTangentForOffset(metric.length * t);
      if (tangent == null) continue;
      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(tangent.angle);
      final flagPath = Path()
        ..moveTo(-flagWidth / 2, 0)
        ..lineTo(flagWidth / 2, 0)
        ..lineTo(0, flagHeight)
        ..close();
      canvas.drawPath(flagPath, Paint()..color = _colors[i % _colors.length]);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BuntingPainter oldDelegate) => oldDelegate.flip != flip;
}

class _Balloon extends StatelessWidget {
  const _Balloon({required this.color, required this.size, required this.stringLength});

  final Color color;
  final double size;
  final double stringLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size * 1.25,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size),
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              colors: [Color.lerp(color, Colors.white, 0.45)!, color],
            ),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 4))],
          ),
        ),
        CustomPaint(size: Size(2, stringLength), painter: _StringPainter()),
      ],
    );
  }
}

class _StringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(0, size.height / 2, size.width / 2, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _StringPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Judul: pita "ALHAMDULILLAH!" + teks besar "SEMUA LEVEL SELESAI!".
// ---------------------------------------------------------------------------

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          _BannerRibbon(width: width * 0.62),
          const SizedBox(height: 2),
          _OutlinedTitle(width: width),
        ],
      ),
    );
  }
}

class _BannerRibbon extends StatelessWidget {
  const _BannerRibbon({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    const bandHeight = 52.0;
    final tailWidth = width * 0.1;
    return SizedBox(
      width: width,
      height: bandHeight + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 0, child: _RibbonTailShape(width: tailWidth, height: bandHeight - 4)),
          Positioned(
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: _RibbonTailShape(width: tailWidth, height: bandHeight - 4),
            ),
          ),
          Container(
            width: width - tailWidth * 0.85,
            height: bandHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0562E), Color(0xFFE0392E)],
              ),
              border: Border.all(color: const Color(0xFFB63A31), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'ALHAMDULILLAH!',
                style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RibbonTailShape extends StatelessWidget {
  const _RibbonTailShape({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ChevronClipper(),
      child: Container(width: width, height: height, color: const Color(0xFFB63A31)),
    );
  }
}

class _ChevronClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.55, size.height / 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _OutlinedTitle extends StatelessWidget {
  const _OutlinedTitle({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.baloo2(fontSize: 42, fontWeight: FontWeight.w800, height: 1);
    const text = 'SEMUA LEVEL SELESAI!';
    return SizedBox(
      width: width,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: baseStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 7
                  ..color = const Color(0xFF6B3B1A),
              ),
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: baseStyle.copyWith(color: const Color(0xFFFCEBC4)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Baris utama: karakter, piala, peti harta, pohon kelapa + Madrasah.
// ---------------------------------------------------------------------------

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.gender});

  final CharacterGender gender;

  @override
  Widget build(BuildContext context) {
    final characterAsset = gender == CharacterGender.girl
        ? 'assets/images/characters/girl_right_jump.png'
        : 'assets/images/characters/boy_right_jump.png';

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.clamp(120, 480);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(characterAsset, height: h * 0.62, filterQuality: FilterQuality.medium),
            _Trophy(size: h * 0.72),
            _GlowImage(asset: 'assets/images/items/chest_open.png', height: h * 0.5),
            SizedBox(
              height: h * 0.8,
              width: h * 0.95,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Image.asset('assets/images/buildings/madrasah.png', height: h * 0.78),
                  ),
                  Positioned(
                    left: -h * 0.12,
                    bottom: 0,
                    child: Image.asset('assets/images/scenery/palm_tree.png', height: h * 0.8),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Trophy extends StatelessWidget {
  const _Trophy({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size * 0.95,
            height: size * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFF3B0).withValues(alpha: 0.85),
                  const Color(0xFFFFF3B0).withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.2,
            left: size * 0.06,
            child: Transform.rotate(
              angle: -0.55,
              child: _RibbonTailShape(width: size * 0.16, height: size * 0.34),
            ),
          ),
          Positioned(
            bottom: size * 0.2,
            right: size * 0.06,
            child: Transform.rotate(
              angle: 0.55,
              child: _RibbonTailShape(width: size * 0.16, height: size * 0.34),
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE985), Color(0xFFCE8A1F)],
            ).createShader(rect),
            child: Icon(Icons.emoji_events_rounded, size: size, color: Colors.white),
          ),
          Positioned(top: 0, left: size * 0.04, child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.16)),
          Positioned(top: size * 0.14, right: 0, child: Icon(Icons.auto_awesome, color: Colors.white, size: size * 0.11)),
        ],
      ),
    );
  }
}

class _GlowImage extends StatelessWidget {
  const _GlowImage({required this.asset, required this.height});

  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 1.3,
      width: height * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: height * 1.1,
            height: height * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFF3B0).withValues(alpha: 0.8),
                  const Color(0xFFFFF3B0).withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Image.asset(asset, height: height, filterQuality: FilterQuality.medium),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tombol aksi bawah: "PILIH LEVEL" (utama) + "Beranda" / "Ulangi" (bulat).
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.levelId});

  final int levelId;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _PillButton(
            icon: Icons.map_rounded,
            label: 'PILIH LEVEL',
            color: const Color(0xFF6FC24C),
            shadowColor: const Color(0xFF3F8F2E),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
            ),
          ),
        ),
        const SizedBox(width: 14),
        _CircleActionButton(
          icon: Icons.home_rounded,
          label: 'Beranda',
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainMenuScreen()),
            (route) => false,
          ),
        ),
        const SizedBox(width: 12),
        _CircleActionButton(
          icon: Icons.refresh_rounded,
          label: 'Ulangi',
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => GameplayScreen(levelId: levelId)),
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF8C6FEE),
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
                boxShadow: [BoxShadow(color: Color(0xFF6449B8), offset: Offset(0, 5))],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 1))],
          ),
        ),
      ],
    );
  }
}
