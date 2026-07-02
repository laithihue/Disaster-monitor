import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null)
      return _database!; //dùng lại kết nối đã mở trc đó, tránh mở file nhiều lần
    _database = await _initDB('disaster_v5.db'); //mở, tạo file dl
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); //lấy đg dẫn
    final path = join(dbPath, filePath); //ghép đg dẫn với tên tệp
    //await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    ); //mở file
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Chạy lệnh ALTER TABLE để tự động bổ sung cột image_path vào DB hiện tại của user
      await db.execute(
        'ALTER TABLE reported_disasters ADD COLUMN image_path TEXT;',
      );
    }
  }

  // Tạo bảng khớp với các trường trong file JSON của bạn
  Future _createDB(Database db, int version) async {
    //tạo bảngP
    await db.execute('''
      CREATE TABLE disaster_types (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        image TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE reported_disasters (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        disaster_type_id INTEGER,            
        title TEXT,
        description TEXT,
        latitude REAL,                        
        longitude REAL,
        create_time TEXT,
        update_time TEXT,
        image_path TEXT
      )
    ''');
    // await db.execute(
    //   '''
    //   CREATE TABLE report_image(
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    // report_id INTEGER,
    // image_path TEXT,
    // FOREIGN KEY (report_id) REFERENCES reported_disasters (id) ON DELETE CASCADE)''',
    // );
  }
}
