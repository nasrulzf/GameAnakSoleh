import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show Alignment, BoxFit, paintImage;

import '../../app/game_progress.dart';
import '../game_anak_soleh.dart';
import 'goal_component.dart';
import 'quiz_gate_component.dart';

const _kDirections = ['right', 'left'];
const _kPoses = ['idle', 'walk1', 'walk2', 'jump'];

/// Karakter pemain: fisika platformer sederhana (gravitasi, lompat, tabrakan
/// AABB manual terhadap tanah/platform/rintangan/gerbang soal) + sprite
/// hasil potong dari lembar karakter berseragam SD (peci untuk laki-laki,
/// kerudung untuk perempuan), dengan frame diam/jalan/lompat terpisah per
/// arah hadap.
///
/// Gerak horizontal memakai percepatan/perlambatan (bukan lompat langsung ke
/// kecepatan penuh) dan lompatan diberi efek "squash & stretch" supaya terasa
/// lebih hidup/bumpy, tanpa mengubah tinggi lompat maksimum atau kecepatan
/// puncak yang sudah dipakai untuk desain level (lihat komentar di level_1
/// & level_2 soal tinggi gate/platform).
class PlayerComponent extends PositionComponent with HasGameReference<GameAnakSoleh> {
  PlayerComponent({required this.gender, required Vector2 startPosition})
      : _startPosition = startPosition.clone(),
        super(position: startPosition.clone(), size: Vector2(48, 64), anchor: Anchor.topLeft);

  static const double _speed = 220;
  static const double _gravity = 1600;
  static const double _jumpSpeed = 760;
  static const double _maxFallSpeed = 900;

  /// Seberapa cepat kecepatan horizontal naik menuju [_speed] saat tombol
  /// ditekan, dan turun menuju 0 saat dilepas. Nilainya dijaga cukup tinggi
  /// (mencapai kecepatan penuh dalam < 0.3 detik) supaya kontrol tetap
  /// responsif untuk anak kecil, hanya tidak lagi instan/konstan.
  static const double _acceleration = 1000;
  static const double _deceleration = 1500;

  /// Kecepatan pemulihan bentuk squash/stretch kembali ke normal (per detik).
  static const double _squashRecovery = 10;

  /// Kecepatan putaran siklus jalan (radian/detik) saat karakter bergerak
  /// pada kecepatan penuh. Diskalakan dengan kecepatan aktual supaya ayunan
  /// kaki/tangan tetap terasa sinkron dengan gerakan, bukan berputar konstan.
  static const double _walkFrequency = 9;

  final CharacterGender gender;
  final Vector2 _startPosition;
  final Vector2 velocity = Vector2.zero();

  // Sprite hasil potong dari lembar karakter (lihat
  // requirements/character-enhancements/assets/), satu gambar per
  // kombinasi arah hadap & pose, dimuat sekali di [onLoad].
  late final Map<String, Image> _sprites;

  /// Diset true oleh GameAnakSoleh begitu semua peti/quiz gate di level ini
  /// sudah dijawab benar. Menampilkan ikon kunci kecil mengambang di atas
  /// kepala karakter, dan menjadi syarat GoalComponent (pintu) bisa dianggap
  /// selesai (lihat pengecekan goalRect di [update]).
  bool hasKey = false;
  late final Image _keyIcon;

  bool movingLeft = false;
  bool movingRight = false;
  bool _grounded = false;
  bool _jumpQueued = false;

  /// Arah hadap terakhir; hanya berubah saat persis satu tombol arah
  /// ditekan, supaya karakter tidak "meloncat" balik menghadap kanan saat
  /// tombol dilepas di tengah jalan ke kiri.
  bool _facingLeft = false;

  // Fase (radian) & amplitudo (0..1) siklus jalan, dipakai render() untuk
  // mengayun kaki/tangan secara halus lewat sinus alih-alih tukar antar 2
  // gambar diam. Amplitudo mengikuti rasio kecepatan aktual terhadap
  // [_speed] sehingga kaki meluruskan diri secara mulus saat berhenti.
  double _walkPhase = 0;
  double _walkAmplitude = 0;

  // Skala visual untuk efek squash (mendarat) & stretch (melompat). 1.0 =
  // bentuk normal. Murni kosmetik di render(), tidak memengaruhi [bounds]
  // ataupun resolusi tabrakan.
  double _squashX = 1;
  double _squashY = 1;

  VoidCallback? onReachGoal;
  void Function(QuizGateComponent gate)? onGateBlocked;

  @override
  Future<void> onLoad() async {
    final entries = await Future.wait([
      for (final direction in _kDirections)
        for (final pose in _kPoses)
          game.images
              .load('characters/${gender.name}_${direction}_$pose.png')
              .then((image) => MapEntry('${direction}_$pose', image)),
    ]);
    _sprites = Map.fromEntries(entries);
    _keyIcon = await game.images.load('items/key_icon.png');
  }

  void requestJump() {
    if (_grounded) {
      _jumpQueued = true;
    }
  }

  Rect get bounds => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  void _respawn() {
    position.setFrom(_startPosition);
    velocity.setZero();
    _grounded = false;
    _squashX = 1;
    _squashY = 1;
    _walkPhase = 0;
    _walkAmplitude = 0;
  }

  /// Menggeser [current] menuju [target] sejauh maksimum [maxDelta], tanpa
  /// pernah melewatinya (dipakai supaya percepatan/perlambatan tidak
  /// membuat kecepatan melebihi batas [_speed]).
  double _moveToward(double current, double target, double maxDelta) {
    final diff = target - current;
    if (diff.abs() <= maxDelta) return target;
    return current + maxDelta * diff.sign;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Batasi dt sebisa mungkin supaya satu frame yang macet/telat (hiccup,
    // app di-background lalu kembali, dsb.) tidak membuat pemain "menembus"
    // tanah setebal [_maxFallSpeed]*dt dalam satu langkah fisika (tunneling).
    dt = dt > 0.05 ? 0.05 : dt;

    if (movingLeft != movingRight) {
      _facingLeft = movingLeft;
    }

    final targetSpeed = movingLeft == movingRight ? 0.0 : (movingLeft ? -_speed : _speed);
    final rate = targetSpeed == 0 ? _deceleration : _acceleration;
    velocity.x = _moveToward(velocity.x, targetSpeed, rate * dt);

    velocity.y += _gravity * dt;
    if (velocity.y > _maxFallSpeed) velocity.y = _maxFallSpeed;

    final wasGrounded = _grounded;
    if (_jumpQueued && _grounded) {
      velocity.y = -_jumpSpeed;
      _grounded = false;
      // Stretch: badan memanjang sesaat saat menolak dari tanah.
      _squashX = 0.82;
      _squashY = 1.22;
    }
    _jumpQueued = false;

    final solids = game.currentSolids();

    // Sumbu X.
    position.x += velocity.x * dt;
    position.x = position.x.clamp(0, game.level.worldWidth - size.x);
    var b = bounds;
    for (final solid in solids) {
      if (!b.overlaps(solid.rect)) continue;
      if (velocity.x > 0) {
        position.x = solid.rect.left - size.x;
      } else if (velocity.x < 0) {
        position.x = solid.rect.right;
      }
      b = bounds;
    }

    // Sumbu Y.
    position.y += velocity.y * dt;
    _grounded = false;
    b = bounds;
    for (final solid in solids) {
      if (!b.overlaps(solid.rect)) continue;
      if (velocity.y > 0) {
        position.y = solid.rect.top - size.y;
        velocity.y = 0;
        _grounded = true;
      } else if (velocity.y < 0) {
        position.y = solid.rect.bottom;
        velocity.y = 0;
      }
      b = bounds;
    }

    // Peti kunci tidak solid (lihat GameAnakSoleh.currentSolids) — cukup
    // disentuh untuk memicu soalnya, supaya peti terasa seperti benda yang
    // "didatangi", bukan tembok tak kasat mata yang menghalangi jalan.
    for (final gate in game.quizGates) {
      if (!gate.solved && b.overlaps(gate.bounds)) {
        onGateBlocked?.call(gate);
      }
    }

    if (!wasGrounded && _grounded) {
      // Squash: badan memipih sesaat saat mendarat, lalu memantul balik
      // normal di bawah — inilah yang membuat lompatan terasa "bumpy".
      _squashX = 1.2;
      _squashY = 0.8;
    }

    // Pegas sederhana yang menarik squash/stretch kembali ke 1.0 tiap
    // frame; framerate-independent lewat faktor eksponensial.
    final recovery = 1 - math.exp(-_squashRecovery * dt);
    _squashX += (1 - _squashX) * recovery;
    _squashY += (1 - _squashY) * recovery;

    // Siklus jalan hanya berjalan di darat; amplitudonya mengikuti rasio
    // kecepatan aktual terhadap [_speed] supaya kaki melambat & meluruskan
    // diri secara halus mengikuti percepatan/perlambatan, bukan berhenti
    // mendadak di tengah langkah.
    _walkAmplitude = _grounded ? (velocity.x.abs() / _speed).clamp(0.0, 1.0) : 0.0;
    if (_grounded && _walkAmplitude > 0.02) {
      _walkPhase += dt * _walkFrequency * (0.4 + 0.6 * _walkAmplitude);
      _walkPhase %= math.pi * 2;
    }

    // Jaga-jaga bila keluar dari batas dunia (seharusnya tidak terjadi karena
    // tidak ada jurang di desain level 1 & 2), kembalikan ke titik start.
    if (position.y > game.level.worldHeight + 200) {
      _respawn();
      return;
    }

    final goalRect = Rect.fromLTWH(
      game.level.goalPosition.x,
      game.level.goalPosition.y,
      kGoalSize.x,
      kGoalSize.y,
    );
    // Pintu di ujung level cuma bisa diselesaikan bila pemain sudah
    // memegang kunci (semua peti/[QuizGateComponent] di level sudah
    // dijawab benar) — lihat GameAnakSoleh yang mengeset [hasKey].
    if (hasKey && bounds.overlaps(goalRect)) {
      onReachGoal?.call();
    }
  }

  @override
  void render(Canvas canvas) {
    // Sedikit condong ke arah gerak (maks ~3 derajat) supaya jalan/lari
    // terasa punya momentum, bukan geser kaku.
    final tilt = (velocity.x / _speed).clamp(-1.0, 1.0) * 0.05;

    // Pose: melompat selama tidak menapak tanah, jalan (dua frame berselang-
    // seling mengikuti fase siklus jalan) selama bergerak cukup cepat,
    // selain itu diam.
    final pose = !_grounded
        ? 'jump'
        : (_walkAmplitude > 0.05 ? (math.sin(_walkPhase) >= 0 ? 'walk1' : 'walk2') : 'idle');
    final direction = _facingLeft ? 'left' : 'right';
    final sprite = _sprites['${direction}_$pose']!;

    canvas.save();
    canvas.translate(size.x / 2, size.y);
    canvas.rotate(tilt);
    canvas.scale(_squashX, _squashY);
    canvas.translate(-size.x / 2, -size.y);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.x, size.y),
      image: sprite,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
    canvas.restore();

    if (hasKey) {
      const keySize = 22.0;
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(size.x / 2 - keySize / 2, -keySize - 6, keySize, keySize),
        image: _keyIcon,
        fit: BoxFit.contain,
      );
    }
  }
}
