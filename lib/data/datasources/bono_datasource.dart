import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';

class BonoDataSource {
  static Database? _database;
  static final BonoDataSource db = BonoDataSource._();

  BonoDataSource._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'bonos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bonos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valorNominal REAL,
        tasa REAL,
        frecuenciaPago TEXT,
        plazoAnios INTEGER,
        fechaEmision TEXT,
        fechaVencimiento TEXT
      )
    ''');
  }

  Future<int> insertarBono(BonoModel bono) async {
    final db = await database;
    return await db.insert('bonos', bono.toMap());
  }

  Future<List<BonoModel>> obtenerBonos() async {
    final db = await database;
    final res = await db.query('bonos');
    return res.map((e) => BonoModel.fromMap(e)).toList();
  }

  Future<int> eliminarBono(int id) async {
    final db = await database;
    return await db.delete('bonos', where: 'id = ?', whereArgs: [id]);
  }
}
