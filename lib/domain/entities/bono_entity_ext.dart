import 'bono_entity.dart';
import 'dart:math';

extension BonoEntityCalculations on BonoEntity {
  /// Calcula la duración, duración modificada y convexidad del bono.
  /// [cok] es el costo de oportunidad de capital (en porcentaje, ej: 0.10 para 10%)
  Map<String, double> calcularDuracionConvexidad({required double cok}) {
    final tasa = tasaInteres / 100;
    final valorNom = valorNominal;
    final frecuencia = _frecuenciaPagosPorAnio(frecuenciaPago);
    final double y = cok / frecuencia;  //
    final double c = valorNom * tasa / frecuencia;
    final double fv = valorNom * (1 + primaRedencion / 100);
    final n = plazo * frecuencia;


    double precio = 0;
    double duracion = 0;
    double convexidad = 0;
    double sumaFlujos = 0;
    double sumaConvexidad = 0;

    for (int t = 1; t <= n; t++) {
      double tiempoEnAnios = t / frecuencia;
      double flujo = (t == n) ? c + fv : c;
      double descuento = pow(1 + y, t).toDouble();
      double valorPresente = flujo / descuento;

      precio += valorPresente;
      sumaFlujos += tiempoEnAnios * valorPresente;
      sumaConvexidad += tiempoEnAnios * (tiempoEnAnios + 1/frecuencia) * valorPresente;
    }


    duracion = sumaFlujos / precio;
    double duracionModificada = duracion / (1 + y);
    convexidad = sumaConvexidad / (pow(1 + y, 2) * precio);

    return {
      'precio': precio,
      'duracion': duracion,
      'duracionModificada': duracionModificada,
      'convexidad': convexidad,
    };
  }

  /// Calcula la Tasa de Rentabilidad Efectiva Anual (TREA)
  /// [cok] es el costo de oportunidad de capital (en porcentaje, ej: 0.10 para 10%)
  double calcularTREA({required double cok}) {
    final frecuencia = _frecuenciaPagosPorAnio(frecuenciaPago);
    return pow(1 + cok / frecuencia, frecuencia) - 1;
  }

  int _frecuenciaPagosPorAnio(String frecuencia) {
    switch (frecuencia.toLowerCase()) {
      case 'mensual':
        return 12;
      case 'bimestral':
        return 6;
      case 'trimestral':
        return 4;
      case 'cuatrimestral':
        return 3;
      case 'semestral':
        return 2;
      case 'anual':
        return 1;
      default:
        return 1;
    }
  }
}
