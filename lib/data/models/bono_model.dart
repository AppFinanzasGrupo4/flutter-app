import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity.dart';

class BonoModel extends BonoEntity {
  final int? id;
  final int? userId; // ID del emisor que creó el bono

  BonoModel({
    this.id,
    this.userId,
    required super.nombre,
    required super.moneda,
    required super.tipoTasa,
    super.capitalizacion,
    required super.valorNominal,
    required super.plazo,
    required super.tasaInteres,
    required super.frecuenciaTasa,
    required super.tipoGracia,
    required super.periodoGracia,
    required super.frecuenciaPago,
    required super.fechaEmision,
    required super.fechaVencimiento,
    required super.costoEstructuracion,
    required super.costoColocacion,
    required super.costoFlotacion,
    required super.costoCavali,
    required super.primaRedencion,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nombre': nombre,
      'moneda': moneda,
      'tipoTasa': tipoTasa,
      'capitalizacion': capitalizacion,
      'valorNominal': valorNominal,
      'plazo': plazo,
      'tasaInteres': tasaInteres,
      'frecuenciaTasa': frecuenciaTasa,
      'tipoGracia': tipoGracia.name,
      'periodoGracia': periodoGracia,
      'frecuenciaPago': frecuenciaPago,
      'fechaEmision': fechaEmision.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'costoEstructuracion': costoEstructuracion,
      'costoColocacion': costoColocacion,
      'costoFlotacion': costoFlotacion,
      'costoCavali': costoCavali,
      'primaRedencion': primaRedencion,
    };
  }

  factory BonoModel.fromMap(Map<String, dynamic> map) {
    return BonoModel(
      id: map['id'],
      userId: map['userId'],
      nombre: map['nombre'],
      moneda: map['moneda'],
      tipoTasa: map['tipoTasa'],
      capitalizacion: map['capitalizacion'],
      valorNominal: map['valorNominal'],
      plazo: map['plazo'],
      tasaInteres: map['tasaInteres'],
      frecuenciaTasa: map['frecuenciaTasa'],
      tipoGracia: TipoGracia.values.firstWhere(
        (e) => e.name == map['tipoGracia'],
      ),
      periodoGracia: map['periodoGracia'],
      frecuenciaPago: map['frecuenciaPago'],
      fechaEmision: DateTime.parse(map['fechaEmision']),
      fechaVencimiento: DateTime.parse(map['fechaVencimiento']),
      costoEstructuracion: map['costoEstructuracion'],
      costoColocacion: map['costoColocacion'],
      costoFlotacion: map['costoFlotacion'],
      costoCavali: map['costoCavali'],
      primaRedencion: map['primaRedencion'],
    );
  }
}
