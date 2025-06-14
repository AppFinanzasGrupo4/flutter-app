class BonoModel {
  final int? id;
  final double valorNominal;
  final double tasa;
  final String frecuenciaPago;
  final int plazoAnios;
  final String fechaEmision;
  final String fechaVencimiento;

  BonoModel({
    this.id,
    required this.valorNominal,
    required this.tasa,
    required this.frecuenciaPago,
    required this.plazoAnios,
    required this.fechaEmision,
    required this.fechaVencimiento,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valorNominal': valorNominal,
      'tasa': tasa,
      'frecuenciaPago': frecuenciaPago,
      'plazoAnios': plazoAnios,
      'fechaEmision': fechaEmision,
      'fechaVencimiento': fechaVencimiento,
    };
  }

  factory BonoModel.fromMap(Map<String, dynamic> map) {
    return BonoModel(
      id: map['id'],
      valorNominal: map['valorNominal'],
      tasa: map['tasa'],
      frecuenciaPago: map['frecuenciaPago'],
      plazoAnios: map['plazoAnios'],
      fechaEmision: map['fechaEmision'],
      fechaVencimiento: map['fechaVencimiento'],
    );
  }
}
