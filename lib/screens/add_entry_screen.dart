import 'dart:io';
// Fotoğraf dosyalarını File tipiyle kullanabilmek için

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Galeriden fotoğraf seçme işlemleri için

import 'package:latlong2/latlong.dart';
// Harita üzerinde konum (latitude, longitude) tutmak için

import 'package:intl/intl.dart';
// Tarih formatlama işlemleri için

import '../database/database_helper.dart';
import '../models/entry.dart';
import 'pick_location_screen.dart';

/// Yeni anı ekleme ve mevcut anıyı düzenleme ekranı
/// StatefulWidget kullanılmasının sebebi:
/// - Form alanları
/// - Seçilen tarih, fotoğraf ve konum gibi
///   dinamik verilerin ekranda anlık güncellenmesi
class AddEntryScreen extends StatefulWidget {
  /// Eğer entry null ise → yeni anı ekleme
  /// Eğer dolu ise → düzenleme modu
  final Entry? entry;

  const AddEntryScreen({super.key, this.entry});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  /// TextField verilerini kontrol etmek için controller'lar
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  /// Kullanıcının seçtiği fotoğraflar
  List<File> _selectedImages = [];

  /// Kullanıcının seçtiği konum (opsiyonel)
  LatLng? _selectedLocation;

  /// Anının tarihi
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Eğer bu ekran "düzenleme" modunda açıldıysa
    // mevcut verileri form alanlarına doldururuz
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _noteController.text = widget.entry!.note;

      // Veritabanından gelen fotoğraf yollarını File listesine çeviriyoruz
      _selectedImages =
          widget.entry!.imagePaths?.map((path) => File(path)).toList() ?? [];

      // Konum bilgisi varsa LatLng nesnesine dönüştürülür
      if (widget.entry!.latitude != null) {
        _selectedLocation = LatLng(
          widget.entry!.latitude!,
          widget.entry!.longitude!,
        );
      }

      // String olarak tutulan tarih tekrar DateTime'a çevrilir
      try {
        _selectedDate = DateFormat(
          'dd.MM.yyyy HH:mm',
        ).parse(widget.entry!.date);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
  }

  /// 📅 Tarih seçme fonksiyonu
  /// showDatePicker asenkron çalışır
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // Kullanıcı tarih seçtiyse state güncellenir
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  /// 📸 Galeriden fotoğraf seçme fonksiyonu
  /// Asenkron çalışır
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  /// 💾 Kaydetme işlemi
  /// Hem ekleme hem güncelleme işlemini yönetir
  Future<void> _save() async {
    // Basit form doğrulaması
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen başlık girin!")));
      return;
    }

    // Formdan gelen verilerle Entry nesnesi oluşturulur
    final entry = Entry(
      id: widget.entry?.id,
      title: _titleController.text,
      note: _noteController.text,
      date: DateFormat('dd.MM.yyyy HH:mm').format(_selectedDate),
      imagePaths: _selectedImages.map((e) => e.path).toList(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
    );

    try {
      // Eğer yeni anıysa insert, değilse update yapılır
      if (widget.entry == null) {
        await DatabaseHelper.instance.insertEntry(entry);
      } else {
        await DatabaseHelper.instance.updateEntry(entry);
      }

      // true değeri ile önceki ekrana dönülür
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? "Yeni Anı" : "Anıyı Düzenle"),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),

      // Klavye taşması olmaması için SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık alanı
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Başlık",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // Not alanı
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Anınız...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// Tarih seçme bileşeni
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Anı Tarihi"),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.edit),
              onTap: _pickDate,
              tileColor: Colors.blue.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 15),

            /// Konum seçme bileşeni
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text("Konum Bilgisi"),
              subtitle: Text(
                _selectedLocation == null
                    ? "Konum Seçilmedi"
                    : "Seçildi: ${_selectedLocation!.latitude.toStringAsFixed(3)}, "
                          "${_selectedLocation!.longitude.toStringAsFixed(3)}",
              ),
              trailing: const Icon(Icons.map),
              onTap: () async {
                final loc = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PickLocationScreen()),
                );
                if (loc != null) setState(() => _selectedLocation = loc);
              },
            ),

            const SizedBox(height: 20),

            /// Fotoğraf ekleme ve önizleme alanı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Fotoğraflar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Ekle"),
                ),
              ],
            ),

            // Fotoğraf yoksa bilgi mesajı
            if (_selectedImages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Henüz fotoğraf seçilmedi.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 12,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: () => setState(
                                () => _selectedImages.removeAt(index),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 50),

            // Kaydetme butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text(
                  "ANIYI KAYDET",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
