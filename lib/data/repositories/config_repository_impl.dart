import 'package:flutter_finanzasapp/data/repositories/config_repository.dart';
import '../../domain/entities/config_entity.dart';
import '../datasources/config_local_datasource.dart';
import '../models/config_model.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigLocalDatasource datasource;

  ConfigRepositoryImpl(this.datasource);

  @override
  Future<void> saveConfig(ConfigEntity config) {
    final model = ConfigModel(
      moneda: config.moneda,
      tipoTasa: config.tipoTasa,
      capitalizacion: config.capitalizacion,
    );
    return datasource.saveConfig(model);
  }

  @override
  Future<ConfigEntity?> getConfig() async {
    final model = await datasource.getConfig();
    return model;
  }
}
