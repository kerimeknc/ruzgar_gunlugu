import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../database/database_helper.dart';
import '../models/entry.dart';
import 'entry_detail_screen.dart';

// Kaydedilen anıların harita üzerinde marker (işaretçi) olarak gösterildiği ekran
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anı Haritası"),
        actions: [
          // Kullanıcının haritayı ve verileri manuel olarak tazelemesini sağlayan buton
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      // Veritabanından veriler gelirken arayüzün durumunu yöneten FutureBuilder
      body: FutureBuilder<List<Entry>>(
        // Her arayüz yenilenmesinde veritabanından güncel anı listesini talep eder
        future: DatabaseHelper.instance.getEntries(),
        builder: (context, snapshot) {
          // Veriler henüz yüklenirken bir yükleme çubuğu gösterir
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Veritabanından gelen tüm anılar içinden sadece koordinat bilgisi olanları filtreler
          final locations =
              snapshot.data?.where((e) => e.latitude != null).toList() ?? [];

          // Eğer haritada gösterilecek konumlu bir anı yoksa kullanıcıyı bilgilendirir
          if (locations.isEmpty) {
            return const Center(child: Text("Henüz konumlu bir anı yok."));
          }

          // Harita bileşenini oluşturur
          return FlutterMap(
            options: MapOptions(
              // Harita açıldığında ilk marker'ın (anı) olduğu konumu merkez alır
              initialCenter: LatLng(
                locations.first.latitude!,
                locations.first.longitude!,
              ),
              initialZoom: 6.0, // Varsayılan yakınlık seviyesi
            ),
            children: [
              // Harita alt tabakasını (OpenStreetMap) sağlayan katman
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ruzgargunlugu.app',
              ),
              // Anıların konumlarını gösteren işaretçiler katmanı
              MarkerLayer(
                markers: locations
                    .map(
                      (entry) => Marker(
                        point: LatLng(entry.latitude!, entry.longitude!),
                        width: 45,
                        height: 45,
                        // Her bir işaretçiyi tıklanabilir hale getiren sarıcı
                        child: GestureDetector(
                          onTap: () async {
                            // İşaretçiye tıklandığında anının detay ekranına yönlendirir
                            // await kullanımı: Detay ekranından geri dönülene kadar bekler
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EntryDetailScreen(entry: entry),
                              ),
                            );
                            // Detay ekranında anı silinmiş veya güncellenmiş olabilir.
                            // Geri dönüldüğünde haritayı (ve FutureBuilder'ı) yeniden tetikleyerek verileri günceller.
                            setState(() {});
                          },
                          // Haritadaki konumun görsel simgesi
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
