import 'package:sqflite/sqflite.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';
import 'database_manager.dart';

class UserDataSource {
  static final UserDataSource db = UserDataSource._();
  UserDataSource._();

  Future<Database> get database async {
    return await DatabaseManager().database;
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
