import 'dart:async';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../models/inversor_config_model.dart';
import 'database_manager.dart';

class InversorConfigDatasource {
  static const String _tableName = 'inversor_config';

  Future<Database> get database async {
    return await DatabaseManager().database;
  }

  // Guardar o actualizar configuración del inversor
  Future<void> saveConfig(InversorConfigModel config) async {
    final db = await database;

    // Primero eliminamos configuración existente de este usuario
    await db.delete(
      _tableName,
      where: 'userId = ?',
      whereArgs: [config.userId],
    );

    // Luego insertamos la nueva configuración
    await db.insert(
      _tableName,
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener la configuración del inversor específico
  Future<InversorConfigModel?> getConfig(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'fechaActualizacion DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return InversorConfigModel.fromMap(maps.first);
    }
    return null;
  }

  // Verificar si existe configuración para un usuario
  Future<bool> hasConfig(int userId) async {
    final config = await getConfig(userId);
    return config != null;
  }

  // Eliminar configuración de un usuario
  Future<void> deleteConfig(int userId) async {
    final db = await database;
    await db.delete(_tableName, where: 'userId = ?', whereArgs: [userId]);
  }

  // Obtener COK efectivo para cálculos
  Future<double> getCOKEfectivo(int userId) async {
    final config = await getConfig(userId);
    if (config == null) {
      return 0.10; // COK por defecto de 10%
    }

    double cok = config.valorCOK / 100; // Convertir de porcentaje a decimal

    // Si es tasa nominal, convertir a efectiva
    if (config.tipoTasa == 'Nominal' && config.capitalizacion != null) {
      int frecuenciaCapitalizacion = _frecuenciaToInt(config.capitalizacion!);
      // Convertir tasa nominal a efectiva: (1 + i/n)^n - 1
      cok = (1 + cok / frecuenciaCapitalizacion).toDouble();
      cok = cok - 1;
    } else if (config.tipoTasa == 'Descontada') {
      // Convertir tasa descontada a tasa efectiva equivalente
      cok = _convertirTasaDescontadaAEfectiva(cok, config.frecuenciaTasa);
    }

    return cok;
  }

  int _frecuenciaToInt(String frecuencia) {
    switch (frecuencia) {
      case 'Mensual':
      case 'mensual':
        return 12;
      case 'Bimestral':
      case 'bimestral':
        return 6;
      case 'Trimestral':
      case 'trimestral':
        return 4;
      case 'Cuatrimestral':
      case 'cuatrimestral':
        return 3;
      case 'Semestral':
      case 'semestral':
        return 2;
      case 'Anual':
      case 'anual':
        return 1;
      default:
        return 1;
    }
  }

  // Convertir tasa descontada a tasa efectiva equivalente
  double _convertirTasaDescontadaAEfectiva(
    double tasaDescontada,
    String periodo,
  ) {
    // Extraer el número de días del período (ej: 'd30' -> 30)
    final dias = int.tryParse(periodo.substring(1)) ?? 360;

    // Convertir tasa descontada a tasa efectiva para el período específico
    // Fórmula: i = d / (1 - d)
    // donde d es la tasa de descuento para el período específico

    // Primero, convertir la tasa de descuento del período a tasa efectiva del mismo período
    final tasaEfectivaPeriodo = tasaDescontada / (1 - tasaDescontada);

    // Luego, convertir a tasa efectiva anual
    final periodosPorAnio = 360.0 / dias;
    final tasaEfectivaAnual = pow(1 + tasaEfectivaPeriodo, periodosPorAnio) - 1;

    return tasaEfectivaAnual.toDouble();
  }
}
