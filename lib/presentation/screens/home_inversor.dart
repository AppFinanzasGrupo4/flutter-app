import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity_ext.dart';
import 'package:flutter_finanzasapp/presentation/screens/config_screen.dart';

import '../../domain/entities/bono_entity.dart';

class HomeInversorScreen extends StatefulWidget {
  final UserModel usuario;
  const HomeInversorScreen({super.key, required this.usuario});

  @override
  State<HomeInversorScreen> createState() => _HomeInversorScreenState();
}

class _HomeInversorScreenState extends State<HomeInversorScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _historial = [];

  void _agregarHistorial(Map<String, dynamic> calculo) {
    setState(() {
      _historial.insert(0, calculo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _VerBonosSoloLecturaScreen(onCalculo: _agregarHistorial),
      _HistorialCalculosScreen(historial: _historial),
      _ConfigInversorScreen(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Home Inversor')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Bienvenido, ${widget.usuario.nombre}', style: const TextStyle(fontSize: 20)),
          ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Bonos'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}

/// Widget que muestra los bonos en modo solo lectura para el inversor
class _VerBonosSoloLecturaScreen extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onCalculo;
  const _VerBonosSoloLecturaScreen({this.onCalculo});

  @override
  State<_VerBonosSoloLecturaScreen> createState() => _VerBonosSoloLecturaScreenState();
}

class _VerBonosSoloLecturaScreenState extends State<_VerBonosSoloLecturaScreen> {
  late Future<List<dynamic>> _bonosFuture;

  @override
  void initState() {
    super.initState();
    _bonosFuture = _getAllBonos();
  }

  Future<List<dynamic>> _getAllBonos() async {
    final datasource = await BonoLocalDatasource().getAllBonos();
    return datasource;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
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
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Información de ${bono.nombre}'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Moneda: ${bono.moneda}'),
                                Text('Tipo de Tasa: ${bono.tipoTasa}'),
                                if (bono.capitalizacion != null) Text('Capitalización: ${bono.capitalizacion}'),
                                Text('Valor Nominal: ${bono.valorNominal}'),
                                Text('Plazo: ${bono.plazo}'),
                                Text('Tasa de Interés: ${bono.tasaInteres}'),
                                if (bono.frecuenciaTasa != null) Text('Frecuencia Tasa: ${bono.frecuenciaTasa}'),
                                Text('Tipo Gracia: ${bono.tipoGracia.name}'),
                                Text('Periodo Gracia: ${bono.periodoGracia}'),
                                Text('Frecuencia Pago: ${bono.frecuenciaPago}'),
                                Text('Fecha Emisión: ${bono.fechaEmision.toString().substring(0,10)}'),
                                Text('Fecha Vencimiento: ${bono.fechaVencimiento.toString().substring(0,10)}'),
                                Text('Costo Estructuración: ${bono.costoEstructuracion}%'),
                                Text('Costo Colocación: ${bono.costoColocacion}%'),
                                Text('Costo Flotación: ${bono.costoFlotacion}%'),
                                Text('Costo Cavali: ${bono.costoCavali}%'),
                                Text('Prima Redención: ${bono.primaRedencion}%'),
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
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.calculate),
                    tooltip: 'Calcular',
                    onPressed: () async {
                      final cok = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text('Ingrese el COK (%)'),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: 'Ejemplo: 10'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final text = controller.text.trim().replaceAll(',', '.');
                                  if (text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Debe ingresar un valor numérico')),
                                    );
                                    return;
                                  }
                                  final value = double.tryParse(text);
                                  if (value != null) {
                                    Navigator.of(context, rootNavigator: true).pop(value / 100);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Valor inválido')),
                                    );
                                  }
                                },
                                child: const Text('Calcular'),
                              ),
                            ],
                          );
                        },
                      );
                      if (cok != null) {
                        final resultados = bono.calcularDuracionConvexidad(cok: cok);
                        final trea = bono.calcularTREA(cok: cok);
                        widget.onCalculo?.call({
                          'bono': bono.nombre,
                          'cok': cok * 100,
                          'duracion': resultados['duracion'],
                          'duracionModificada': resultados['duracionModificada'],
                          'convexidad': resultados['convexidad'],
                          'trea': trea * 100,
                          'fecha': DateTime.now(),
                        });
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Resultados para ${bono.nombre}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Duración: ${resultados['duracion']?.toStringAsFixed(4)}'),
                                Text('Duración Modificada: ${resultados['duracionModificada']?.toStringAsFixed(4)}'),
                                Text('Convexidad: ${resultados['convexidad']?.toStringAsFixed(4)}'),
                                Text('TREA: ${(trea * 100).toStringAsFixed(2)}%'),
                              ],
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
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HistorialCalculosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> historial;
  const _HistorialCalculosScreen({required this.historial});

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return const Center(child: Text('No hay cálculos realizados.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: historial.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final h = historial[i];
        return ListTile(
          title: Text('Bono: ${h['bono']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COK: ${h['cok'].toStringAsFixed(2)}%'),
              Text('Duración: ${h['duracion']?.toStringAsFixed(4)}'),
              Text('Duración Modificada: ${h['duracionModificada']?.toStringAsFixed(4)}'),
              Text('Convexidad: ${h['convexidad']?.toStringAsFixed(4)}'),
              Text('TREA: ${h['trea']?.toStringAsFixed(2)}%'),
              Text('Fecha: ${h['fecha'].toString().substring(0, 19)}'),
            ],
          ),
        );
      },
    );
  }
}

class _ConfigInversorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConfigScreen(
      onSave: () {
        // Puedes agregar lógica adicional si es necesario
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada.')),
        );
      },
    );
  }
}