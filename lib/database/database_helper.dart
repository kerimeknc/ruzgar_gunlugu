import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/entry.dart';

/// Veritabanı işlemlerini yöneten yardımcı sınıf
/// SQLite kullanılarak CRUD (Create, Read, Update, Delete) işlemleri yapılır
class DatabaseHelper {
  /// Singleton yapı: Uygulama boyunca tek bir veritabanı örneği kullanılır
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  /// Private constructor
  DatabaseHelper._init();

  /// Veritabanına erişim sağlayan getter
  /// Eğer veritabanı daha önce oluşturulduysa direkt onu döner
  /// Oluşturulmadıysa _initDB() metodu ile oluşturur
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ruzgar_gunlugu.db');
    return _database!;
  }

  /// Veritabanını başlatan metot
  /// Veritabanı dosyasının yolu alınır ve openDatabase ile açılır
  Future<Database> _initDB(String filePath) async {
    // Cihazdaki veritabanı klasörünün yolu
    final dbPath = await getDatabasesPath();

    // Veritabanı dosyasının tam yolu
    final path = join(dbPath, filePath);

    // Veritabanı oluşturuluyor / açılıyor
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Veritabanı ilk kez oluşturulduğunda çalışır
  /// entries tablosu burada tanımlanır
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        note TEXT,
        date TEXT,
        imagePaths TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');
  }

  /// Yeni bir anı kaydı ekler
  /// Entry nesnesi Map'e çevrilerek SQLite veritabanına eklenir
  Future<int> insertEntry(Entry entry) async {
    final db = await instance.database;
    return await db.insert('entries', entry.toMap());
  }

  /// Var olan bir anı kaydını günceller
  /// id değerine göre update işlemi yapılır
  Future<int> updateEntry(Entry entry) async {
    final db = await instance.database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Veritabanındaki tüm anıları liste olarak getirir
  /// En son eklenen anı en üstte olacak şekilde sıralama yapılır
  Future<List<Entry>> getEntries() async {
    final db = await instance.database;
    final result = await db.query('entries', orderBy: 'id DESC');

    // Map listesini Entry nesnelerine dönüştürür
    return result.map((json) => Entry.fromMap(json)).toList();
  }

  /// Belirli bir anıyı siler
  /// id parametresine göre delete işlemi yapılır
  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}
