class Bono {
  final double valorNominal;
  final double tasa;
  final String frecuenciaPago;
  final int plazoAnos;
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;

  Bono({
    required this.valorNominal,
    required this.tasa,
    required this.frecuenciaPago,
    required this.plazoAnos,
    required this.fechaEmision,
    required this.fechaVencimiento,
  });
}
