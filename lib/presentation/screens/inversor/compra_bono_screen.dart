import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/session_service.dart';
import '../../../domain/entities/bono_entity.dart';
import '../../../domain/calc/flujo_caja.dart';
import '../../../domain/calc/precio_bono.dart';
import '../../../data/models/bono_model.dart';
import '../../../data/models/compra_bono_model.dart';
import '../../../data/datasources/compra_bonos_datasource.dart';
import '../../../data/datasources/inversor_config_datasource.dart';

class CompraBonoPantalla extends StatefulWidget {
  final BonoEntity bono;
  final VoidCallback? onCompraRealizada;

  const CompraBonoPantalla({
    super.key,
    required this.bono,
    this.onCompraRealizada,
  });

  @override
  State<CompraBonoPantalla> createState() => _CompraBonoPantallaState();
}

class _CompraBonoPantallaState extends State<CompraBonoPantalla> {
  bool _isLoading = true;
  bool _isComprando = false;

  double _cokInversor = 0.0;
  double _precioBono = 0.0;
  List<Map<String, dynamic>> _flujoCaja = [];
  Map<String, double> _metricas = {};

  final _currencyFormat = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/.',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _cargarDatosCompra();
  }

  Future<void> _cargarDatosCompra() async {
    setState(() => _isLoading = true);

    try {
      final userId = SessionService().currentUserId;
      if (userId == null) {
        throw Exception('Usuario no identificado');
      }

      // Obtener COK del inversor
      final inversorConfig = InversorConfigDatasource();
      _cokInversor = await inversorConfig.getCOKEfectivo(userId);

      // Convertir BonoEntity a BonoModel para generar flujo de caja
      final bonoModel = _convertirABonoModel(widget.bono);

      // Generar flujo de caja
      _flujoCaja = calcularFlujosCaja(bonoModel);

      // Calcular precio del bono
      _precioBono = calcularPrecioBono(
        flujoCaja: _flujoCaja,
        cokInversor: _cokInversor,
      );

      // Calcular métricas adicionales
      _metricas = calcularMetricasBono(
        flujoCaja: _flujoCaja,
        cokInversor: _cokInversor,
        precio: _precioBono,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  BonoModel _convertirABonoModel(BonoEntity entity) {
    return BonoModel(
      nombre: entity.nombre,
      moneda: entity.moneda,
      tipoTasa: entity.tipoTasa,
      capitalizacion: entity.capitalizacion,
      valorNominal: entity.valorNominal,
      plazo: entity.plazo,
      tasaInteres: entity.tasaInteres,
      frecuenciaTasa: entity.frecuenciaTasa,
      tipoGracia: entity.tipoGracia,
      periodoGracia: entity.periodoGracia,
      frecuenciaPago: entity.frecuenciaPago,
      fechaEmision: entity.fechaEmision,
      fechaVencimiento: entity.fechaVencimiento,
      costoEstructuracion: entity.costoEstructuracion,
      costoColocacion: entity.costoColocacion,
      costoFlotacion: entity.costoFlotacion,
      costoCavali: entity.costoCavali,
      primaRedencion: entity.primaRedencion,
    );
  }

  Future<void> _realizarCompra() async {
    setState(() => _isComprando = true);

    try {
      final userId = SessionService().currentUserId;
      if (userId == null) {
        throw Exception('Usuario no identificado');
      }

      // Crear el registro de compra
      final compra = CompraBonoModel.fromBono(
        userId: userId,
        bono: widget.bono,
        precio: _precioBono,
        cokUtilizado: _cokInversor,
        flujoCaja: _flujoCaja,
      );

      // Guardar en la base de datos
      final datasource = CompraBonosDatasource();
      await datasource.registrarCompra(compra);

      if (mounted) {
        // Mostrar confirmación
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('¡Compra Realizada!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Has comprado exitosamente el bono "${widget.bono.nombre}"',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Precio pagado: ${_currencyFormat.format(_precioBono)}',
                    ),
                    Text(
                      'COK utilizado: ${(_cokInversor * 100).toStringAsFixed(2)}%',
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.of(
                        context,
                      ).pop(); // Volver a la pantalla anterior
                      widget.onCompraRealizada?.call();
                    },
                    child: const Text('Continuar'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar compra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isComprando = false);
    }
  }

  void _mostrarConfirmacionCompra() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Compra'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Está seguro de comprar el bono "${widget.bono.nombre}"?',
                ),
                const SizedBox(height: 16),
                Text('Precio: ${_currencyFormat.format(_precioBono)}'),
                Text('COK: ${(_cokInversor * 100).toStringAsFixed(2)}%'),
                Text(
                  'Valor Nominal: ${_currencyFormat.format(widget.bono.valorNominal)}',
                ),
                if (_metricas['descuento']! > 0)
                  Text(
                    'Descuento: ${_currencyFormat.format(_metricas['descuento']!)} (${_metricas['descuentoPorcentual']!.toStringAsFixed(2)}%)',
                    style: const TextStyle(color: Colors.green),
                  )
                else if (_metricas['descuento']! < 0)
                  Text(
                    'Prima: ${_currencyFormat.format(-_metricas['descuento']!)} (${(-_metricas['descuentoPorcentual']!).toStringAsFixed(2)}%)',
                    style: const TextStyle(color: Colors.orange),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _realizarCompra();
                },
                child: const Text('Confirmar Compra'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Comprar ${widget.bono.nombre}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del bono
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Información del Bono',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Detalles generales del instrumento',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRowWhite('Nombre', widget.bono.nombre),
                            _buildInfoRowWhite('Moneda', widget.bono.moneda),
                            _buildInfoRowWhite(
                              'Valor Nominal',
                              _currencyFormat.format(widget.bono.valorNominal),
                            ),
                            _buildInfoRowWhite(
                              'Plazo',
                              '${widget.bono.plazo} años',
                            ),
                            _buildInfoRowWhite(
                              'Tasa Interés',
                              '${widget.bono.tasaInteres}%',
                            ),
                            _buildInfoRowWhite(
                              'Frecuencia Pago',
                              widget.bono.frecuenciaPago,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Análisis de precio
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.analytics,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Análisis de Precio',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Cálculos basados en tu COK',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow(
                              'COK Utilizado',
                              '${(_cokInversor * 100).toStringAsFixed(2)}%',
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green.withOpacity(0.1),
                                    Colors.blue.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.monetization_on,
                                        color: Colors.green[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Precio Calculado',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _currencyFormat.format(_precioBono),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildInfoRow(
                              'Valor Nominal',
                              _currencyFormat.format(
                                _metricas['valorNominal']!,
                              ),
                            ),
                            if (_metricas['descuento']! > 0)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.trending_down,
                                      color: Colors.green[600],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Descuento: ${_currencyFormat.format(_metricas['descuento']!)} (${_metricas['descuentoPorcentual']!.toStringAsFixed(2)}%)',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (_metricas['descuento']! < 0)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      color: Colors.orange[600],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Prima: ${_currencyFormat.format(-_metricas['descuento']!)} (${(-_metricas['descuentoPorcentual']!).toStringAsFixed(2)}%)',
                                      style: TextStyle(
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _buildInfoRow(
                              'Rendimiento Total',
                              '${_metricas['rendimientoPorcentual']!.toStringAsFixed(2)}%',
                            ),
                            _buildInfoRow(
                              'YTM Estimado',
                              '${_metricas['ytm']!.toStringAsFixed(2)}%',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Flujo de caja
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.timeline,
                                    color: Colors.purple,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Flujo de Caja',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_flujoCaja.length} periodos de pago',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 350,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  // Encabezados de la tabla
                                  Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.purple.withOpacity(0.1),
                                          Colors.blue.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Período',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Intereses',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Principal',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Total',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Contenido scrolleable
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _flujoCaja.length,
                                      itemBuilder: (context, index) {
                                        final flujo = _flujoCaja[index];
                                        final esUltimoPeriodo =
                                            index == _flujoCaja.length - 1;
                                        final esInversion =
                                            flujo['Periodo'] == 0;

                                        return Container(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                esInversion
                                                    ? Colors.red.shade50
                                                    : esUltimoPeriodo
                                                    ? Colors.green.shade50
                                                    : index % 2 == 0
                                                    ? Colors.grey.shade50
                                                    : Colors.white,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${flujo['Periodo']}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight:
                                                        esInversion ||
                                                                esUltimoPeriodo
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  _currencyFormat.format(
                                                    flujo['Intereses'] ?? 0.0,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  _currencyFormat.format(
                                                    flujo['Pago Principal'] ??
                                                        0.0,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  _currencyFormat.format(
                                                    flujo['Pago Total'] ?? 0.0,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        esInversion ||
                                                                esUltimoPeriodo
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                    color:
                                                        esInversion
                                                            ? Colors
                                                                .red
                                                                .shade700
                                                            : esUltimoPeriodo
                                                            ? Colors
                                                                .green
                                                                .shade700
                                                            : null,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones de acción
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Volver'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isComprando
                                      ? null
                                      : _mostrarConfirmacionCompra,
                              icon:
                                  _isComprando
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Icon(Icons.shopping_cart),
                              label: Text(
                                _isComprando ? 'Procesando...' : 'Comprar Bono',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWhite(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
