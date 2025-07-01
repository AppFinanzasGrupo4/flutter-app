import 'package:flutter_finanzasapp/data/repositories/bono_repository.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity.dart';

import '../datasources/bono_local_datasource.dart';
import '../models/bono_model.dart';

class BonoRepositoryImpl implements BonoRepository {
  final BonoLocalDatasource datasource;

  BonoRepositoryImpl(this.datasource);

  @override
  Future<void> saveBono(BonoEntity bono) {
    final model = BonoModel(
      nombre: bono.nombre,
      moneda: bono.moneda,
      tipoTasa: bono.tipoTasa,
      capitalizacion: bono.capitalizacion,
      valorNominal: bono.valorNominal,
      plazo: bono.plazo,
      tasaInteres: bono.tasaInteres,
      frecuenciaTasa: bono.frecuenciaTasa,
      tipoGracia: bono.tipoGracia,
      periodoGracia: bono.periodoGracia,
      frecuenciaPago: bono.frecuenciaPago,
      fechaEmision: bono.fechaEmision,
      fechaVencimiento: bono.fechaVencimiento,
      costoEstructuracion: bono.costoEstructuracion,
      costoColocacion: bono.costoColocacion,
      costoFlotacion: bono.costoFlotacion,
      costoCavali: bono.costoCavali,
      primaRedencion: bono.primaRedencion,
    );
    return datasource.saveBono(model);
  }
}
