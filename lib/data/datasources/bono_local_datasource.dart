import 'package:sqflite/sqflite.dart';
import '../models/bono_model.dart';
import 'database_manager.dart';

class BonoLocalDatasource {
  static final BonoLocalDatasource _instance = BonoLocalDatasource._internal();
  factory BonoLocalDatasource() => _instance;
  BonoLocalDatasource._internal();

  Future<Database> get database async {
    return await DatabaseManager().database;
  }

  Future<void> saveBono(BonoModel bono) async {
    final db = await database;
    await db.insert('bonos', bono.toMap());
  }

  /// Obtiene todos los bonos creados por un emisor específico
  Future<List<BonoModel>> getBonosByEmisor(int userId) async {
    final db = await database;
    final result = await db.query(
      'bonos',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'fechaEmision DESC',
    );
    return result.map((map) => BonoModel.fromMap(map)).toList();
  }

  /// Obtiene todos los bonos disponibles (para inversores)
  Future<List<BonoModel>> getAllBonos() async {
    final db = await database;
    final result = await db.query('bonos', orderBy: 'fechaEmision DESC');
    return result.map((map) => BonoModel.fromMap(map)).toList();
  }

  /// Inserta un nuevo bono
  Future<int> insertBono(BonoModel bono) async {
    final db = await database;
    return await db.insert('bonos', bono.toMap());
  }

  /// Actualiza un bono existente
  Future<int> updateBono(BonoModel bono) async {
    final db = await database;
    return await db.update(
      'bonos',
      bono.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [bono.id, bono.userId],
    );
  }

  /// Elimina un bono (solo el emisor que lo creó)
  Future<int> deleteBono(int bonoId, int userId) async {
    final db = await database;
    return await db.delete(
      'bonos',
      where: 'id = ? AND userId = ?',
      whereArgs: [bonoId, userId],
    );
  }

  /// Obtiene un bono específico por ID
  Future<BonoModel?> getBonoById(int id) async {
    final db = await database;
    final result = await db.query('bonos', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return BonoModel.fromMap(result.first);
    }
    return null;
  }
}
