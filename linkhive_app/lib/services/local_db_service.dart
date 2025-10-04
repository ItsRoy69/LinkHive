import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/link.dart';

class LocalDbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'linkhive.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE links (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        category_id INTEGER,
        url TEXT NOT NULL,
        title TEXT,
        type TEXT,
        status TEXT,
        metadata TEXT,
        shared_flag INTEGER,
        pinned_flag INTEGER,
        order_index INTEGER,
        is_dead INTEGER,
        synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT,
        data TEXT,
        created_at TEXT
      )
    ''');
  }

  // Save link locally
  Future<int> saveLink(Link link) async {
    final db = await database;
    return await db.insert(
      'links',
      {
        'id': link.id,
        'user_id': link.userId,
        'category_id': link.categoryId,
        'url': link.url,
        'title': link.title,
        'type': link.type.toString().split('.').last,
        'status': link.status.toString().split('.').last,
        'shared_flag': link.sharedFlag ? 1 : 0,
        'pinned_flag': link.pinnedFlag ? 1 : 0,
        'order_index': link.orderIndex,
        'is_dead': link.isDead ? 1 : 0,
        'created_at': link.createdAt?.toIso8601String(),
        'updated_at': link.updatedAt?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all local links
  Future<List<Link>> getLinks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('links');
    return List.generate(maps.length, (i) {
      return Link(
        id: maps[i]['id'],
        userId: maps[i]['user_id'],
        categoryId: maps[i]['category_id'],
        url: maps[i]['url'],
        title: maps[i]['title'],
        type: LinkType.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['type'],
          orElse: () => LinkType.other,
        ),
        status: LinkStatus.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['status'],
          orElse: () => LinkStatus.none,
        ),
        sharedFlag: maps[i]['shared_flag'] == 1,
        pinnedFlag: maps[i]['pinned_flag'] == 1,
        orderIndex: maps[i]['order_index'],
        isDead: maps[i]['is_dead'] == 1,
        createdAt: maps[i]['created_at'] != null 
            ? DateTime.parse(maps[i]['created_at']) 
            : null,
        updatedAt: maps[i]['updated_at'] != null 
            ? DateTime.parse(maps[i]['updated_at']) 
            : null,
      );
    });
  }

  // Delete link locally
  Future<void> deleteLink(int id) async {
    final db = await database;
    await db.delete('links', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all links
  Future<void> clearLinks() async {
    final db = await database;
    await db.delete('links');
  }
}