import 'package:flutter/material.dart';
import '../main.dart'; // Tema değişikliğini tetiklemek için themeNotifier'a erişim
import 'home_screen.dart';
import 'map_screen.dart';
import 'about_screen.dart';

// Uygulamanın ana navigasyon yapısını yöneten, sekmeler arası geçişi sağlayan ana ekran
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Alt menüde (BottomNavigationBar) hangi sekmenin seçili olduğunu tutan değişken
  int _currentIndex = 0;

  // Navigasyon menüsünde geçiş yapılacak olan ekranların listesi
  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Uygulamanın o anki parlaklık ayarını (koyu/açık mod) kontrol eden mantıksal değişken
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // AppBar tüm sekmeler üzerinde sabit kalır, böylece her yerden tema değiştirilebilir
      appBar: AppBar(
        title: const Text('Rüzgar Günlüğü'),
        actions: [
          // Kullanıcının gece/gündüz modu arasında geçiş yapmasını sağlayan buton
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Tema Değiştir',
            onPressed: () {
              // main.dart dosyasında tanımlanan ValueNotifier üzerinden tüm uygulamanın temasını günceller
              themeNotifier.value = isDarkMode
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      // IndexedStack: Sayfalar arası geçiş yaparken sayfaların mevcut durumunu (scrol pozisyonu vb.) korur
      body: IndexedStack(index: _currentIndex, children: _screens),
      // Alt kısımda yer alan navigasyon çubuğu
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Hangi ikonun aktif görüneceğini belirler
        selectedItemColor: Theme.of(
          context,
        ).colorScheme.primary, // Seçili öğenin rengi (temadan gelir)
        unselectedItemColor: Colors.grey, // Seçili olmayan öğelerin rengi
        type: BottomNavigationBarType
            .fixed, // Öğeler arası mesafeyi sabit tutar, kaymayı engeller
        onTap: (index) {
          // Kullanıcı bir sekmeye tıkladığında mevcut indeksi günceller ve arayüzü yeniler
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_motion),
            label: 'Anılar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Harita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Hakkında',
          ),
        ],
      ),
    );
  }
}
