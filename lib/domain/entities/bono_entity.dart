import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';

class BonoEntity {
  final String nombre;
  final String moneda;
  final String tipoTasa;
  final String? capitalizacion;
  final double valorNominal;
  final int plazo;
  final double tasaInteres;
  final TipoGracia tipoGracia;
  final int periodoGracia;

  BonoEntity({
    required this.nombre,
    required this.moneda,
    required this.tipoTasa,
    this.capitalizacion,
    required this.valorNominal,
    required this.plazo,
    required this.tasaInteres,
    required this.tipoGracia,
    required this.periodoGracia,
  });
}
