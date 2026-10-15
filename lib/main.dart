import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart'; // On importe le nouvel écran animé !

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  
  runApp(const YMediSaveApp());
}

class YMediSaveApp extends StatelessWidget {
  const YMediSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YMediSave',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // L'application s'ouvre maintenant sur le SplashScreen
      home: const SplashScreen(),
    );
  }
}
