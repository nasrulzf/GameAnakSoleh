import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'app/game_progress.dart';
import 'ui/splash_screen.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Android 12+ me-render Flutter lewat SurfaceView terpisah yang tidak
  // memicu auto-dismiss splash native bawaan OS, jadi splash bisa nyangkut
  // beberapa detik menutupi konten Flutter. `preserve` menahannya secara
  // eksplisit sampai [SplashScreen] memanggil `FlutterNativeSplash.remove()`
  // di awal initState-nya, begitu widget custom-nya siap ditampilkan.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const GameAnakSholehApp());
}

class GameAnakSholehApp extends StatelessWidget {
  const GameAnakSholehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProgress.empty(),
      child: MaterialApp(
        title: 'Game Anak Sholeh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF2563EB), useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}
