import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Kullanıcının harita üzerinden bir nokta seçmesini sağlayan ekran
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Kullanıcının haritada tıkladığı koordinatı tutan değişken
  LatLng? _selectedLocation;
  // Haritayı programatik olarak kontrol etmeye (zoom, hareket vb.) yarayan kontrolcü
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    // Uygulamanın o anki temasının koyu mod olup olmadığını kontrol eder
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Konum Seç')),
      body: Stack(
        children: [
          // Ana Harita Bileşeni
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Harita ilk açıldığında Ankara koordinatlarını merkez alır
              initialCenter: const LatLng(39.9334, 32.8597),
              initialZoom: 6,
              // Haritaya tıklandığında çalışan fonksiyon
              onTap: (tapPosition, point) {
                setState(() {
                  // Tıklanan noktanın koordinatlarını değişkene aktarır
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              // Harita katmanlarını (sokaklar, binalar vb.) getiren katman
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ruzgargunlugu',
                // 🌙 KOYU MOD DESTEĞİ: Eğer tema koyuysa, harita renklerini tersine çevirir (Invert)
                tileBuilder: isDark
                    ? (context, tileWidget, tile) => ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -1, 0, 0, 0, 255, // Kırmızı kanalını ters çevir
                          0, -1, 0, 0, 255, // Yeşil kanalını ters çevir
                          0, 0, -1, 0, 255, // Mavi kanalını ters çevir
                          0, 0, 0, 1, 0, // Opaklığı koru
                        ]),
                        child: tileWidget,
                      )
                    : null,
              ),
              // Eğer bir konum seçildiyse, harita üzerine kırmızı bir işaretçi (Marker) koyar
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 💡 KULLANICI İPUCU: Henüz seçim yapılmadıysa üstte bir bilgilendirme balonu gösterir
          if (_selectedLocation == null)
            Positioned(
              top: 10,
              left: 50,
              right: 50,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Haritaya dokunarak yer seçin',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // SEÇİMİ ONAYLAMA BUTONU: Alt kısımda yer alır
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              // Seçim yapılana kadar butonu görünmez (opaklık 0) tutar, seçilince gösterir
              opacity: _selectedLocation == null ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('SEÇİMİ TAMAMLA'),
                onPressed: _selectedLocation == null
                    ? null // Seçim yoksa buton tıklanamaz
                    : () => Navigator.pop(
                        context,
                        _selectedLocation,
                      ), // Seçilen konumu bir önceki ekrana döndürür
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
