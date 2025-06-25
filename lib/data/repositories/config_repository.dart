import 'package:flutter_finanzasapp/domain/entities/config_entity.dart';

abstract class ConfigRepository {
  Future<void> saveConfig(ConfigEntity config);
  Future<ConfigEntity?> getConfig();
}
