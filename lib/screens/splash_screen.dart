import 'package:flutter/material.dart';
import 'dart:async';
import 'main_navigation_screen.dart'; // Navigasyon dosyanın adı farklıysa düzelt

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Logon beyaz olduğu için arka planı beyaz yapalım
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 180), // Tasarladığımız logo
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.blue,
            ), // Yükleme ikonu
          ],
        ),
      ),
    );
  }
}
