import 'dart:math';

import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';

// Enum para los tipos de gracia

List<Map<String, dynamic>> calcularFlujosCaja(BonoModel bono) {
  List<Map<String, dynamic>> flujos = [];
  double valorNominal = bono.valorNominal;
  int plazo = bono.plazo;
  int frecuenciaPago = _frecuenciaToInt(
    bono.frecuenciaPago,
  ); // Convertir frecuencia a número
  double tasaInteres = bono.tasaInteres / 100;
  String frecuenciaCapitalizacion = bono.capitalizacion ?? 'Anual';
  // Convertir frecuencia de capitalización y de pago a número de periodos por año
  int nCapitalizacion = _frecuenciaToInt(frecuenciaCapitalizacion);
  int nPago = frecuenciaPago;

  // Calcular tasa efectiva para la frecuencia de pago
  double tasaEfectivaPago =
      (pow(1 + tasaInteres / nCapitalizacion, nCapitalizacion / nPago) - 1);

  // Usar la tasa efectiva de pago como tasa de cupón
  double tasaCupon = tasaEfectivaPago;
  double pagoInteres = double.parse(
    (valorNominal * tasaCupon).toStringAsFixed(2),
  );

  // Periodo 0: costos iniciales
  double costosIniciales =
      valorNominal *
      (bono.costoEstructuracion +
          bono.costoColocacion +
          bono.costoFlotacion +
          bono.costoCavali) /
      100;
  flujos.add({
    'Periodo': 0,
    'Intereses': 0.0,
    'Pago Principal': 0.0,
    'Pago Total': -(valorNominal - costosIniciales), // Salida inicial
  });

  // Periodos 1 a n-1: solo intereses
  for (int i = 1; i <= plazo * frecuenciaPago; i++) {
    double pagoPrincipal = 0.0;
    double pagoInteresPeriodo = pagoInteres;
    double pagoTotal = pagoInteres;

    // Si el periodo está dentro del periodo de gracia, los intereses son cero
    if ((bono.tipoGracia == TipoGracia.total ||
            bono.tipoGracia == TipoGracia.parcial) &&
        i <= bono.periodoGracia) {
      pagoInteresPeriodo = 0.0;
      pagoTotal = 0.0;
    }

    // Último periodo: incluye el capital y la prima de redención
    if (i == plazo * frecuenciaPago) {
      pagoPrincipal = double.parse(
        (valorNominal + bono.primaRedencion / 100 * valorNominal)
            .toStringAsFixed(2),
      );
      pagoTotal += pagoPrincipal;
    }

    flujos.add({
      'Periodo': i,
      'Intereses': pagoInteresPeriodo,
      'Pago Principal': pagoPrincipal,
      'Pago Total': pagoTotal,
    });
  }

  return flujos;
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
      return 1; // Por defecto, anual
  }
}
