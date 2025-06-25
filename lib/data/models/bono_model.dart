import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity.dart';

class BonoModel extends BonoEntity {
  final int? id;

  BonoModel({
    this.id,
    required super.nombre,
    required super.moneda,
    required super.tipoTasa,
    super.capitalizacion,
    required super.valorNominal,
    required super.plazo,
    required super.tasaInteres,
    required super.tipoGracia,
    required super.periodoGracia,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'moneda': moneda,
      'tipoTasa': tipoTasa,
      'capitalizacion': capitalizacion,
      'valorNominal': valorNominal,
      'plazo': plazo,
      'tasaInteres': tasaInteres,
      'tipoGracia': tipoGracia.name,
      'periodoGracia': periodoGracia,
    };
  }

  factory BonoModel.fromMap(Map<String, dynamic> map) {
    return BonoModel(
      id: map['id'],
      nombre: map['nombre'],
      moneda: map['moneda'],
      tipoTasa: map['tipoTasa'],
      capitalizacion: map['capitalizacion'],
      valorNominal: map['valorNominal'],
      plazo: map['plazo'],
      tasaInteres: map['tasaInteres'],
      tipoGracia: TipoGracia.values.firstWhere(
        (e) => e.name == map['tipoGracia'],
      ),
      periodoGracia: map['periodoGracia'],
    );
  }
}
