import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import 'character_select_screen.dart';
import 'level_select_screen.dart';

/// Main menu bergaya "Gerbang Petualangan" — lihat
/// requirements/ui-enhancement-main-menu/requirement.md (acuan:
/// expected-design.jpeg) untuk detail desain. Panel batu ukir & lengkung
/// mihrab digambar via CustomPainter sebagai fallback karena aset PNG-nya
/// (assets/images/ui/geometric_pattern_strip.png,
/// assets/images/ui/mihrab_arch_frame.png) belum digenerate — lihat bagian
/// "Aset Gambar" di requirement.md untuk migrasi ke aset asli nanti.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _introController.value = 1.0;
    } else if (_introController.status == AnimationStatus.dismissed) {
      _introController.forward();
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgress>();
    final introCurve = CurvedAnimation(parent: _introController, curve: Curves.easeOutBack);

    void goToNext() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => progress.gender == null ? const CharacterSelectScreen() : const LevelSelectScreen(),
        ),
      );
    }

    void changeCharacter() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CharacterSelectScreen()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFBFE6F2),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final archHeight = constraints.maxHeight * 0.48;
          return Stack(
            fit: StackFit.expand,
            children: [
              const _HillBackground(),
              Positioned(top: 0, left: 0, right: 0, height: archHeight, child: const _MihrabArch()),
              const _GeometricPatternStrip(),
              const _BuntingRow(),
              const Positioned(left: 0, right: 0, bottom: 0, child: _SoilStrip()),
              SafeArea(
                child: FadeTransition(
                  opacity: introCurve,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.94, end: 1.0).animate(introCurve),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: _ScoreBadge(score: progress.totalHighScore),
                          ),
                          const SizedBox(height: 4),
                          const _MenuRibbon(),
                          const SizedBox(height: 6),
                          Image.asset('assets/images/buildings/mosque.png', height: 92),
                          const SizedBox(height: 10),
                          const _TaglineScroll(),
                          Expanded(child: _MenuCharacters(gender: progress.gender)),
                          const SizedBox(height: 12),
                          _MenuPrimaryButton(onTap: goToNext),
                          const SizedBox(height: 10),
                          _MenuSecondaryButton(
                            avatarGender: progress.gender ?? CharacterGender.boy,
                            onTap: changeCharacter,
                          ),
                        ],
                      ),
                    ),
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

/// Perbukitan hijau berlapis + pohon bulat kecil, pengganti langit biru
/// polos Splash — palet khusus Main Menu, lihat "Palet & token warna" di
/// requirement.md.
class _HillBackground extends StatelessWidget {
  const _HillBackground();

  static const _treePositions = [
    Alignment(-0.86, 0.30),
    Alignment(-0.6, 0.44),
    Alignment(0.84, 0.28),
    Alignment(0.58, 0.45),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE6F2), Color(0xFFDCEFC8)],
        ),
      ),
      child: CustomPaint(
        painter: _HillsPainter(),
        child: Stack(
          children: [
            for (var i = 0; i < _treePositions.length; i++)
              Align(
                alignment: _treePositions[i],
                child: Transform.scale(scale: i.isEven ? 1.0 : 0.78, child: const _TreeDot()),
              ),
          ],
        ),
      ),
    );
  }
}

class _TreeDot extends StatelessWidget {
  const _TreeDot();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 30,
          decoration: const BoxDecoration(color: Color(0xFF4E8F35), shape: BoxShape.circle),
        ),
        Container(width: 5, height: 10, color: const Color(0xFF6B4A2E)),
      ],
    );
  }
}

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintHill(canvas, size, baseY: size.height * 0.60, amplitude: 16, color: const Color(0xFF9BC96A));
    _paintHill(canvas, size, baseY: size.height * 0.71, amplitude: 22, color: const Color(0xFF7EB552));
    _paintHill(canvas, size, baseY: size.height * 0.85, amplitude: 18, color: const Color(0xFF5FA03E));
  }

  void _paintHill(Canvas canvas, Size size, {required double baseY, required double amplitude, required Color color}) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, baseY)
      ..quadraticBezierTo(size.width * 0.25, baseY - amplitude, size.width * 0.5, baseY)
      ..quadraticBezierTo(size.width * 0.75, baseY + amplitude, size.width, baseY - amplitude * 0.4)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _HillsPainter oldDelegate) => false;
}

/// Lengkung mihrab yang menaungi ribbon+masjid — fallback `CustomPainter`
/// menggantikan aset opsional `mihrab_arch_frame.png` (belum digenerate).
class _MihrabArch extends StatelessWidget {
  const _MihrabArch();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _MihrabArchPainter());
}

class _MihrabArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.14, size.height)
      ..cubicTo(
        size.width * 0.14, size.height * 0.55, //
        size.width * 0.23, size.height * 0.16,
        size.width * 0.5, size.height * 0.02,
      )
      ..cubicTo(
        size.width * 0.77, size.height * 0.16, //
        size.width * 0.86, size.height * 0.55,
        size.width * 0.86, size.height,
      );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFB4915A),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE4D3A7),
    );

    final keystone = Offset(size.width * 0.5, size.height * 0.02);
    canvas.drawCircle(keystone, 6, Paint()..color = const Color(0xFFE3B23C));
    canvas.drawCircle(
      keystone,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF8B6B22),
    );
  }

  @override
  bool shouldRepaint(covariant _MihrabArchPainter oldDelegate) => false;
}

/// Panel batu berukir di tepi kiri layar — fallback `CustomPainter`
/// menggantikan aset wajib `geometric_pattern_strip.png` (belum
/// digenerate). Memudar ke arah tengah lewat `ShaderMask`.
class _GeometricPatternStrip extends StatelessWidget {
  const _GeometricPatternStrip();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      width: 26,
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.black, Colors.transparent],
        ).createShader(rect),
        blendMode: BlendMode.dstIn,
        child: CustomPaint(painter: _GeometricPatternPainter()),
      ),
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4D3A7), Color(0xFFCBAE73)],
        ).createShader(rect),
    );

    final line = Paint()
      ..color = const Color(0xFF8B6B3D).withValues(alpha: 0.55)
      ..strokeWidth = 2;
    const step = 10.0;
    for (var y = -size.width; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width), line);
      canvas.drawLine(Offset(size.width, y), Offset(0, y + size.width), line);
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricPatternPainter oldDelegate) => false;
}

/// Bendera segitiga hijau-emas-krem di tepi atas — murni widget, tidak
/// perlu aset gambar.
class _BuntingRow extends StatelessWidget {
  const _BuntingRow();

  static const _colors = [Color(0xFF0F6B4A), Color(0xFFE3B23C), Color(0xFFFAF6EC)];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 2,
      left: 14,
      right: 14,
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 14; i++) _BuntingFlag(color: _colors[i % _colors.length]),
        ],
      ),
    );
  }
}

class _BuntingFlag extends StatelessWidget {
  const _BuntingFlag({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(10, 16), painter: _TrianglePainter(color));
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}

/// Koin emas + pill skor kanan-atas — reskin pola `_StarBadge` (Character
/// Select/Level Select) jadi bentuk koin, murni widget.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.3),
              colors: [Color(0xFFFBE292), Color(0xFFE3B23C), Color(0xFFB0842A)],
              stops: [0, 0.7, 1],
            ),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.star_rounded, color: Color(0xFF8B6B22), size: 15),
        ),
        Transform.translate(
          offset: const Offset(-12, 0),
          child: Container(
            padding: const EdgeInsets.only(left: 18, right: 12, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
            ),
            child: Text(
              '$score',
              style: GoogleFonts.baloo2(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF4A3220)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Ribbon "GAME ANAK SHOLEH" — widget berdiri sendiri (bukan berbagi kode
/// dengan `_SplashBanner`), lihat alasan di requirement.md bagian "Prompt
/// Implementasi".
class _MenuRibbon extends StatelessWidget {
  const _MenuRibbon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(left: -5, top: 4, child: _tail()),
        Positioned(right: -5, top: 4, child: _tail(flip: true)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0F6B4A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3B23C), width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Text(
            'GAME ANAK SHOLEH',
            style: GoogleFonts.baloo2(
              color: const Color(0xFFFDF6E3),
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tail({bool flip = false}) {
    final tail = ClipPath(
      clipper: _TailClipper(),
      child: Container(width: 18, height: 28, color: const Color(0xFF0A4E36)),
    );
    return Transform.flip(flipX: flip, child: tail);
  }
}

class _TailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Kotak gulungan kertas untuk tagline — fallback widget menggantikan aset
/// wajib `scroll_banner.png` (belum digenerate).
class _TaglineScroll extends StatelessWidget {
  const _TaglineScroll();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF6E9C6), Color(0xFFEAD59D)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB4915A), width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
            ),
            child: Text(
              'Petualangan seru berangkat ngaji sambil belajar Islam!',
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                color: const Color(0xFF5C3E1E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
          Positioned(left: -6, top: -2, bottom: -2, child: _rollEnd()),
          Positioned(right: -6, top: -2, bottom: -2, child: _rollEnd()),
        ],
      ),
    );
  }

  Widget _rollEnd() {
    return Container(
      width: 10,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4CC91), Color(0xFFC9A968)],
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 0))],
      ),
    );
  }
}

/// Panggung karakter diapit 2 pohon kelapa — 2 karakter idle kalau
/// `gender` belum pernah dipilih, 1 karakter (lebih besar) kalau sudah.
class _MenuCharacters extends StatefulWidget {
  const _MenuCharacters({required this.gender});

  final CharacterGender? gender;

  @override
  State<_MenuCharacters> createState() => _MenuCharactersState();
}

class _MenuCharactersState extends State<_MenuCharacters> with SingleTickerProviderStateMixin {
  late final AnimationController _bobController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      if (reduceMotion) {
        _bobController.stop();
      } else if (!_bobController.isAnimating) {
        _bobController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -22,
          bottom: 6,
          child: Image.asset('assets/images/scenery/palm_tree.png', height: 140),
        ),
        Positioned(
          right: -22,
          bottom: 6,
          child: Transform.flip(
            flipX: true,
            child: Image.asset('assets/images/scenery/palm_tree.png', height: 140),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.gender == null
                ? [_bobbingChar('boy', 92), const SizedBox(width: 12), _bobbingChar('girl', 92)]
                : [_bobbingChar(widget.gender!.name, 116)],
          ),
        ),
      ],
    );
  }

  Widget _bobbingChar(String gender, double height) {
    return AnimatedBuilder(
      animation: _bobController,
      builder: (context, child) {
        final bob = math.sin(_bobController.value * math.pi) * 4;
        return Transform.translate(offset: Offset(0, -bob), child: child);
      },
      child: Image.asset('assets/images/characters/${gender}_right_idle.png', height: height),
    );
  }
}

/// Strip tanah cokelat di dasar layar, dengan garis rumput tipis di tepi
/// atasnya.
class _SoilStrip extends StatelessWidget {
  const _SoilStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6B4A2E), Color(0xFF432A17)],
        ),
        border: Border(top: BorderSide(color: Color(0xFF5FA03E), width: 4)),
      ),
    );
  }
}

/// Tombol "Mulai Bermain" — pill hijau tua, palet baru khusus Main Menu
/// (bukan hijau terang milik Character Select).
class _MenuPrimaryButton extends StatefulWidget {
  const _MenuPrimaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MenuPrimaryButton> createState() => _MenuPrimaryButtonState();
}

class _MenuPrimaryButtonState extends State<_MenuPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF379A63), Color(0xFF155C39)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFD9B25C), width: 2.5),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFF3D67A), size: 16),
              const SizedBox(width: 8),
              Text(
                'MULAI BERMAIN',
                style: GoogleFonts.baloo2(
                  color: const Color(0xFFFDF6E3),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded, color: Color(0xFFF3D67A), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol "Ganti Karakter" — pill krem-parchment dengan avatar bulat
/// karakter yang sedang aktif (fallback boy kalau belum pernah pilih).
class _MenuSecondaryButton extends StatefulWidget {
  const _MenuSecondaryButton({required this.avatarGender, required this.onTap});

  final CharacterGender avatarGender;
  final VoidCallback onTap;

  @override
  State<_MenuSecondaryButton> createState() => _MenuSecondaryButtonState();
}

class _MenuSecondaryButtonState extends State<_MenuSecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.only(left: 6, right: 16, top: 6, bottom: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF6E9C6), Color(0xFFEAD59D)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFB4915A), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/characters/${widget.avatarGender.name}_right_idle.png',
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ganti Karakter',
                style: GoogleFonts.baloo2(color: const Color(0xFF5C3E1E), fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
