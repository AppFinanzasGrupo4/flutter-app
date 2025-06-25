import '../../domain/entities/config_entity.dart';

class ConfigModel extends ConfigEntity {
  ConfigModel({
    required super.moneda,
    required super.tipoTasa,
    super.capitalizacion,
  });

  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      moneda: map['moneda'],
      tipoTasa: map['tipoTasa'],
      capitalizacion: map['capitalizacion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moneda': moneda,
      'tipoTasa': tipoTasa,
      'capitalizacion': capitalizacion,
    };
  }
}
