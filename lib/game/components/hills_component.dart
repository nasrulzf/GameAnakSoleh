import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Bukit-bukit hijau bergelombang di kejauhan, murni dekoratif (tidak solid).
/// Dua lapis (jauh lebih terang & pucat, dekat lebih gelap) supaya latar
/// terasa punya kedalaman, mengikuti gaya pada referensi storyboard alih-alih
/// tanah datar polos. Bentuknya di-cache sekali sebagai [Path] saat [onLoad]
/// (bukan dihitung ulang tiap frame) supaya murah dirender walau dunia level
/// cukup lebar.
class HillsComponent extends PositionComponent {
  HillsComponent({required double worldWidth, required double groundY})
      : _worldWidth = worldWidth,
        _groundY = groundY,
        super(priority: -2);

  final double _worldWidth;
  final double _groundY;

  late final Path _farHill;
  late final Path _nearHill;

  static const _farColor = Color(0xFFA9DE85);
  static const _nearColor = Color(0xFF8FCB66);

  Path _buildHill({
    required double baseline,
    required double amplitude,
    required double frequency,
    required double phase,
    required double secondaryAmplitude,
    required double secondaryFrequency,
  }) {
    const step = 24.0;
    final path = Path()..moveTo(0, _groundY + 4);
    for (double x = 0; x <= _worldWidth; x += step) {
      final y = baseline -
          amplitude * (0.5 + 0.5 * math.sin(x * frequency + phase)) -
          secondaryAmplitude * (0.5 + 0.5 * math.sin(x * secondaryFrequency + phase * 1.7));
      path.lineTo(x, y);
    }
    path.lineTo(_worldWidth, _groundY + 4);
    path.close();
    return path;
  }

  @override
  Future<void> onLoad() async {
    _farHill = _buildHill(
      baseline: _groundY - 30,
      amplitude: 46,
      frequency: 2 * math.pi / 520,
      phase: 0.6,
      secondaryAmplitude: 16,
      secondaryFrequency: 2 * math.pi / 190,
    );
    _nearHill = _buildHill(
      baseline: _groundY - 6,
      amplitude: 60,
      frequency: 2 * math.pi / 380,
      phase: 2.1,
      secondaryAmplitude: 20,
      secondaryFrequency: 2 * math.pi / 150,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_farHill, Paint()..color = _farColor);
    canvas.drawPath(_nearHill, Paint()..color = _nearColor);
  }
}
