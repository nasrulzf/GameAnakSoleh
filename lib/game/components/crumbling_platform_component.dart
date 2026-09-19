import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, ImageRepeat, paintImage;

import '../game_anak_soleh.dart';
import '../levels/level_data.dart';

/// Platform yang mulai runtuh setelah dipijak pemain selama
/// [CrumblingPlatformSpec.crumbleDelaySeconds], hilang (tidak solid) untuk
/// sementara, lalu muncul kembali setelah
/// [CrumblingPlatformSpec.respawnDelaySeconds]. Dipakai
/// GameAnakSoleh.currentSolids() lewat [isSolidNow] & [currentRect].
class CrumblingPlatformComponent extends PositionComponent
    with HasGameReference<GameAnakSoleh> {
  CrumblingPlatformComponent({required this.spec})
      : super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  final CrumblingPlatformSpec spec;

  late final Image _texture;

  double _standTimer = 0;
  double _respawnTimer = 0;
  bool _crumbled = false;

  bool get isSolidNow => !_crumbled;
  Rect get currentRect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  Future<void> onLoad() async {
    _texture = await game.images.load('platform/platform_wood_a.png');
  }

  bool get _playerStandingOnTop {
    final playerBounds = game.player.bounds;
    final onTopEdge = (playerBounds.bottom - position.y).abs() < 6;
    final withinSpan = playerBounds.right > position.x && playerBounds.left < position.x + size.x;
    return onTopEdge && withinSpan;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_crumbled) {
      _respawnTimer -= dt;
      if (_respawnTimer <= 0) {
        _crumbled = false;
        _standTimer = 0;
      }
      return;
    }

    if (_playerStandingOnTop) {
      _standTimer += dt;
      if (_standTimer >= spec.crumbleDelaySeconds) {
        _crumbled = true;
        _respawnTimer = spec.respawnDelaySeconds;
      }
    } else {
      _standTimer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_crumbled) return;

    // Sedikit "goyang" (opacity berkurang) mendekati waktu runtuh supaya anak
    // sempat bereaksi sebelum platform benar-benar hilang.
    final shakeRatio = (_standTimer / spec.crumbleDelaySeconds).clamp(0.0, 1.0);
    final paint = Paint()..color = Color.fromRGBO(255, 255, 255, 1 - shakeRatio * 0.5);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: _texture,
      fit: BoxFit.fitHeight,
      alignment: Alignment.center,
      repeat: ImageRepeat.repeatX,
    );
    canvas.restore();
  }
}
