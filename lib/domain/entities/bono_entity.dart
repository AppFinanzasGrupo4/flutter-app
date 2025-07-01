import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';

class BonoEntity {
  final String nombre;
  final String moneda;
  final String tipoTasa;
  final String? capitalizacion;
  final double valorNominal;
  final int plazo;
  final double tasaInteres;
  final String? frecuenciaTasa;
  final TipoGracia tipoGracia;
  final int periodoGracia;
  final String frecuenciaPago; // mensual, trimestral, etc.
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;
  final double costoEstructuracion; // porcentaje
  final double costoColocacion; // porcentaje
  final double costoFlotacion; // porcentaje
  final double costoCavali; // porcentaje
  final double primaRedencion; // porcentaje

  BonoEntity({
    required this.nombre,
    required this.moneda,
    required this.tipoTasa,
    this.capitalizacion,
    required this.valorNominal,
    required this.plazo,
    required this.tasaInteres,
    this.frecuenciaTasa,
    required this.tipoGracia,
    required this.periodoGracia,
    required this.frecuenciaPago,
    required this.fechaEmision,
    required this.fechaVencimiento,
    required this.costoEstructuracion,
    required this.costoColocacion,
    required this.costoFlotacion,
    required this.costoCavali,
    required this.primaRedencion,
  });
}
