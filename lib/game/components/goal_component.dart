import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, paintImage;

/// Ukuran area goal, dipakai juga oleh PlayerComponent untuk cek overlap.
final Vector2 kGoalSize = Vector2(150, 210);

/// Pintu Madrasah di akhir level: tergembok (ikon gembok bintang) selama
/// belum semua kunci (quiz gate/[ChestComponent]) terpecahkan, lalu gemboknya
/// hilang begitu [unlock] dipanggil sebagai tanda pintu sudah bisa dibuka.
/// Penyelesaian level sendiri tetap digerbang lewat [PlayerComponent.hasKey]
/// (lihat GameAnakSoleh._handleGateSolvedChange), bukan tabrakan solid — jadi
/// pemain boleh berjalan sampai ke depan pintu kapan saja, hanya levelnya
/// belum selesai sebelum kuncinya didapat.
class GoalComponent extends PositionComponent with HasGameReference {
  GoalComponent({required Vector2 position})
      : super(position: position.clone(), size: kGoalSize.clone(), anchor: Anchor.topLeft);

  late final Image _building;
  late final Image _lock;

  bool locked = true;

  void unlock() {
    locked = false;
  }

  @override
  Future<void> onLoad() async {
    _building = await game.images.load('buildings/madrasah.png');
    _lock = await game.images.load('buildings/lock_star.png');
  }

  @override
  void render(Canvas canvas) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: _building,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );

    if (!locked) return;
    // Gembok digantung di area pintu (tengah-bawah bangunan).
    final lockSize = size.x * 0.32;
    final lockRect = Rect.fromCenter(
      center: Offset(size.x * 0.5, size.y * 0.62),
      width: lockSize,
      height: lockSize,
    );
    paintImage(canvas: canvas, rect: lockRect, image: _lock, fit: BoxFit.contain);
  }
}
