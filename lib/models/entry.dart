import 'dart:convert';
// Fotoğraf yollarını (List<String>) veritabanında saklayabilmek için
// JSON formatına dönüştürme ve geri çevirme işlemleri için kullanılır

/// Entry modeli
/// Uygulamadaki tek bir "anı"yı temsil eder
class Entry {
  /// Veritabanı tarafından otomatik atanır
  final int? id;

  /// Anı başlığı (zorunlu)
  final String title;

  /// Anıya ait not / açıklama
  final String note;

  /// Anının tarihi (String formatında tutulur)
  final String date;

  /// Bir anıya ait birden fazla fotoğraf yolu
  /// Liste olarak tutulur, veritabanında JSON String olarak saklanır
  final List<String>? imagePaths;

  /// Konum bilgileri (opsiyonel)
  final double? latitude;
  final double? longitude;

  /// Entry nesnesi oluşturulurken kullanılan constructor
  Entry({
    this.id,
    required this.title,
    required this.note,
    required this.date,
    this.imagePaths,
    this.latitude,
    this.longitude,
  });

  /// Entry nesnesini veritabanına kaydedebilmek için
  /// Map<String, dynamic> yapısına dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': date,

      // Fotoğraf yolları listesi JSON formatında String'e çevrilir
      'imagePaths': imagePaths != null ? jsonEncode(imagePaths) : null,

      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Veritabanından gelen Map yapısını tekrar Entry nesnesine dönüştürür
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as int?,
      title: map['title'] as String,
      note: map['note'] as String,
      date: map['date'] as String,

      // JSON String olarak gelen fotoğraf yolları tekrar List<String>'e çevrilir
      // Null ve boş String kontrolleri ile hata oluşması engellenir
      imagePaths: map['imagePaths'] != null && map['imagePaths'] != ""
          ? List<String>.from(jsonDecode(map['imagePaths']))
          : [],

      // SQLite REAL tipinden gelen değerler double'a dönüştürülür
      latitude: map['latitude'] != null
          ? (map['latitude'] as num).toDouble()
          : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
    );
  }
}
