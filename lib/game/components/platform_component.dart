import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, ImageRepeat, paintImage;

import '../levels/level_data.dart';

/// Platform layang tempat pemain bisa berpijak, digambar dari tekstur balok
/// (bata/batu) yang di-tile horizontal supaya tidak gepeng di platform lebar.
/// Jenis tekstur diselang-seling berdasarkan posisi X supaya level terasa
/// lebih variatif tanpa perlu data tambahan di [LevelData].
class PlatformComponent extends PositionComponent with HasGameReference {
  PlatformComponent({required PlatformSpec spec})
      : _useStone = (spec.position.x ~/ 200).isEven,
        super(position: spec.position.clone(), size: spec.size.clone(), anchor: Anchor.topLeft);

  final bool _useStone;
  late final Image _texture;

  @override
  Future<void> onLoad() async {
    _texture = await game.images.load(
      _useStone ? 'platform/platform_stone.png' : 'platform/platform_brick.png',
    );
  }

  @override
  void render(Canvas canvas) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: _texture,
      fit: BoxFit.fitHeight,
      alignment: Alignment.center,
      repeat: ImageRepeat.repeatX,
    );
  }
}
