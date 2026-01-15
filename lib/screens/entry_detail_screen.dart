import 'dart:io';
import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../database/database_helper.dart';
import 'add_entry_screen.dart';

// Belirli bir anının tüm detaylarını (fotoğraflar, notlar, tarih) gösteren ekran
class EntryDetailScreen extends StatefulWidget {
  final Entry entry; // Gösterilecek olan anı nesnesi
  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  // Ekran içinde güncellenebilir olması için anıyı yerel bir değişkende tutuyoruz
  late Entry _currentEntry;

  @override
  void initState() {
    super.initState();
    // widget'tan gelen ilk veriyi yerel değişkene atıyoruz
    _currentEntry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEntry.title), // AppBar başlığı anının başlığı olur
        actions: [
          // ✏️ DÜZENLE BUTONU: Mevcut anıyı düzenleme ekranına gönderir
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEntryScreen(entry: _currentEntry),
                ),
              );
              // Eğer düzenleme ekranından 'true' döndüyse (kaydedildiyse)
              if (result == true) {
                // Listeyi tetiklemek için bu ekranı kapatıp ana sayfaya haber veriyoruz
                Navigator.pop(context, true);
              }
            },
          ),
          // 🗑️ SİL BUTONU: Anıyı veritabanından kalıcı olarak kaldırır
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Veritabanı yardımcısını kullanarak ID üzerinden silme işlemini yapar
              await DatabaseHelper.instance.deleteEntry(_currentEntry.id!);
              // İşlem bitince ve ekran hala aktifse (mounted), önceki sayfaya döner
              if (mounted) Navigator.pop(context, true);
            },
          ),
        ],
      ),
      // İçeriğin taşmasını önlemek ve kaydırılabilir yapmak için SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eğer anıya ait fotoğraflar varsa onları liste halinde gösterir
            if (_currentEntry.imagePaths != null &&
                _currentEntry.imagePaths!.isNotEmpty)
              SizedBox(
                height: 250, // Fotoğrafların dikey yüksekliği
                child: ListView.builder(
                  scrollDirection: Axis
                      .horizontal, // Fotoğrafları yan yana kaydırılabilir yapar
                  itemCount: _currentEntry.imagePaths!.length,
                  itemBuilder: (context, index) {
                    final path = _currentEntry.imagePaths![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          15,
                        ), // Fotoğraf köşelerini yuvarlar
                        child: Image.file(
                          File(path), // Dosya yolundan resmi yükler
                          fit: BoxFit.cover,
                          width: 300,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            // Anının kaydedildiği tarih bilgisi
            Text(
              _currentEntry.date,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Divider(
              height: 30,
            ), // Tarih ile notlar arasına ince bir çizgi çeker
            const Text(
              "Notlar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Kullanıcının yazdığı uzun notun metni
            Text(_currentEntry.note, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
