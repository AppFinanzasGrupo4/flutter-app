import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';

class UserDataSource {
  static Database? _database;
  static final UserDataSource db = UserDataSource._();

  UserDataSource._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'usuarios.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        correo TEXT,
        clave TEXT,
        rol TEXT
      )
    ''');
  }

  Future<int> insertarUsuario(UserModel usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario.toMap());
  }

  Future<UserModel?> validarUsuario(String correo, String clave) async {
    final db = await database;
    final res = await db.query(
      'usuarios',
      where: 'correo = ? AND clave = ?',
      whereArgs: [correo, clave],
    );

    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }
}
