import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/config_model.dart';

class ConfigLocalDatasource {
  static final ConfigLocalDatasource _instance =
      ConfigLocalDatasource._internal();

  factory ConfigLocalDatasource() => _instance;

  ConfigLocalDatasource._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'bono_config.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE config (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            moneda TEXT,
            tipoTasa TEXT,
            capitalizacion TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveConfig(ConfigModel config) async {
    final db = await database;
    await db.delete('config'); // Guardamos solo 1 configuración activa
    await db.insert('config', config.toMap());
  }

  Future<ConfigModel?> getConfig() async {
    final db = await database;
    final result = await db.query('config', limit: 1);
    if (result.isNotEmpty) {
      return ConfigModel.fromMap(result.first);
    }
    return null;
  }
}
