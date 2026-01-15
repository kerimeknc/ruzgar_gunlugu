import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // 1. SplashScreen importunu ekledik

// Temayı yöneten değişken
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RuzgarGunluguApp());
}

class RuzgarGunluguApp extends StatelessWidget {
  const RuzgarGunluguApp({super.key});

  @override.Widget
  build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rüzgar Günlüğü',
          themeMode: currentMode,

          // 1. VARSAYILAN MAVİ TEMA
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F3B4D),
              primary: const Color(0xFF1F3B4D),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F3B4D),
              foregroundColor: Colors.white,
            ),
            cardTheme: const CardThemeData(elevation: 2),
          ),

          // 2. SİYAH KOYU TEMA
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F3B4D),
              brightness: Brightness.dark,
              surface: const Color(0xFF101820),
            ),
            scaffoldBackgroundColor: const Color(0xFF101820),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F3B4D),
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1F3B4D).withOpacity(0.5),
              elevation: 0,
            ),
          ),

          // 2. BAŞLANGIÇ EKRANI DEĞİŞTİ
          home: const SplashScreen(),
        );
      },
    );
  }
}
