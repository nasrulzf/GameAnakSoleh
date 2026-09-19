import 'dart:math' as math;

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../app/game_progress.dart';
import '../audio/sound_service.dart';
import 'main_menu_screen.dart';

/// Daftar sprite yang sama dengan yang di-load [GameAnakSoleh.onLoad] —
/// di-preload lebih awal di sini supaya cache [Flame.images] sudah hangat
/// dan level pertama tidak stutter (lihat game_anak_soleh.dart:73-92).
const _gameSprites = [
  'bg/sky_base.png',
  'bg/sky_clouds.png',
  'ground/grass_tile.png',
  'platform/platform_wood_a.png',
  'platform/platform_wood_b.png',
  'obstacle/rock.png',
  'items/chest_closed.png',
  'items/chest_open.png',
  'items/key_icon.png',
  'buildings/madrasah.png',
  'buildings/lock_star.png',
  'buildings/mosque.png',
  'scenery/house_a.png',
  'scenery/house_b.png',
  'scenery/palm_tree.png',
  'scenery/banana_tree.png',
  'scenery/bush.png',
  'platform/ladder.png',
];

const _minDisplayTime = Duration(milliseconds: 1350);

/// Loading screen tampil di cold start, sebelum [MainMenuScreen]. Progress
/// bar-nya benar-benar mengikuti proses preload asli (GameProgress, sprite
/// Flame, audio) — bukan timer dekoratif, lihat [_preload].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Widget custom ini sudah siap ditampilkan — lepas splash native
    // sekarang juga (lihat catatan di main.dart soal kenapa ini perlu
    // eksplisit di Android 12+), baru lanjut preload asli.
    FlutterNativeSplash.remove();
    _preload();
  }

  void _setProgress(double value) {
    if (!mounted) return;
    setState(() => _progress = value);
  }

  Future<void> _preload() async {
    final stopwatch = Stopwatch()..start();

    await context.read<GameProgress>().hydrate();
    _setProgress(0.15);

    await Flame.images.loadAll(_gameSprites);
    _setProgress(0.70);

    try {
      await SoundService.preload();
    } catch (_) {
      // Aset audio mungkin belum digenerate — game tetap jalan tanpa suara.
    }
    _setProgress(0.90);

    final remaining = _minDisplayTime - stopwatch.elapsed;
    _setProgress(1.0);
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SplashBackground(),
          const Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(child: _SplashBanner()),
          ),
          const Positioned(
            bottom: 96,
            left: 0,
            right: 0,
            child: Center(child: _RunningCharacters()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Center(child: _LoadingBar(progress: _progress)),
          ),
        ],
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/bg/sky_base.png', fit: BoxFit.cover),
        Positioned.fill(
          child: Image.asset('assets/images/bg/sky_clouds.png', fit: BoxFit.cover),
        ),
        Align(
          alignment: const Alignment(0, -0.05),
          child: Image.asset('assets/images/buildings/mosque.png', height: 220),
        ),
        Positioned(
          left: -20,
          bottom: 60,
          child: Image.asset('assets/images/scenery/palm_tree.png', height: 260),
        ),
        Positioned(
          left: 90,
          bottom: 40,
          child: Image.asset('assets/images/scenery/palm_tree.png', height: 190),
        ),
        Positioned(
          right: -20,
          bottom: 60,
          child: Transform.flip(
            flipX: true,
            child: Image.asset('assets/images/scenery/palm_tree.png', height: 260),
          ),
        ),
        Positioned(
          right: 90,
          bottom: 40,
          child: Transform.flip(
            flipX: true,
            child: Image.asset('assets/images/scenery/palm_tree.png', height: 190),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: Image.asset(
              'assets/images/ground/grass_tile.png',
              repeat: ImageRepeat.repeatX,
              alignment: Alignment.topCenter,
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 90,
          child: Image.asset('assets/images/scenery/bush.png', height: 70),
        ),
        Positioned(
          right: 12,
          bottom: 90,
          child: Image.asset('assets/images/scenery/bush.png', height: 70),
        ),
      ],
    );
  }
}

/// Ribbon "GAME ANAK SHOLEH" + subteks developer, sebagai widget teks asli
/// (bukan gambar statis) supaya tetap tajam di semua ukuran layar.
class _SplashBanner extends StatelessWidget {
  const _SplashBanner();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5C542);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // "Ekor" pita di kiri & kanan, disembunyikan sebagian di belakang
        // panel utama supaya terkesan seperti banner/ribbon.
        Positioned(left: -6, top: 6, child: _ribbonTail(gold)),
        Positioned(right: -6, top: 6, child: _ribbonTail(gold, flip: true)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F6B5C),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: gold, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME ANAK SHOLEH',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Developed by Nasrul A Solution',
                style: GoogleFonts.baloo2(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ribbonTail(Color gold, {bool flip = false}) {
    final tail = ClipPath(
      clipper: _TailClipper(),
      child: Container(width: 26, height: 40, color: const Color(0xFF0B4F44)),
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

/// Dua anak "berlari" di tengah — pakai sprite karakter asli (walk1/walk2
/// bergantian cepat) yang sudah dipakai gameplay, bukan gambar statis.
class _RunningCharacters extends StatefulWidget {
  const _RunningCharacters();

  @override
  State<_RunningCharacters> createState() => _RunningCharactersState();
}

class _RunningCharactersState extends State<_RunningCharacters> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final frame = _controller.value < 0.5 ? '1' : '2';
        final bob = math.sin(_controller.value * math.pi) * 5;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.translate(
              offset: Offset(0, -bob),
              child: Image.asset('assets/images/characters/boy_right_walk$frame.png', height: 110),
            ),
            const SizedBox(width: 12),
            Transform.translate(
              offset: Offset(0, -bob),
              child: Image.asset('assets/images/characters/girl_right_walk$frame.png', height: 110),
            ),
          ],
        );
      },
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const barWidth = 320.0;
    const barHeight = 30.0;
    const gold = Color(0xFFF5C542);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: barWidth,
          height: barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(barHeight / 2),
                  border: Border.all(color: gold, width: 2.5),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          height: barHeight - 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular((barHeight - 8) / 2),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFE08A), gold],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  final left = (barWidth - 20) * value;
                  return Positioned(
                    left: left,
                    top: -6,
                    child: const Text('🌙', style: TextStyle(fontSize: 22)),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Loading...',
          style: GoogleFonts.baloo2(
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
