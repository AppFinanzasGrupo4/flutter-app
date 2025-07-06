import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity_ext.dart';
import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';

void main() {
  test(
    'Test cálculos de duración, duración modificada y convexidad - Bono B',
    () {
      // Crear el Bono B con las características especificadas
      final bonoB = BonoEntity(
        nombre: 'Bono B',
        moneda: 'PEN',
        tipoTasa: 'Nominal',
        capitalizacion: 'Semestral',
        valorNominal: 1000.0,
        plazo: 3, // 3 años
        tasaInteres: 6.0, // 6% nominal semestral
        frecuenciaTasa: 'Semestral',
        tipoGracia: TipoGracia.ninguna,
        periodoGracia: 0,
        frecuenciaPago: 'Semestral',
        fechaEmision: DateTime.now(),
        fechaVencimiento: DateTime.now().add(
          const Duration(days: 1095),
        ), // 3 años
        costoEstructuracion: 0.0,
        costoColocacion: 0.0,
        costoFlotacion: 0.0,
        costoCavali: 0.0,
        primaRedencion: 0.0,
      );

      // COK del inversor: 8.4% nominal anual con capitalización semestral
      // Esto se convertirá automáticamente a la frecuencia del bono (semestral)

      // Calcular métricas usando la configuración completa del COK
      final resultados = bonoB.calcularDuracionConvexidadConConfig(
        tipoTasaCOK: 'Nominal',
        frecuenciaTasaCOK: 'Anual',
        capitalizacionCOK: 'Semestral',
        valorCOK: 8.4,
      );

      // Verificar valores esperados
      print('Precio calculado: ${resultados['precio']?.toStringAsFixed(2)}');
      print(
        'Duración: ${resultados['duracion']?.toStringAsFixed(2)} semestres',
      );
      print(
        'Duración Modificada: ${resultados['duracionModificada']?.toStringAsFixed(2)} semestres',
      );
      print('Convexidad: ${resultados['convexidad']?.toStringAsFixed(2)}');

      // Los valores esperados según el usuario son:
      // Precio: 932.92
      // Duración: 5.69 semestres
      // Duración Modificada: 5.46 semestres
      // Convexidad: 35.84

      expect(resultados['precio'], closeTo(932.92, 0.5)); // Tolerancia de 0.5
      expect(resultados['duracion'], closeTo(5.69, 0.1)); // Tolerancia de 0.1
      expect(resultados['duracionModificada'], closeTo(5.46, 0.1));
      expect(
        resultados['convexidad'],
        closeTo(35.84, 1.0),
      ); // Tolerancia de 1.0
    },
  );
}
