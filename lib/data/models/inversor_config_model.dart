class InversorConfigModel {
  final int? userId; // ID del inversor
  final String tipoTasa; // 'Nominal', 'Efectiva' o 'Descontada'
  final String
  frecuenciaTasa; // 'Mensual', 'Trimestral', etc. Para descontada: 'd30', 'd60', etc.
  final String? capitalizacion; // Solo si es nominal
  final double valorCOK; // El valor del COK en porcentaje
  final DateTime fechaActualizacion;

  InversorConfigModel({
    this.userId,
    required this.tipoTasa,
    required this.frecuenciaTasa,
    this.capitalizacion,
    required this.valorCOK,
    required this.fechaActualizacion,
  });

  // Constructor desde Map (para base de datos)
  factory InversorConfigModel.fromMap(Map<String, dynamic> map) {
    return InversorConfigModel(
      userId: map['userId'],
      tipoTasa: map['tipoTasa'] ?? 'Efectiva',
      frecuenciaTasa: map['frecuenciaTasa'] ?? 'Anual',
      capitalizacion: map['capitalizacion'],
      valorCOK: (map['valorCOK'] ?? 0.0).toDouble(),
      fechaActualizacion: DateTime.parse(
        map['fechaActualizacion'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Convertir a Map (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tipoTasa': tipoTasa,
      'frecuenciaTasa': frecuenciaTasa,
      'capitalizacion': capitalizacion,
      'valorCOK': valorCOK,
      'fechaActualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  // Copiar con modificaciones
  InversorConfigModel copyWith({
    int? userId,
    String? tipoTasa,
    String? frecuenciaTasa,
    String? capitalizacion,
    double? valorCOK,
    DateTime? fechaActualizacion,
  }) {
    return InversorConfigModel(
      userId: userId ?? this.userId,
      tipoTasa: tipoTasa ?? this.tipoTasa,
      frecuenciaTasa: frecuenciaTasa ?? this.frecuenciaTasa,
      capitalizacion: capitalizacion ?? this.capitalizacion,
      valorCOK: valorCOK ?? this.valorCOK,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'InversorConfigModel(tipoTasa: $tipoTasa, frecuenciaTasa: $frecuenciaTasa, capitalizacion: $capitalizacion, valorCOK: $valorCOK, fechaActualizacion: $fechaActualizacion)';
  }
}
