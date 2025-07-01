class ConfigEntity {
  final String moneda;
  final String tipoTasa; // 'Efectiva' o 'Nominal'
  final String? frecuenciaTasa;
  final String? capitalizacion; // solo si tipoTasa es Nominal

  ConfigEntity({
    required this.moneda,
    required this.tipoTasa,
    this.frecuenciaTasa,
    this.capitalizacion,
  });
}
