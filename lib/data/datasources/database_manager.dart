import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Datasource unificado que maneja todas las tablas en una sola base de datos
class DatabaseManager {
  static Database? _database;
  static const String _dbName = 'finanzas_app.db';
  static const int _dbVersion = 3;

  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        correo TEXT,
        clave TEXT,
        rol TEXT
      )
    ''');

    // Tabla de bonos
    await db.execute('''
      CREATE TABLE bonos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        nombre TEXT,
        moneda TEXT,
        tipoTasa TEXT,
        capitalizacion TEXT,
        valorNominal REAL,
        plazo INTEGER,
        tasaInteres REAL,
        frecuenciaTasa TEXT,
        tipoGracia TEXT,
        periodoGracia INTEGER,
        frecuenciaPago TEXT,
        fechaEmision TEXT,
        fechaVencimiento TEXT,
        costoEstructuracion REAL,
        costoColocacion REAL,
        costoFlotacion REAL,
        costoCavali REAL,
        primaRedencion REAL,
        FOREIGN KEY (userId) REFERENCES usuarios (id)
      )
    ''');

    // Tabla de configuración del inversor
    await db.execute('''
      CREATE TABLE inversor_config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        tipoTasa TEXT NOT NULL,
        frecuenciaTasa TEXT NOT NULL,
        capitalizacion TEXT,
        valorCOK REAL NOT NULL,
        fechaActualizacion TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES usuarios (id)
      )
    ''');

    // Tabla de compras de bonos
    await db.execute('''
      CREATE TABLE compras_bonos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        nombreBono TEXT NOT NULL,
        precio REAL NOT NULL,
        cokUtilizado REAL NOT NULL,
        valorNominal REAL NOT NULL,
        fechaCompra TEXT NOT NULL,
        detallesBono TEXT NOT NULL,
        flujoCaja TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES usuarios (id)
      )
    ''');

    // Tabla de configuración del emisor
    await db.execute('''
      CREATE TABLE config (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moneda TEXT,
        tipoTasa TEXT,
        capitalizacion TEXT,
        fechaActualizacion TEXT
      )
    ''');
  }

  Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migración de versiones anteriores
    if (oldVersion < 3) {
      // Recrear todas las tablas con la nueva estructura
      await db.execute('DROP TABLE IF EXISTS usuarios');
      await db.execute('DROP TABLE IF EXISTS bonos');
      await db.execute('DROP TABLE IF EXISTS inversor_config');
      await db.execute('DROP TABLE IF EXISTS compras_bonos');
      await db.execute('DROP TABLE IF EXISTS config');

      await _createTables(db, newVersion);
    }
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
