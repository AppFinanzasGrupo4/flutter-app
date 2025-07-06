import '../../domain/entities/bono_entity.dart';

class CompraBonoModel {
  final int? id;
  final int userId; // ID del inversor que compró el bono
  final String nombreBono;
  final double precio;
  final double cokUtilizado;
  final double valorNominal;
  final DateTime fechaCompra;
  final Map<String, dynamic>
  detallesBono; // Para almacenar info completa del bono
  final List<Map<String, dynamic>> flujoCaja; // El flujo de caja calculado

  CompraBonoModel({
    this.id,
    required this.userId,
    required this.nombreBono,
    required this.precio,
    required this.cokUtilizado,
    required this.valorNominal,
    required this.fechaCompra,
    required this.detallesBono,
    required this.flujoCaja,
  });

  // Constructor desde Map (para base de datos)
  factory CompraBonoModel.fromMap(Map<String, dynamic> map) {
    return CompraBonoModel(
      id: map['id'],
      userId: map['userId'] ?? 0,
      nombreBono: map['nombreBono'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      cokUtilizado: (map['cokUtilizado'] ?? 0.0).toDouble(),
      valorNominal: (map['valorNominal'] ?? 0.0).toDouble(),
      fechaCompra: DateTime.parse(
        map['fechaCompra'] ?? DateTime.now().toIso8601String(),
      ),
      detallesBono:
          map['detallesBono'] != null
              ? Map<String, dynamic>.from(map['detallesBono'])
              : {},
      flujoCaja:
          map['flujoCaja'] != null
              ? List<Map<String, dynamic>>.from(map['flujoCaja'])
              : [],
    );
  }

  // Convertir a Map (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'nombreBono': nombreBono,
      'precio': precio,
      'cokUtilizado': cokUtilizado,
      'valorNominal': valorNominal,
      'fechaCompra': fechaCompra.toIso8601String(),
      'detallesBono': detallesBono,
      'flujoCaja': flujoCaja,
    };
  }

  // Constructor desde BonoEntity
  factory CompraBonoModel.fromBono({
    required int userId,
    required BonoEntity bono,
    required double precio,
    required double cokUtilizado,
    required List<Map<String, dynamic>> flujoCaja,
  }) {
    return CompraBonoModel(
      userId: userId,
      nombreBono: bono.nombre,
      precio: precio,
      cokUtilizado: cokUtilizado,
      valorNominal: bono.valorNominal,
      fechaCompra: DateTime.now(),
      detallesBono: {
        'moneda': bono.moneda,
        'tipoTasa': bono.tipoTasa,
        'capitalizacion': bono.capitalizacion,
        'plazo': bono.plazo,
        'tasaInteres': bono.tasaInteres,
        'frecuenciaTasa': bono.frecuenciaTasa,
        'tipoGracia': bono.tipoGracia.name,
        'periodoGracia': bono.periodoGracia,
        'frecuenciaPago': bono.frecuenciaPago,
        'fechaEmision': bono.fechaEmision.toIso8601String(),
        'fechaVencimiento': bono.fechaVencimiento.toIso8601String(),
        'costoEstructuracion': bono.costoEstructuracion,
        'costoColocacion': bono.costoColocacion,
        'costoFlotacion': bono.costoFlotacion,
        'costoCavali': bono.costoCavali,
        'primaRedencion': bono.primaRedencion,
      },
      flujoCaja: flujoCaja,
    );
  }

  // Copiar con modificaciones
  CompraBonoModel copyWith({
    int? id,
    int? userId,
    String? nombreBono,
    double? precio,
    double? cokUtilizado,
    double? valorNominal,
    DateTime? fechaCompra,
    Map<String, dynamic>? detallesBono,
    List<Map<String, dynamic>>? flujoCaja,
  }) {
    return CompraBonoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombreBono: nombreBono ?? this.nombreBono,
      precio: precio ?? this.precio,
      cokUtilizado: cokUtilizado ?? this.cokUtilizado,
      valorNominal: valorNominal ?? this.valorNominal,
      fechaCompra: fechaCompra ?? this.fechaCompra,
      detallesBono: detallesBono ?? this.detallesBono,
      flujoCaja: flujoCaja ?? this.flujoCaja,
    );
  }

  @override
  String toString() {
    return 'CompraBonoModel(id: $id, nombreBono: $nombreBono, precio: $precio, cokUtilizado: $cokUtilizado, valorNominal: $valorNominal, fechaCompra: $fechaCompra)';
  }
}
