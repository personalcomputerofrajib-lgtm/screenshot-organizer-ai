import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/constants.dart';
import '../models/screenshot_model.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE screenshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL UNIQUE,
        extracted_text TEXT,
        category TEXT,
        date_added INTEGER NOT NULL,
        date_taken INTEGER,
        is_pinned INTEGER DEFAULT 0,
        is_scanned INTEGER DEFAULT 0,
        file_hash TEXT,
        thumbnail_path TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_screenshots_category ON screenshots(category)',
    );
    await db.execute(
      'CREATE INDEX idx_screenshots_date ON screenshots(date_taken)',
    );
    await db.execute(
      'CREATE INDEX idx_screenshots_pinned ON screenshots(is_pinned)',
    );
    await db.execute(
      'CREATE INDEX idx_screenshots_scanned ON screenshots(is_scanned)',
    );
    await db.execute(
      'CREATE INDEX idx_screenshots_hash ON screenshots(file_hash)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  // ========== INSERT ==========

  Future<int> insertScreenshot(ScreenshotModel screenshot) async {
    final db = await database;
    return await db.insert(
      'screenshots',
      screenshot.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertScreenshots(List<ScreenshotModel> screenshots) async {
    final db = await database;
    final batch = db.batch();
    for (final screenshot in screenshots) {
      batch.insert(
        'screenshots',
        screenshot.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  // ========== READ ==========

  Future<List<ScreenshotModel>> getAllScreenshots({
    int? limit,
    int? offset,
    String orderBy = 'date_taken DESC',
  }) async {
    final db = await database;
    final maps = await db.query(
      'screenshots',
      where: 'is_scanned = 1',
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => ScreenshotModel.fromMap(map)).toList();
  }

  Future<ScreenshotModel?> getScreenshotById(int id) async {
    final db = await database;
    final maps = await db.query(
      'screenshots',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ScreenshotModel.fromMap(maps.first);
  }

  Future<List<ScreenshotModel>> getScreenshotsByCategory(
    String category, {
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final maps = await db.query(
      'screenshots',
      where: 'category = ? AND is_scanned = 1',
      whereArgs: [category],
      orderBy: 'date_taken DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => ScreenshotModel.fromMap(map)).toList();
  }

  Future<List<ScreenshotModel>> getPinnedScreenshots() async {
    final db = await database;
    final maps = await db.query(
      'screenshots',
      where: 'is_pinned = 1 AND is_scanned = 1',
      orderBy: 'date_taken DESC',
    );
    return maps.map((map) => ScreenshotModel.fromMap(map)).toList();
  }

  Future<List<ScreenshotModel>> getUnscannedScreenshots({
    int? limit,
  }) async {
    final db = await database;
    final maps = await db.query(
      'screenshots',
      where: 'is_scanned = 0',
      orderBy: 'date_added ASC',
      limit: limit,
    );
    return maps.map((map) => ScreenshotModel.fromMap(map)).toList();
  }

  Future<List<ScreenshotModel>> searchScreenshots(String query) async {
    final db = await database;
    final searchTerm = '%${query.toLowerCase()}%';
    final maps = await db.query(
      'screenshots',
      where: 'is_scanned = 1 AND (LOWER(extracted_text) LIKE ? OR LOWER(category) LIKE ?)',
      whereArgs: [searchTerm, searchTerm],
      orderBy: 'date_taken DESC',
    );
    return maps.map((map) => ScreenshotModel.fromMap(map)).toList();
  }

  Future<Map<String, int>> getCategoryCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM screenshots
      WHERE is_scanned = 1 AND category IS NOT NULL
      GROUP BY category
    ''');
    final counts = <String, int>{};
    for (final row in result) {
      counts[row['category'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<int> getTotalCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM screenshots WHERE is_scanned = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> screenshotExists(String imagePath) async {
    final db = await database;
    final result = await db.query(
      'screenshots',
      where: 'image_path = ?',
      whereArgs: [imagePath],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<ScreenshotModel>> getScreenshotsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      'screenshots',
      where: 'is_scanned = 1 AND date_taken >= ? AND date_taken <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date_taken DESC',
    );
    return maps.map((map) => ScreenshotModel.fromMap(map)).toList();
  }

  // ========== UPDATE ==========

  Future<int> updateScreenshot(ScreenshotModel screenshot) async {
    final db = await database;
    return await db.update(
      'screenshots',
      screenshot.toMap(),
      where: 'id = ?',
      whereArgs: [screenshot.id],
    );
  }

  Future<void> togglePin(int id, bool isPinned) async {
    final db = await database;
    await db.update(
      'screenshots',
      {'is_pinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCategory(int id, String category) async {
    final db = await database;
    await db.update(
      'screenshots',
      {'category': category},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsScanned(
    int id, {
    required String extractedText,
    required String category,
    String? fileHash,
  }) async {
    final db = await database;
    await db.update(
      'screenshots',
      {
        'is_scanned': 1,
        'extracted_text': extractedText,
        'category': category,
        'file_hash': fileHash,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== DELETE ==========

  Future<int> deleteScreenshot(int id) async {
    final db = await database;
    return await db.delete(
      'screenshots',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllScreenshots() async {
    final db = await database;
    await db.delete('screenshots');
  }

  // ========== DUPLICATES ==========

  Future<List<List<ScreenshotModel>>> findDuplicates() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT file_hash, COUNT(*) as count
      FROM screenshots
      WHERE is_scanned = 1 AND file_hash IS NOT NULL AND file_hash != ''
      GROUP BY file_hash
      HAVING count > 1
    ''');

    final duplicateGroups = <List<ScreenshotModel>>[];
    for (final row in result) {
      final hash = row['file_hash'] as String;
      final maps = await db.query(
        'screenshots',
        where: 'file_hash = ?',
        whereArgs: [hash],
        orderBy: 'date_taken ASC',
      );
      duplicateGroups.add(
        maps.map((map) => ScreenshotModel.fromMap(map)).toList(),
      );
    }
    return duplicateGroups;
  }

  // ========== CLEANUP ==========

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
