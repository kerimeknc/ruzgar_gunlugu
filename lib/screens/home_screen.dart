import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/entry.dart';
import '../widgets/empty_state.dart';
import 'entry_detail_screen.dart';
import 'add_entry_screen.dart';

// Anıları sıralamak için kullanılan seçenekleri içeren Enum tanımı
enum SortType { dateDesc, dateAsc, titleAsc, titleDesc, shuffle }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Veritabanından gelecek anı listesini tutacak Future nesnesi
  late Future<List<Entry>> _entriesFuture;
  // Varsayılan sıralama türü: Yeniden eskiye
  SortType _currentSort = SortType.dateDesc;
  // Arama metni ve seçili tarih filtrelerini tutan değişkenler
  String _searchTitle = '';
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Uygulama açıldığında verileri yükle
    _loadEntries();
  }

  // Veritabanından verileri çekip arayüzü güncelleyen fonksiyon
  void _loadEntries() {
    setState(() {
      _entriesFuture = DatabaseHelper.instance.getEntries();
    });
  }

  // Gelen ham listeye arama, tarih filtresi ve sıralama kriterlerini uygulayan fonksiyon
  List<Entry> _applyFilters(List<Entry> entries) {
    var list = List<Entry>.from(entries);

    // Başlığa göre arama filtresi (Küçük/büyük harf duyarsız)
    if (_searchTitle.isNotEmpty) {
      list = list
          .where(
            (e) => e.title.toLowerCase().contains(_searchTitle.toLowerCase()),
          )
          .toList();
    }

    // Seçilen tarihe göre filtreleme
    if (_selectedDate != null) {
      list = list.where((e) => e.date.startsWith(_selectedDate!)).toList();
    }

    // Seçili olan sıralama türüne göre listeyi yeniden düzenleme
    switch (_currentSort) {
      case SortType.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortType.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortType.titleAsc:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortType.titleDesc:
        list.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortType.shuffle:
        list.shuffle();
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Üst bilgi çubuğu: Uygulama adı ve aksiyon butonları
      appBar: AppBar(
        title: const Text(
          'Rüzgar Günlüğü',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          // Arama ve filtreleme sayfasını açan buton
          IconButton(
            icon: Icon(
              _searchTitle.isEmpty && _selectedDate == null
                  ? Icons.search
                  : Icons.filter_alt,
            ),
            onPressed: _openSearchSheet,
          ),
          // Sıralama seçeneklerini sunan açılır menü
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (val) => setState(() => _currentSort = val),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: SortType.dateDesc,
                child: Text('Yeni → Eski'),
              ),
              PopupMenuItem(
                value: SortType.dateAsc,
                child: Text('Eski → Yeni'),
              ),
              PopupMenuItem(value: SortType.titleAsc, child: Text('A → Z')),
              PopupMenuItem(value: SortType.titleDesc, child: Text('Z → A')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Aktif bir filtre varsa (arama veya tarih), kullanıcıya bilgi veren 'Chip' widgetları
          if (_searchTitle.isNotEmpty || _selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_searchTitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Ara: $_searchTitle'),
                        onDeleted: () => setState(() => _searchTitle = ''),
                      ),
                    ),
                  if (_selectedDate != null)
                    Chip(
                      label: Text('Tarih: $_selectedDate'),
                      onDeleted: () => setState(() => _selectedDate = null),
                    ),
                ],
              ),
            ),

          // Veritabanı işlemleri asenkron olduğu için FutureBuilder ile veriyi bekleme süreci
          Expanded(
            child: FutureBuilder<List<Entry>>(
              future: _entriesFuture,
              builder: (context, snapshot) {
                // Veri yüklenirken dönen yükleme ikonu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Veri yoksa veya boşsa gösterilecek özel boş durum ekranı
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyState();
                }

                // Veri geldiğinde önce filtreleri uygula
                final entries = _applyFilters(snapshot.data!);
                // Filtreleme sonucu liste boş kalırsa uyarı metni
                if (entries.isEmpty) {
                  return const Center(child: Text('Sonuç bulunamadı.'));
                }

                // Anıları listeleyen ana bileşen
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    // Anıya ait resim yolu olup olmadığını kontrol et
                    final bool hasImage =
                        entry.imagePaths != null &&
                        entry.imagePaths!.isNotEmpty;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          // Anıya tıklandığında detay ekranına git
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EntryDetailScreen(entry: entry),
                            ),
                          );
                          // Detay ekranından dönüldüğünde veri güncellenmiş olabilir, listeyi yenile
                          if (result == true) _loadEntries();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Sol taraftaki fotoğraf alanı
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: hasImage
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(entry.imagePaths![0]),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Sağ taraftaki başlık, not ve tarih bilgisi
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.note,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          entry.date,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Yeni anı ekleme ekranına giden buton
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntryScreen()),
          );
          // Yeni anı eklendikten sonra listeyi veritabanından tekrar çek
          _loadEntries();
        },
        label: const Text('Yeni Anı'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Alt kısımdan açılan arama ve tarih seçme paneli (ModalBottomSheet)
  void _openSearchSheet() {
    final titleController = TextEditingController(text: _searchTitle);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtrele',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Başlığa göre arama yapılan metin alanı
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Başlıkta ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tarih seçme alanı
            ListTile(
              title: Text(_selectedDate ?? 'Tarih Seçin'),
              leading: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(
                    () => _selectedDate = picked.toString().split(' ')[0],
                  );
                  // Tarih seçildikten sonra paneli kapatıp güncel durumla tekrar aç (UI güncellemesi için)
                  Navigator.pop(ctx);
                  _openSearchSheet();
                }
              },
            ),
            const SizedBox(height: 20),
            // Filtreleri uygulayıp ana ekranı güncelleyen buton
            ElevatedButton(
              onPressed: () {
                setState(() => _searchTitle = titleController.text);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Uygula'),
            ),
          ],
        ),
      ),
    );
  }
}
