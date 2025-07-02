import 'dart:math';
import 'package:logger/logger.dart';

final logger = Logger();

double calcularTIRPeriodica(
  List<Map<String, dynamic>> flujos,
  double inversionInicial,
) {
  const double tolerancia = 1e-8; // Tolerancia más estricta
  const int maxIteraciones = 1000; // Más iteraciones

  // Imprimir flujos para depuración
  logger.i('Flujos de caja:');
  for (var flujo in flujos) {
    logger.i('Período ${flujo['Periodo']}: ${flujo['Pago Total']}');
  }

  // Usar el método de bisección para encontrar la TIR
  double tirMin = -0.99; // TIR mínima
  double tirMax = 5.0; // TIR máxima (500%)
  double tir = 0.05; // Suposición inicial

  for (int i = 0; i < maxIteraciones; i++) {
    double vpn = calcularVPN(flujos, tir);

    logger.d(
      'Iteración $i: TIR = ${(tir * 100).toStringAsFixed(4)}%, VPN = ${vpn.toStringAsFixed(6)}',
    );

    if (vpn.abs() < tolerancia) {
      logger.i('TIR periódica encontrada: ${(tir * 100).toStringAsFixed(4)}%');
      return tir;
    }

    // Método de bisección
    if (vpn > 0) {
      tirMin = tir;
    } else {
      tirMax = tir;
    }

    tir = (tirMin + tirMax) / 2;

    // Si el rango es muy pequeño, detener
    if ((tirMax - tirMin).abs() < tolerancia) {
      break;
    }
  }

  logger.i('TIR periódica final: ${(tir * 100).toStringAsFixed(4)}%');
  return tir;
}

double calcularVPN(List<Map<String, dynamic>> flujos, double tasa) {
  double vpn = 0.0;

  for (var flujo in flujos) {
    int periodo = flujo['Periodo'];
    double flujoTotal = flujo['Pago Total'];

    if (periodo == 0) {
      vpn += flujoTotal;
    } else {
      vpn += flujoTotal / pow(1 + tasa, periodo);
    }
  }

  return vpn;
}

double calcularTCEA(double tirPeriodica, int frecuenciaPagos) {
  logger.i('Calculando TCEA...');
  logger.i('TIR periódica: ${(tirPeriodica * 100).toStringAsFixed(4)}%');
  logger.i('Frecuencia de pagos por año: $frecuenciaPagos');

  // La TCEA se calcula usando la fórmula: (1 + TIR_periódica)^n - 1
  // donde n es el número de períodos por año
  double tceaDecimal = pow(1 + tirPeriodica, frecuenciaPagos) - 1;
  double tceaPorcentaje = tceaDecimal * 100;

  logger.i('TCEA calculada: ${tceaPorcentaje.toStringAsFixed(4)}%');

  return tceaPorcentaje;
}
