import 'package:flutter_test/flutter_test.dart';
import 'package:game_anak_soleh/app/game_progress.dart';
import 'package:game_anak_soleh/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Main menu tampil tanpa error saat app dijalankan', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await GameProgress.load();

    await tester.pumpWidget(GameAnakSholehApp(progress: progress));
    await tester.pump();

    expect(find.text('Game Anak Sholeh'), findsOneWidget);
    expect(find.text('Mulai Bermain'), findsOneWidget);
  });
}
