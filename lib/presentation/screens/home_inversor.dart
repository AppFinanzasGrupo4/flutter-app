import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/core/services/session_service.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/data/datasources/inversor_config_datasource.dart';
import 'package:flutter_finanzasapp/data/datasources/compra_bonos_datasource.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity_ext.dart';
import 'package:flutter_finanzasapp/presentation/screens/inversor/inversor_config_screen.dart';
import 'package:flutter_finanzasapp/presentation/screens/inversor/compra_bono_screen.dart';
import 'package:flutter_finanzasapp/presentation/screens/inversor/analisis_bono_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../domain/entities/bono_entity.dart';

class HomeInversorScreen extends StatefulWidget {
  final UserModel usuario;
  const HomeInversorScreen({super.key, required this.usuario});

  @override
  State<HomeInversorScreen> createState() => _HomeInversorScreenState();
}

class _HomeInversorScreenState extends State<HomeInversorScreen> {
  int _currentIndex = 0;

  void _onCompraRealizada() {
    // Actualizar la pantalla del historial cuando se realiza una compra
    setState(() {
      _currentIndex = 1; // Navegar al historial
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _VerBonosSoloLecturaScreen(onCompraRealizada: _onCompraRealizada),
      const _HistorialComprasScreen(),
      const _ConfigInversorScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Inversor'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // Mostrar diálogo de confirmación
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text(
                      '¿Estás seguro de que quieres cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cerrar diálogo
                          // Cerrar sesión en SessionService
                          SessionService().logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', // Ruta del login
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('Cerrar Sesión'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mostrar mensaje de bienvenida solo en la pestaña de Bonos (índice 0)
          if (_currentIndex == 0 && _currentIndex == 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                'Bienvenido, ${widget.usuario.nombre}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Bonos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Compras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}

/// Widget que muestra los bonos en modo solo lectura para el inversor
class _VerBonosSoloLecturaScreen extends StatefulWidget {
  final VoidCallback? onCompraRealizada;
  const _VerBonosSoloLecturaScreen({this.onCompraRealizada});

  @override
  State<_VerBonosSoloLecturaScreen> createState() =>
      _VerBonosSoloLecturaScreenState();
}

class _VerBonosSoloLecturaScreenState
    extends State<_VerBonosSoloLecturaScreen> {
  late Future<List<dynamic>> _bonosFuture;
  bool _tieneConfigCOK = false;
  double _kokActual = 0.0;
  String _tipoTasaCOK = '';
  String _frecuenciaCOK = '';
  String? _capitalizacionCOK;

  @override
  void initState() {
    super.initState();
    _bonosFuture = _getAllBonos();
    _verificarConfigCOK();
  }

  Future<List<dynamic>> _getAllBonos() async {
    final datasource = await BonoLocalDatasource().getAllBonos();
    return datasource;
  }

  Future<void> _verificarConfigCOK() async {
    final userId = SessionService().currentUserId;
    if (userId == null) return;

    final inversorConfig = InversorConfigDatasource();
    final hasConfig = await inversorConfig.hasConfig(userId);
    if (hasConfig) {
      // Obtener la configuración original (no convertida)
      final configCompleta = await inversorConfig.getConfig(userId);
      if (configCompleta != null) {
        setState(() {
          _tieneConfigCOK = true;
          _kokActual =
              configCompleta.valorCOK / 100; // Mostrar el valor original
          _tipoTasaCOK = configCompleta.tipoTasa;
          _frecuenciaCOK = configCompleta.frecuenciaTasa;
          _capitalizacionCOK = configCompleta.capitalizacion;
        });
      }
    }
  }

  int _frecuenciaPagosPorAnio(String frecuencia) {
    switch (frecuencia) {
      case 'Mensual':
      case 'mensual':
        return 12;
      case 'Bimestral':
      case 'bimestral':
        return 6;
      case 'Trimestral':
      case 'trimestral':
        return 4;
      case 'Cuatrimestral':
      case 'cuatrimestral':
        return 3;
      case 'Semestral':
      case 'semestral':
        return 2;
      case 'Anual':
      case 'anual':
        return 1;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Información del COK configurado
        if (_tieneConfigCOK)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'COK Configurado',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Valor: ${(_kokActual * 100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Tipo: $_tipoTasaCOK $_frecuenciaCOK${_capitalizacionCOK != null ? ' (Cap. $_capitalizacionCOK)' : ''}',
                  style: TextStyle(color: Colors.green.shade600, fontSize: 13),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Configure su COK para realizar cálculos automáticos',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => InversorConfigScreen(
                              onSave: () {
                                Navigator.pop(context);
                                _verificarConfigCOK(); // Actualizar estado
                              },
                            ),
                      ),
                    );
                  },
                  child: const Text('Configurar'),
                ),
              ],
            ),
          ),
        // Lista de bonos
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _bonosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final bonos = snapshot.data ?? [];
              if (bonos.isEmpty) {
                return const Center(child: Text('No hay bonos registrados.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bonos.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final BonoEntity bono = bonos[index];
                  return ListTile(
                    title: Text(bono.nombre),
                    subtitle: Text('${bono.moneda} - ${bono.tipoTasa}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          tooltip: 'Ver información',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => _DetalleBonoScreen(bono: bono),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.calculate),
                          tooltip: 'Calcular',
                          onPressed: () async {
                            // Obtener el COK desde la configuración del inversor
                            final userId = SessionService().currentUserId;
                            if (userId == null) return;

                            final inversorConfig = InversorConfigDatasource();
                            final hasConfig = await inversorConfig.hasConfig(
                              userId,
                            );

                            if (!hasConfig) {
                              // Si no hay configuración, mostrar mensaje y redirigir a configuración
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text(
                                        'Configuración requerida',
                                      ),
                                      content: const Text(
                                        'Debe configurar su COK (Costo de Oportunidad de Capital) antes de realizar cálculos.\n\n¿Desea configurarlo ahora?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        InversorConfigScreen(
                                                          onSave: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                        ),
                                              ),
                                            );
                                          },
                                          child: const Text('Configurar'),
                                        ),
                                      ],
                                    ),
                              );
                              return;
                            }

                            try {
                              // Obtener la configuración completa del COK
                              final configCompleta = await inversorConfig
                                  .getConfig(userId);

                              if (configCompleta == null) {
                                throw Exception(
                                  'No se pudo obtener la configuración del COK',
                                );
                              }

                              // Realizar los cálculos usando la configuración completa
                              final resultados = bono
                                  .calcularDuracionConvexidadConConfig(
                                    tipoTasaCOK: configCompleta.tipoTasa,
                                    frecuenciaTasaCOK:
                                        configCompleta.frecuenciaTasa,
                                    capitalizacionCOK:
                                        configCompleta.capitalizacion,
                                    valorCOK: configCompleta.valorCOK,
                                  ); // Para TREA, usar el precio calculado
                              final precio = resultados['precio']!;
                              final trea = bono.calcularTREA(precio: precio);

                              // Calcular el COK convertido para este bono específico
                              final frecuenciaBono = _frecuenciaPagosPorAnio(
                                bono.frecuenciaPago,
                              );
                              final frecuenciaCOK = _frecuenciaPagosPorAnio(
                                configCompleta.frecuenciaTasa,
                              );

                              double kokConvertido;
                              if (configCompleta.tipoTasa == 'Efectiva') {
                                if (configCompleta.frecuenciaTasa
                                        .toLowerCase() ==
                                    bono.frecuenciaPago.toLowerCase()) {
                                  kokConvertido = configCompleta.valorCOK / 100;
                                } else {
                                  final tasaEfectivaAnual =
                                      pow(
                                        1 +
                                            (configCompleta.valorCOK / 100) /
                                                frecuenciaCOK,
                                        frecuenciaCOK,
                                      ) -
                                      1;
                                  kokConvertido =
                                      pow(
                                        1 + tasaEfectivaAnual,
                                        1 / frecuenciaBono,
                                      ) -
                                      1;
                                }
                              } else if (configCompleta.tipoTasa == 'Nominal') {
                                final frecuenciaCapitalizacion =
                                    _frecuenciaPagosPorAnio(
                                      configCompleta.capitalizacion ??
                                          configCompleta.frecuenciaTasa,
                                    );
                                final tasaEfectivaAnual =
                                    pow(
                                      1 +
                                          (configCompleta.valorCOK / 100) /
                                              frecuenciaCapitalizacion,
                                      frecuenciaCapitalizacion,
                                    ) -
                                    1;
                                kokConvertido =
                                    pow(
                                      1 + tasaEfectivaAnual,
                                      1 / frecuenciaBono,
                                    ) -
                                    1;
                              } else {
                                // Tasa descontada
                                final tasaDescontada =
                                    configCompleta.valorCOK / 100;
                                final dias =
                                    int.tryParse(
                                      configCompleta.frecuenciaTasa.substring(
                                        1,
                                      ),
                                    ) ??
                                    360;

                                // Convertir tasa descontada a tasa efectiva para el período específico
                                final tasaEfectivaPeriodo =
                                    tasaDescontada / (1 - tasaDescontada);

                                // Convertir a tasa efectiva anual
                                final periodosPorAnio = 360.0 / dias;
                                final tasaEfectivaAnual =
                                    pow(
                                      1 + tasaEfectivaPeriodo,
                                      periodosPorAnio,
                                    ) -
                                    1;

                                // Convertir a la frecuencia del bono
                                kokConvertido =
                                    pow(
                                      1 + tasaEfectivaAnual,
                                      1 / frecuenciaBono,
                                    ) -
                                    1;
                              }

                              // Navegar a la pantalla de análisis
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => AnalisisBonoScreen(
                                        bono: bono,
                                        cok:
                                            kokConvertido, // COK convertido para este bono
                                        resultados: resultados,
                                        trea: trea,
                                      ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al realizar cálculos: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          tooltip: 'Comprar bono',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => CompraBonoPantalla(
                                      bono: bono,
                                      onCompraRealizada:
                                          widget.onCompraRealizada,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistorialComprasScreen extends StatefulWidget {
  const _HistorialComprasScreen();

  @override
  State<_HistorialComprasScreen> createState() =>
      _HistorialComprasScreenState();
}

class _HistorialComprasScreenState extends State<_HistorialComprasScreen> {
  late Future<List<dynamic>> _comprasFuture;
  final _currencyFormat = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/.',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _comprasFuture = _cargarCompras();
  }

  Future<List<dynamic>> _cargarCompras() async {
    final datasource = CompraBonosDatasource();
    final userId = SessionService().currentUserId;
    if (userId != null) {
      return await datasource.getComprasByUser(userId);
    }
    return [];
  }

  void _actualizarCompras() {
    setState(() {
      _comprasFuture = _cargarCompras();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _actualizarCompras();
      },
      child: FutureBuilder<List<dynamic>>(
        future: _comprasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final compras = snapshot.data ?? [];
          if (compras.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('No hay compras realizadas.'),
                  Text(
                    '¡Compra tu primer bono!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: compras.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final compra = compras[index];
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.account_balance,
                    color: Colors.green,
                  ),
                  title: Text(compra.nombreBono),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precio: ${_currencyFormat.format(compra.precio)}'),
                      Text(
                        'COK: ${(compra.cokUtilizado * 100).toStringAsFixed(2)}%',
                      ),
                      Text(
                        'Fecha: ${compra.fechaCompra.toString().substring(0, 19)}',
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'detalles',
                            child: Row(
                              children: [
                                Icon(Icons.info_outline),
                                SizedBox(width: 8),
                                Text('Ver detalles'),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'detalles') {
                        _mostrarDetallesCompra(compra);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDetallesCompra(dynamic compra) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Detalles de ${compra.nombreBono}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Precio pagado: ${_currencyFormat.format(compra.precio)}',
                  ),
                  Text(
                    'Valor nominal: ${_currencyFormat.format(compra.valorNominal)}',
                  ),
                  Text(
                    'COK utilizado: ${(compra.cokUtilizado * 100).toStringAsFixed(2)}%',
                  ),
                  Text(
                    'Fecha de compra: ${compra.fechaCompra.toString().substring(0, 19)}',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Flujo de Caja:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Período')),
                          DataColumn(label: Text('Intereses')),
                          DataColumn(label: Text('Principal')),
                          DataColumn(label: Text('Total')),
                        ],
                        rows:
                            compra.flujoCaja.map<DataRow>((flujo) {
                              return DataRow(
                                cells: [
                                  DataCell(Text('${flujo['Periodo']}')),
                                  DataCell(
                                    Text(
                                      _currencyFormat.format(
                                        flujo['Intereses'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _currencyFormat.format(
                                        flujo['Pago Principal'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _currencyFormat.format(
                                        flujo['Pago Total'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}

class _ConfigInversorScreen extends StatelessWidget {
  const _ConfigInversorScreen();

  @override
  Widget build(BuildContext context) {
    return InversorConfigScreen(
      onSave: () {
        // Puedes agregar lógica adicional si es necesario
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada.')),
        );
      },
    );
  }
}

class _DetalleBonoScreen extends StatelessWidget {
  final BonoEntity bono;

  const _DetalleBonoScreen({required this.bono});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: bono.moneda == 'USD' ? '\$' : 'S/.',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Información de ${bono.nombre}'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          color: Colors.indigo[600],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Información Básica',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Nombre', bono.nombre),
                    _buildInfoRow('Moneda', bono.moneda),
                    _buildInfoRow(
                      'Valor Nominal',
                      currencyFormat.format(bono.valorNominal),
                    ),
                    _buildInfoRow('Plazo', '${bono.plazo} años'),
                    _buildInfoRow('Tipo de Tasa', bono.tipoTasa),
                    if (bono.frecuenciaTasa != null)
                      _buildInfoRow('Frecuencia de Tasa', bono.frecuenciaTasa!),

                    if (bono.capitalizacion != null)
                      _buildInfoRow('Capitalización', bono.capitalizacion!),
                    _buildInfoRow(
                      'Tasa de Interés',
                      '${bono.tasaInteres.toStringAsFixed(2)}%',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información de pagos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.blue[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Información de Pagos',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Frecuencia de Pago', bono.frecuenciaPago),
                    _buildInfoRow(
                      'Tipo de Gracia',
                      _getTipoGraciaText(bono.tipoGracia),
                    ),
                    if (bono.periodoGracia > 0)
                      _buildInfoRow(
                        'Período de Gracia',
                        '${bono.periodoGracia} períodos',
                      ),
                    _buildInfoRow(
                      'Prima de Redención',
                      '${bono.primaRedencion.toStringAsFixed(2)}%',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fechas
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.green[50]!, Colors.green[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.green[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Fechas Importantes',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Fecha de Emisión',
                      DateFormat('dd/MM/yyyy').format(bono.fechaEmision),
                    ),
                    _buildInfoRow(
                      'Fecha de Vencimiento',
                      DateFormat('dd/MM/yyyy').format(bono.fechaVencimiento),
                    ),
                    _buildInfoRow(
                      'Días hasta Vencimiento',
                      '${bono.fechaVencimiento.difference(DateTime.now()).inDays} días',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Costos
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.orange[50]!, Colors.orange[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.orange[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Costos Asociados',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Costo de Estructuración',
                      '${bono.costoEstructuracion.toStringAsFixed(2)}%',
                    ),
                    _buildInfoRow(
                      'Costo de Colocación',
                      '${bono.costoColocacion.toStringAsFixed(2)}%',
                    ),
                    _buildInfoRow(
                      'Costo de Flotación',
                      '${bono.costoFlotacion.toStringAsFixed(2)}%',
                    ),
                    _buildInfoRow(
                      'Costo Cavali',
                      '${bono.costoCavali.toStringAsFixed(2)}%',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Total de Costos',
                      '${(bono.costoEstructuracion + bono.costoColocacion + bono.costoFlotacion + bono.costoCavali).toStringAsFixed(2)}%',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botón de cerrar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                fontSize: isHighlight ? 16 : 15,
                color: isHighlight ? Colors.indigo[700] : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getTipoGraciaText(dynamic tipoGracia) {
    switch (tipoGracia.toString()) {
      case 'TipoGracia.ninguna':
        return 'Sin gracia';
      case 'TipoGracia.total':
        return 'Gracia total';
      case 'TipoGracia.parcial':
        return 'Gracia parcial';
      default:
        return tipoGracia.toString().split('.').last;
    }
  }
}
