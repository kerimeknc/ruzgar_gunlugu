import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// Kullanıcının harita üzerinden dokunarak veya mevcut konumunu kullanarak yer seçtiği ekran
class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  // Seçilen konumun koordinatlarını tutar, başlangıçta boştur
  LatLng? selectedLocation;
  // Haritayı hareket ettirmek (mevcut konuma gitmek gibi) için kullanılan kontrolcü
  final MapController _mapController = MapController();

  // Cihazın GPS verisini kullanarak mevcut konumu bulan fonksiyon
  Future<void> _getCurrentLocation() async {
    // Konum iznini kontrol eder
    LocationPermission permission = await Geolocator.checkPermission();
    // Eğer izin reddedilmişse kullanıcıdan izin ister
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Cihazın o anki enlem ve boylam bilgisini alır
    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    // Haritayı bulunan konuma odaklayıp yakınlaştırır (zoom: 15.0)
    _mapController.move(currentLatLng, 15.0);
    // Seçilen konumu mevcut konum olarak günceller ve arayüzü yeniler
    setState(() => selectedLocation = currentLatLng);
  }

  @override
  Widget build(BuildContext context) {
    // Koyu modun açık olup olmadığını kontrol eder
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seç'),
        actions: [
          // Eğer bir konum seçilmişse AppBar'da "TAMAM" butonu görünür
          if (selectedLocation != null)
            TextButton(
              // Seçilen konumu bir önceki ekrana (Geri dönerek) iletir
              onPressed: () => Navigator.pop(context, selectedLocation),
              child: const Text(
                "TAMAM",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Harita bileşeni
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Harita ilk açıldığında Türkiye merkezli (39, 35) görünür
              initialCenter: const LatLng(39.0, 35.0),
              initialZoom: 5,
              // Haritada bir noktaya tıklandığında seçilen konumu günceller
              onTap: (_, point) => setState(() => selectedLocation = point),
            ),
            children: [
              // Harita görsellerini (kareleri) OpenStreetMap'ten çeken katman
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ruzgargunlugu',
                // Koyu mod aktifse haritayı görsel olarak filtreleyen fonksiyonu çağırır
                tileBuilder: isDark ? _darkMapFilter : null,
              ),
              // Eğer bir konum seçilmişse harita üzerine kırmızı marker koyar
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Seçilen koordinatların bilgisini gösteren alt panel
          Positioned(
            bottom: 30,
            left: 20,
            right: 80,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Seçim yoksa koyu, seçim varsa tema renginde görünür
                color: selectedLocation == null
                    ? Colors.black87
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: Text(
                // Seçim yapılmamışsa ipucu, yapılmışsa koordinat bilgisini yazar
                selectedLocation == null
                    ? 'Haritadan bir noktaya dokun'
                    : 'Seçilen: ${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  color: selectedLocation == null ? Colors.white : null,
                ),
              ),
            ),
          ),
          // Mevcut konuma gitmeyi sağlayan yuvarlak buton (GPS butonu)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: "btn_loc", // Birden fazla buton varsa karışıklığı önler
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  // Haritayı koyu modda okunabilir kılmak için renkleri tersine çeviren matris filtresi
  Widget _darkMapFilter(context, tileWidget, tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -1, 0, 0, 0, 255, // Kırmızı kanalını ters çevir
        0, -1, 0, 0, 255, // Yeşil kanalını ters çevir
        0, 0, -1, 0, 255, // Mavi kanalını ters çevir
        0, 0, 0, 1, 0, // Opaklığı koru
      ]),
      child: tileWidget,
    );
  }
}
