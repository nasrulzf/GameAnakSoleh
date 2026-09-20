import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_anak_soleh/app/game_progress.dart';
import 'package:game_anak_soleh/ui/main_menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Main menu tampil tanpa error saat app dijalankan', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await GameProgress.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const MaterialApp(home: MainMenuScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('GAME ANAK SHOLEH'), findsOneWidget);
    expect(find.text('MULAI BERMAIN'), findsOneWidget);
  });
}
