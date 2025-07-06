import 'bono_entity.dart';
import 'dart:math';
import '../../data/models/bono_model.dart';
import '../calc/flujo_caja.dart';
import '../calc/precio_bono.dart';

extension BonoEntityCalculations on BonoEntity {
  /// [cok] es el costo de oportunidad de capital (decimal, ej: 0.084 para 8.4%)
  /// Se mantiene para compatibilidad
  Map<String, double> calcularDuracionConvexidad({required double cok}) {
    return calcularDuracionConvexidadConConfig(
      tipoTasaCOK: 'Efectiva',
      frecuenciaTasaCOK: 'Anual',
      valorCOK: cok * 100,
    );
  }

  /// [configCOK] es la configuración completa del COK del inversor
  /// [frecuenciaBono] es la frecuencia de pago del bono para hacer la conversión apropiada
  Map<String, double> calcularDuracionConvexidadConConfig({
    required String tipoTasaCOK,
    required String frecuenciaTasaCOK,
    String? capitalizacionCOK,
    required double valorCOK,
  }) {
    // Convertir BonoEntity a BonoModel para usar las funciones existentes
    final bonoModel = BonoModel(
      nombre: nombre,
      moneda: moneda,
      tipoTasa: tipoTasa,
      capitalizacion: capitalizacion,
      valorNominal: valorNominal,
      plazo: plazo,
      tasaInteres: tasaInteres,
      frecuenciaTasa: frecuenciaTasa,
      tipoGracia: tipoGracia,
      periodoGracia: periodoGracia,
      frecuenciaPago: frecuenciaPago,
      fechaEmision: fechaEmision,
      fechaVencimiento: fechaVencimiento,
      costoEstructuracion: costoEstructuracion,
      costoColocacion: costoColocacion,
      costoFlotacion: costoFlotacion,
      costoCavali: costoCavali,
      primaRedencion: primaRedencion,
    );

    // Generar flujo de caja usando la función existente
    final flujoCaja = calcularFlujosCaja(bonoModel);

    // Convertir el COK del inversor a tasa efectiva según la frecuencia del bono
    final frecuenciaBono = _frecuenciaPagosPorAnio(frecuenciaPago);
    final frecuenciaCOK = _frecuenciaPagosPorAnio(frecuenciaTasaCOK);

    double kokEfectivoParaBono;

    if (tipoTasaCOK == 'Efectiva') {
      // Si el COK es efectiva, convertir a la frecuencia del bono
      if (frecuenciaTasaCOK.toLowerCase() == frecuenciaPago.toLowerCase()) {
        // Misma frecuencia, usar directamente
        kokEfectivoParaBono = valorCOK / 100;
      } else {
        // Diferente frecuencia, convertir
        final tasaEfectivaAnual =
            pow(1 + (valorCOK / 100) / frecuenciaCOK, frecuenciaCOK) - 1;
        kokEfectivoParaBono =
            pow(1 + tasaEfectivaAnual, 1 / frecuenciaBono) - 1;
      }
    } else if (tipoTasaCOK == 'Nominal') {
      // Si el COK es nominal, convertir a efectiva según capitalización y luego a frecuencia del bono
      final frecuenciaCapitalizacion = _frecuenciaPagosPorAnio(
        capitalizacionCOK ?? frecuenciaTasaCOK,
      );
      final tasaEfectivaAnual =
          pow(
            1 + (valorCOK / 100) / frecuenciaCapitalizacion,
            frecuenciaCapitalizacion,
          ) -
          1;
      kokEfectivoParaBono = pow(1 + tasaEfectivaAnual, 1 / frecuenciaBono) - 1;
    } else {
      // Si el COK es tasa descontada, convertir a efectiva y luego a frecuencia del bono
      final tasaDescontada = valorCOK / 100;
      final dias = int.tryParse(frecuenciaTasaCOK.substring(1)) ?? 360;

      // Convertir tasa descontada a tasa efectiva para el período específico
      // Fórmula: i = d / (1 - d)
      final tasaEfectivaPeriodo = tasaDescontada / (1 - tasaDescontada);

      // Convertir a tasa efectiva anual
      final periodosPorAnio = 360.0 / dias;
      final tasaEfectivaAnual =
          pow(1 + tasaEfectivaPeriodo, periodosPorAnio) - 1;

      // Convertir a la frecuencia del bono
      kokEfectivoParaBono = pow(1 + tasaEfectivaAnual, 1 / frecuenciaBono) - 1;
    }

    // Calcular precio del bono usando el COK convertido
    final precio = calcularPrecioBono(
      flujoCaja: flujoCaja,
      cokInversor: kokEfectivoParaBono,
    );

    // Usar la tasa efectiva del COK para los cálculos
    final tasaPeriodica = kokEfectivoParaBono;

    double sumaPonderadaDuracion = 0;
    double sumaPonderadaConvexidad = 0;

    // Calcular duración y convexidad usando el flujo de caja real
    for (int i = 1; i < flujoCaja.length; i++) {
      // Empezar desde 1 para omitir período 0
      final flujo = flujoCaja[i];
      final periodo = flujo['Periodo'] as int;
      final pagoTotal = flujo['Pago Total'] as double;

      if (pagoTotal > 0) {
        final valorPresente = pagoTotal / pow(1 + tasaPeriodica, periodo);

        // Duración: suma de (t * VP) / Precio
        sumaPonderadaDuracion += periodo * valorPresente;

        // Convexidad: suma de [t * (t + 1) * VP] / [(1 + y)^2 * Precio]
        sumaPonderadaConvexidad += periodo * (periodo + 1) * valorPresente;
      }
    }

    // Duración expresada en períodos de pago (semestres para frecuencia semestral)
    final duracion = sumaPonderadaDuracion / precio;

    // Duración modificada: D / (1 + y)
    final duracionModificada = duracion / (1 + tasaPeriodica);

    // Convexidad: [suma de t*(t+1)*VP] / [(1+y)^2 * P]
    final convexidad =
        sumaPonderadaConvexidad / (pow(1 + tasaPeriodica, 2) * precio);

    return {
      'precio': precio,
      'duracion': duracion,
      'duracionModificada': duracionModificada,
      'convexidad': convexidad,
    };
  }

  /// Calcula la Tasa de Rentabilidad Efectiva Anual (TREA)
  /// [precio] es el precio pagado por el bono
  double calcularTREA({required double precio}) {
    // Convertir BonoEntity a BonoModel para usar las funciones existentes
    final bonoModel = BonoModel(
      nombre: nombre,
      moneda: moneda,
      tipoTasa: tipoTasa,
      capitalizacion: capitalizacion,
      valorNominal: valorNominal,
      plazo: plazo,
      tasaInteres: tasaInteres,
      frecuenciaTasa: frecuenciaTasa,
      tipoGracia: tipoGracia,
      periodoGracia: periodoGracia,
      frecuenciaPago: frecuenciaPago,
      fechaEmision: fechaEmision,
      fechaVencimiento: fechaVencimiento,
      costoEstructuracion: costoEstructuracion,
      costoColocacion: costoColocacion,
      costoFlotacion: costoFlotacion,
      costoCavali: costoCavali,
      primaRedencion: primaRedencion,
    );

    // Generar flujo de caja
    final flujoCaja = calcularFlujosCaja(bonoModel);

    // Calcular TIR periódica usando la función existente
    final tirPeriodica = _calcularTIRPeriodica(flujoCaja, precio);

    // Convertir TIR periódica a TREA (anual efectiva)
    final frecuencia = _frecuenciaPagosPorAnio(frecuenciaPago);
    final trea = pow(1 + tirPeriodica, frecuencia) - 1;

    return trea.toDouble();
  }

  /// Calcula la TIR periódica usando el método de Newton-Raphson
  double _calcularTIRPeriodica(
    List<Map<String, dynamic>> flujoCaja,
    double inversionInicial,
  ) {
    double tir = 0.04; // Valor inicial 4%
    const int maxIteraciones = 100;
    const double precision = 1e-6;

    for (int i = 0; i < maxIteraciones; i++) {
      double van = -inversionInicial;
      double derivada = 0.0;

      // Calcular VAN y su derivada
      for (int j = 1; j < flujoCaja.length; j++) {
        final periodo = flujoCaja[j]['Periodo'] as int;
        final flujo = flujoCaja[j]['Pago Total'] as double;

        if (flujo > 0) {
          final factor = pow(1 + tir, periodo);
          van += flujo / factor;
          derivada -= periodo * flujo / (factor * (1 + tir));
        }
      }

      if (van.abs() < precision) {
        return tir;
      }

      if (derivada == 0) {
        break;
      }

      tir = tir - van / derivada;

      // Verificar convergencia
      if (tir < -0.99) tir = -0.99; // Evitar divisiones por cero
      if (tir > 10) tir = 10; // Limitar valores extremos
    }

    return tir;
  }

  int _frecuenciaPagosPorAnio(String frecuencia) {
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
}
