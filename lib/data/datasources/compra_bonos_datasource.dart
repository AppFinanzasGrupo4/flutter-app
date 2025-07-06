import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/compra_bono_model.dart';
import 'database_manager.dart';

class CompraBonosDatasource {
  static const String _tableName = 'compras_bonos';

  Future<Database> get database async {
    return await DatabaseManager().database;
  }

  // Registrar una compra de bono
  Future<int> registrarCompra(CompraBonoModel compra) async {
    final db = await database;

    final Map<String, dynamic> data = compra.toMap();
    // Convertir objetos complejos a JSON
    data['detallesBono'] = jsonEncode(compra.detallesBono);
    data['flujoCaja'] = jsonEncode(compra.flujoCaja);

    return await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todas las compras de un usuario específico
  Future<List<CompraBonoModel>> getComprasByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'fechaCompra DESC',
    );

    return maps.map((map) {
      // Decodificar JSON de objetos complejos
      final decodedMap = Map<String, dynamic>.from(map);
      decodedMap['detallesBono'] = jsonDecode(map['detallesBono']);
      decodedMap['flujoCaja'] = jsonDecode(map['flujoCaja']);
      return CompraBonoModel.fromMap(decodedMap);
    }).toList();
  }

  // Obtener compra por ID
  Future<CompraBonoModel?> getCompraById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final decodedMap = Map<String, dynamic>.from(maps.first);
      decodedMap['detallesBono'] = jsonDecode(maps.first['detallesBono']);
      decodedMap['flujoCaja'] = jsonDecode(maps.first['flujoCaja']);
      return CompraBonoModel.fromMap(decodedMap);
    }
    return null;
  }

  // Obtener compras por nombre de bono de un usuario específico
  Future<List<CompraBonoModel>> getComprasByBonoAndUser(
    String nombreBono,
    int userId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'nombreBono = ? AND userId = ?',
      whereArgs: [nombreBono, userId],
      orderBy: 'fechaCompra DESC',
    );

    return maps.map((map) {
      final decodedMap = Map<String, dynamic>.from(map);
      decodedMap['detallesBono'] = jsonDecode(map['detallesBono']);
      decodedMap['flujoCaja'] = jsonDecode(map['flujoCaja']);
      return CompraBonoModel.fromMap(decodedMap);
    }).toList();
  }

  // Eliminar compra (solo del usuario propietario)
  Future<void> deleteCompra(int id, int userId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // Obtener estadísticas de compras de un usuario específico
  Future<Map<String, dynamic>> getEstadisticasCompras(int userId) async {
    final db = await database;

    final totalComprasResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $_tableName WHERE userId = ?',
      [userId],
    );
    final totalInvertidoResult = await db.rawQuery(
      'SELECT SUM(precio) as total FROM $_tableName WHERE userId = ?',
      [userId],
    );
    final promedioInversionResult = await db.rawQuery(
      'SELECT AVG(precio) as promedio FROM $_tableName WHERE userId = ?',
      [userId],
    );

    return {
      'totalCompras': totalComprasResult.first['total'] ?? 0,
      'totalInvertido': totalInvertidoResult.first['total'] ?? 0.0,
      'promedioInversion': promedioInversionResult.first['promedio'] ?? 0.0,
    };
  }

  // Verificar si el inversor ya compró un bono específico
  Future<bool> yaComproBono(String nombreBono, int userId) async {
    final compras = await getComprasByBonoAndUser(nombreBono, userId);
    return compras.isNotEmpty;
  }
}
