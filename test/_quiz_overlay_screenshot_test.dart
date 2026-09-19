import 'dart:io';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game_anak_soleh/app/game_progress.dart';
import 'package:game_anak_soleh/game/game_anak_soleh.dart';
import 'package:game_anak_soleh/game/levels/level_1.dart';
import 'package:game_anak_soleh/quiz/quiz_overlay.dart';

Future<void> _capture(WidgetTester tester, String filename) async {
  final element = find.byType(RepaintBoundary).evaluate().first;
  final boundary = element.renderObject! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1.0);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  File(filename).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets(
    'screenshot normal & error state',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // ignore: avoid_print
      print('STEP 1: building level');
      final level = buildLevel1();
      final game = GameAnakSoleh(level: level, gender: CharacterGender.boy, onLevelComplete: (_) {});
      final question = level.quizGates.first.question;

      // ignore: avoid_print
      print('STEP 2: pumpWidget');
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            child: Scaffold(body: QuizOverlay(game: game, question: question)),
          ),
        ),
      );
      // ignore: avoid_print
      print('STEP 3: first pump done, pumping again');
      await tester.pump(const Duration(milliseconds: 100));
      // ignore: avoid_print
      print('STEP 4: capturing normal screenshot');
      await _capture(tester, 'test/_screenshot_normal.png');

      // ignore: avoid_print
      print('STEP 5: tapping wrong answer');
      final wrongIndex = question.correctIndex == 0 ? 1 : 0;
      final target = find.text(question.options[wrongIndex]).first;
      // ignore: avoid_print
      print('STEP 5a: finder resolved, calling tap');
      await tester.tap(target, warnIfMissed: false);
      // ignore: avoid_print
      print('STEP 5b: tap awaited, pumping');
      await tester.pump(const Duration(milliseconds: 100));
      // ignore: avoid_print
      print('STEP 6: capturing error screenshot');
      await _capture(tester, 'test/_screenshot_error.png');
      // ignore: avoid_print
      print('STEP 7: done');
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
