// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:                   Colors.transparent,
    statusBarIconBrightness:          Brightness.dark,
    systemNavigationBarColor:         AriaColors.background,
    systemNavigationBarIconBrightness:Brightness.dark,
  ));

  runApp(const ProviderScope(child: ARIAApp()));
}

class ARIAApp extends StatelessWidget {
  const ARIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARIA — AI Personal Secretary',
      debugShowCheckedModeBanner: false,
      theme: AriaTheme.light,
      home: const SplashScreen(),
    );
  }
}
