import 'dart:math';
import '../calc/flujo_caja.dart';
import '../../data/models/bono_model.dart';

/// Calcula el precio del bono usando el flujo de caja y el COK del inversor
double calcularPrecioBono({
  required List<Map<String, dynamic>> flujoCaja,
  required double cokInversor, // COK en decimal (ej: 0.10 para 10%)
}) {
  double precio = 0.0;

  // Sumar el valor presente de todos los flujos positivos (excluyendo la inversión inicial)
  for (var flujo in flujoCaja) {
    int periodo = flujo['Periodo'];
    double flujoTotal = flujo['Pago Total'];

    // Solo considerar flujos positivos (pagos que recibe el inversor)
    if (periodo > 0 && flujoTotal > 0) {
      precio += flujoTotal / pow(1 + cokInversor, periodo);
    }
  }

  return precio;
}

/// Calcula el precio del bono directamente desde el BonoModel
double calcularPrecioDesdeModel({
  required BonoModel bono,
  required double cokInversor,
}) {
  // Generar el flujo de caja
  final flujoCaja = calcularFlujosCaja(bono);

  // Calcular el precio usando el flujo de caja
  return calcularPrecioBono(flujoCaja: flujoCaja, cokInversor: cokInversor);
}

/// Calcula métricas adicionales del bono para mostrar al inversor
Map<String, double> calcularMetricasBono({
  required List<Map<String, dynamic>> flujoCaja,
  required double cokInversor,
  required double precio,
}) {
  double valorNominal = 0.0;
  double totalIntereses = 0.0;
  double totalPrincipal = 0.0;

  // Calcular totales del flujo de caja
  for (var flujo in flujoCaja) {
    int periodo = flujo['Periodo'];
    if (periodo > 0) {
      totalIntereses += flujo['Intereses'] ?? 0.0;
      totalPrincipal += flujo['Pago Principal'] ?? 0.0;
    }
  }

  valorNominal = totalPrincipal; // El principal total es el valor nominal

  // Calcular rendimiento
  double rendimientoTotal = (totalIntereses + totalPrincipal) - precio;
  double rendimientoPorcentual =
      precio > 0 ? (rendimientoTotal / precio) * 100 : 0.0;

  // Calcular yield to maturity aproximado (TIR)
  double ytm = 0.0;
  if (precio > 0) {
    // Aproximación simple del YTM
    double flujoAnual =
        totalIntereses / flujoCaja.length * 12; // Estimación anual
    double gananciaCapital = valorNominal - precio;
    int anios = (flujoCaja.length / 12).ceil();

    if (anios > 0) {
      ytm =
          ((flujoAnual + (gananciaCapital / anios)) /
              ((precio + valorNominal) / 2)) *
          100;
    }
  }

  return {
    'valorNominal': valorNominal,
    'totalIntereses': totalIntereses,
    'totalPrincipal': totalPrincipal,
    'rendimientoTotal': rendimientoTotal,
    'rendimientoPorcentual': rendimientoPorcentual,
    'ytm': ytm,
    'descuento':
        valorNominal - precio, // Descuento si el precio < valor nominal
    'descuentoPorcentual':
        valorNominal > 0 ? ((valorNominal - precio) / valorNominal) * 100 : 0.0,
  };
}
