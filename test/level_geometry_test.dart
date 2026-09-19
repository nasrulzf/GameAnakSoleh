import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_anak_soleh/game/components/goal_component.dart';
import 'package:game_anak_soleh/game/levels/level_data.dart';
import 'package:game_anak_soleh/game/levels/level_registry.dart';

/// Verifikasi geometri level TANPA menjalankan Flame engine (tidak ada
/// render/asset loading) — pengganti playtest visual manual yang tidak bisa
/// dilakukan di environment ini (lihat
/// requirements/add-50-level-scenario/requirement.md & catatan Phase 2).
///
/// Ini BUKAN simulasi fisika penuh, hanya invarian struktural: setiap
/// platform/quiz gate/goal harus bisa "dijangkau" dari ground lewat rantai
/// lompatan wajar atau tangga, dan setiap gate/goal harus benar-benar
/// bertumpu (bukan melayang) di suatu permukaan yang terjangkau. Tujuannya
/// menangkap kelas kesalahan paling fatal (lompatan mustahil, tangga tidak
/// nyambung, gate melayang) sebelum direview manual.

/// Tinggi lompat maksimum pemain (lihat PlayerComponent: jumpSpeed=760,
/// gravity=1600 -> v^2/(2g) ~= 180px), dipakai sebagai batas aman platform
/// yang harus bisa dicapai murni dengan lompat (tanpa tangga).
const _maxJumpUp = 180.0;

/// Jarak horizontal maksimum yang dianggap wajar untuk satu lompatan/jatuh
/// (heuristik konservatif, bukan hasil simulasi kecepatan x waktu-di-udara
/// presisi -- lihat requirement Phase 2 Bagian Verifikasi Geometri).
const _maxHorizontalGap = 220.0;

/// Toleransi kecil untuk pencocokan tinggi (floating point & desain px).
const _epsilon = 4.0;

class _Surface {
  _Surface(this.label, this.left, this.top, this.right, this.bottom);

  final String label;
  final double left;
  final double top;
  final double right;
  final double bottom;

  bool overlapsX(_Surface other) => left < other.right && right > other.left;

  double horizontalGapTo(_Surface other) {
    if (overlapsX(other)) return 0;
    if (right <= other.left) return other.left - right;
    return left - other.right;
  }

  bool containsX(double left2, double right2, {double epsilon = _epsilon}) =>
      left2 >= left - epsilon && right2 <= right + epsilon;
}

_Surface _fromSpec(String label, Vector2 position, Vector2 size) =>
    _Surface(label, position.x, position.y, position.x + size.x, position.y + size.y);

void main() {
  group('Level geometry (reachability tanpa render)', () {
    for (final entry in kLevelBuilders.entries) {
      test('Level ${entry.key}: semua platform/gate/goal terjangkau & bertumpu', () {
        _verifyLevel(entry.value());
      });
    }
  });
}

void _verifyLevel(LevelData level) {
  final groundTop = level.worldHeight - level.groundHeight;
  final ground = _Surface('ground', 0, groundTop, level.worldWidth, level.worldHeight);

  final surfaces = <_Surface>[ground];
  for (var i = 0; i < level.platforms.length; i++) {
    final p = level.platforms[i];
    surfaces.add(_fromSpec('platform[$i]', p.position, p.size));
  }
  for (var i = 0; i < level.crumblingPlatforms.length; i++) {
    final p = level.crumblingPlatforms[i];
    surfaces.add(_fromSpec('crumblingPlatform[$i]', p.position, p.size));
  }
  for (var i = 0; i < level.movingPlatforms.length; i++) {
    final mp = level.movingPlatforms[i];
    surfaces.add(_fromSpec('movingPlatform[$i].start', mp.position, mp.size));
    final endPos = mp.axis == PatrolAxis.horizontal
        ? Vector2(mp.position.x + mp.travelDistance, mp.position.y)
        : Vector2(mp.position.x, mp.position.y + mp.travelDistance);
    surfaces.add(_fromSpec('movingPlatform[$i].end', endPos, mp.size));
  }

  final ladderRects = [
    for (var i = 0; i < level.ladders.length; i++)
      _fromSpec('ladder[$i]', level.ladders[i].position, level.ladders[i].size),
  ];

  // BFS reachability dari ground, lewat lompatan wajar atau tangga.
  final reachable = <_Surface>{ground};
  var changed = true;
  while (changed) {
    changed = false;
    for (final s in surfaces) {
      if (reachable.contains(s)) continue;
      for (final r in reachable) {
        if (_jumpReachable(r, s) || _ladderConnects(ladderRects, r, s)) {
          reachable.add(s);
          changed = true;
          break;
        }
      }
    }
  }

  final unreachable = surfaces.where((s) => !reachable.contains(s)).toList();
  expect(
    unreachable,
    isEmpty,
    reason: 'Level ${level.id} (${level.title}): permukaan berikut tidak terjangkau dari ground: '
        '${unreachable.map((s) => s.label).join(', ')}',
  );

  for (var i = 0; i < level.quizGates.length; i++) {
    final g = level.quizGates[i];
    _expectSupported(level, 'Quiz gate[$i]', g.position, g.size, reachable);
  }
  _expectSupported(level, 'Goal', level.goalPosition, kGoalSize, reachable);
}

bool _jumpReachable(_Surface from, _Surface to) {
  if (identical(from, to)) return false;
  final verticalDiff = from.top - to.top; // positif = `to` lebih tinggi.
  if (verticalDiff >= 0) {
    // `to` lebih tinggi (atau sejajar): butuh lompat naik, dibatasi jarak
    // horizontal wajar & tinggi lompat maksimum.
    return from.horizontalGapTo(to) <= _maxHorizontalGap && verticalDiff <= _maxJumpUp;
  }
  // `to` lebih rendah -> jatuh. Ground selalu menutupi seluruh worldWidth di
  // bawah segala sesuatu (tidak ada jurang tak berdasar di desain game ini),
  // jadi turun/jatuh dari permukaan manapun selalu aman & tidak dibatasi
  // jarak horizontal.
  return true;
}

bool _ladderConnects(List<_Surface> ladders, _Surface a, _Surface b) {
  for (final ladder in ladders) {
    if (!ladder.overlapsX(a) || !ladder.overlapsX(b)) continue;
    final aIsTop = (a.top - ladder.top).abs() <= _epsilon;
    final bIsBottom = (b.top - ladder.bottom).abs() <= _epsilon;
    if (aIsTop && bIsBottom) return true;
    final bIsTop = (b.top - ladder.top).abs() <= _epsilon;
    final aIsBottom = (a.top - ladder.bottom).abs() <= _epsilon;
    if (bIsTop && aIsBottom) return true;
  }
  return false;
}

void _expectSupported(
  LevelData level,
  String label,
  Vector2 position,
  Vector2 size,
  Set<_Surface> reachable,
) {
  final itemBottom = position.y + size.y;
  final supported = reachable.any(
    (s) => (s.top - itemBottom).abs() <= _epsilon &&
        s.containsX(position.x, position.x + size.x),
  );
  expect(
    supported,
    isTrue,
    reason: 'Level ${level.id} (${level.title}): $label di posisi $position tidak bertumpu di '
        'permukaan manapun yang terjangkau (kemungkinan melayang atau lantai belum terhubung).',
  );
}
