import 'dart:math';

double calcularTIRPeriodica(
  List<Map<String, dynamic>> flujos,
  double inversionInicial,
) {
  const double tolerancia = 1e-8; // Tolerancia más estricta
  const int maxIteraciones = 1000; // Más iteraciones

  // Usar el método de bisección para encontrar la TIR
  double tirMin = -0.99; // TIR mínima
  double tirMax = 5.0; // TIR máxima (500%)
  double tir = 0.05; // Suposición inicial

  for (int i = 0; i < maxIteraciones; i++) {
    double vpn = calcularVPN(flujos, tir);



    if (vpn.abs() < tolerancia) {
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

  // La TCEA se calcula usando la fórmula: (1 + TIR_periódica)^n - 1
  // donde n es el número de períodos por año
  double tceaDecimal = pow(1 + tirPeriodica, frecuenciaPagos) - 1;
  double tceaPorcentaje = tceaDecimal * 100;


  return tceaPorcentaje;
}
