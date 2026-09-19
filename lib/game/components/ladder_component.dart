import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, paintImage;

/// Tangga kayu berdiri di dekat gedung tujuan (lihat
/// full-capture-expectations.jpeg). Secara default murni dekoratif: tidak
/// didaftarkan di LevelData.platforms/.obstacles sehingga otomatis tidak ikut
/// resolusi tabrakan (lihat GameAnakSoleh.currentSolids) dan tidak menambah
/// mekanik panjat baru.
///
/// Bila [interactive] true (dibuat dari [LadderSpec] di [LevelData.ladders],
/// lihat GameAnakSoleh.onLoad), tangga ini bisa dipanjat: [PlayerComponent]
/// mengecek overlap terhadap [bounds] untuk menonaktifkan gravitasi &
/// menggerakkan pemain naik/turun langsung.
class LadderComponent extends PositionComponent with HasGameReference {
  LadderComponent({required Vector2 position, required Vector2 size, this.interactive = false})
      : super(position: position.clone(), size: size.clone(), anchor: Anchor.topLeft);

  final bool interactive;

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  late final Image _texture;

  @override
  Future<void> onLoad() async {
    _texture = await game.images.load('platform/ladder.png');
  }

  @override
  void render(Canvas canvas) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: _texture,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  }
}
