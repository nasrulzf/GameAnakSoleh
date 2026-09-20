import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_anak_soleh/app/game_progress.dart';
import 'package:game_anak_soleh/ui/level_select_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GameProgress> _progressWithMixedStates() async {
  SharedPreferences.setMockInitialValues({});
  final progress = await GameProgress.load();
  // Level 1: perfect. Level 2: selesai tapi tidak perfect. Level 3: terbuka,
  // belum pernah dimainkan (jadi "current"). Level 4+: masih terkunci.
  await progress.recordLevelResult(1, 200, perfect: true);
  await progress.completeLevel(1);
  await progress.recordLevelResult(2, 120, perfect: false);
  await progress.completeLevel(2);
  return progress;
}

Widget _wrap(GameProgress progress) {
  return ChangeNotifierProvider.value(
    value: progress,
    child: const MaterialApp(home: LevelSelectScreen()),
  );
}

void main() {
  testWidgets('Level Select tampil tanpa error dengan campuran state node', (tester) async {
    final progress = await _progressWithMixedStates();
    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Pilih Level'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('EPISODE 1'), findsOneWidget);

    // Scroll sampai bawah untuk memastikan signpost "segera hadir" (episode
    // yang belum ada levelnya di kLevelMeta) ikut ter-render tanpa error.
    // pumpAndSettle tidak dipakai karena node current/perfect punya animasi
    // loop tanpa akhir (pulsa/glow) — settle tidak akan pernah tercapai.
    await tester.fling(find.byType(Scrollable).first, const Offset(0, -4000), 4000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Segera hadir'), findsOneWidget);
  });

  testWidgets('Tap level terkunci menampilkan snackbar, tidak berpindah layar', (tester) async {
    final progress = await _progressWithMixedStates();
    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    // Level 4 masih terkunci (unlockedLevel baru sampai 3).
    final level4Node = find.byWidgetPredicate(
      (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName.contains('lock_star'),
    );
    expect(level4Node, findsWidgets);

    await tester.tap(level4Node.first);
    await tester.pump();
    expect(find.textContaining('Selesaikan level sebelumnya'), findsOneWidget);
  });
}
