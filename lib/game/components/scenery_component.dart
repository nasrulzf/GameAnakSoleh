import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, paintImage;

/// Latar dekoratif (rumah & pohon kelapa) yang berjejer di sepanjang jalan,
/// murni kosmetik (tidak solid, tidak dicek tabrakan) supaya perjalanan
/// terasa seperti melewati sebuah desa, bukan cuma langit kosong. Digambar
/// sebagai satu komponen yang menaruh beberapa sprite pada posisi tetap,
/// bukan berulang otomatis, supaya lebih murah dari sisi performa
/// dibanding menambah banyak komponen kecil terpisah.
class SceneryComponent extends PositionComponent with HasGameReference {
  SceneryComponent({required double worldWidth, required double groundY})
      : _worldWidth = worldWidth,
        _groundY = groundY,
        super(priority: -1);

  final double _worldWidth;
  final double _groundY;

  late final Image _houseA;
  late final Image _houseB;
  late final Image _palmTree;
  late final Image _mosque;
  late final Image _bananaTree;
  late final Image _bush;

  final List<_Prop> _props = [];

  @override
  Future<void> onLoad() async {
    _houseA = await game.images.load('scenery/house_a.png');
    _houseB = await game.images.load('scenery/house_b.png');
    _palmTree = await game.images.load('scenery/palm_tree.png');
    _mosque = await game.images.load('buildings/mosque.png');
    _bananaTree = await game.images.load('scenery/banana_tree.png');
    _bush = await game.images.load('scenery/bush.png');

    const spacing = 480.0;
    const margin = 260.0;
    var i = 0;
    for (var x = margin; x < _worldWidth - margin; x += spacing) {
      final kind = i % 6;
      final Image image;
      final double aspect;
      final double height;
      switch (kind) {
        case 0:
          image = _houseA;
          aspect = _houseA.width / _houseA.height;
          height = 150;
        case 1:
          image = _palmTree;
          aspect = _palmTree.width / _palmTree.height;
          height = 190;
        case 2:
          image = _houseB;
          aspect = _houseB.width / _houseB.height;
          height = 140;
        case 3:
          image = _mosque;
          aspect = _mosque.width / _mosque.height;
          height = 200;
        case 4:
          image = _bananaTree;
          aspect = _bananaTree.width / _bananaTree.height;
          height = 130;
        default:
          image = _bush;
          aspect = _bush.width / _bush.height;
          height = 70;
      }
      _props.add(_Prop(image: image, x: x, width: height * aspect, height: height));
      i++;
    }
  }

  @override
  void render(Canvas canvas) {
    for (final prop in _props) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(prop.x, _groundY - prop.height, prop.width, prop.height),
        image: prop.image,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
      );
    }
  }
}

class _Prop {
  const _Prop({required this.image, required this.x, required this.width, required this.height});

  final Image image;
  final double x;
  final double width;
  final double height;
}
