import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/game_progress.dart';
import 'ui/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final progress = await GameProgress.load();
  runApp(GameAnakSholehApp(progress: progress));
}

class GameAnakSholehApp extends StatelessWidget {
  const GameAnakSholehApp({super.key, required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: progress,
      child: MaterialApp(
        title: 'Game Anak Sholeh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF2563EB), useMaterial3: true),
        home: const MainMenuScreen(),
      ),
    );
  }
}
