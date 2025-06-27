import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/bono_model.dart';

class BonoLocalDatasource {
  static final BonoLocalDatasource _instance = BonoLocalDatasource._internal();
  factory BonoLocalDatasource() => _instance;
  BonoLocalDatasource._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'bonos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bonos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            moneda TEXT,
            tipoTasa TEXT,
            capitalizacion TEXT,
            valorNominal REAL,
            plazo INTEGER,
            tasaInteres REAL,
            tipoGracia TEXT,
            periodoGracia INTEGER,
            frecuenciaPago TEXT,
            fechaEmision TEXT,
            fechaVencimiento TEXT,
            primaRedencion REAL
          )
        ''');
      },
    );
  }

  Future<void> saveBono(BonoModel bono) async {
    final db = await database;
    await db.insert('bonos', bono.toMap());
  }

  Future<List<BonoModel>> getAllBonos() async {
    final db = await database;
    final result = await db.query('bonos');
    return result.map((e) => BonoModel.fromMap(e)).toList();
  }
}
