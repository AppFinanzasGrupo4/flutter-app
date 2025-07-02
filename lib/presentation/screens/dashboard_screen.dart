import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';
import 'package:flutter_finanzasapp/domain/calc/calc_tcea.dart';
import 'package:flutter_finanzasapp/domain/calc/flujo_caja.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<BonoModel> bonos = [];
  BonoModel? bonoSeleccionado;
  List<Map<String, dynamic>> flujoCaja = [];
  double? _tcea;

  @override
  void initState() {
    super.initState();
    cargarBonos();
  }

  Future<void> cargarBonos() async {
    final lista = await BonoLocalDatasource().getAllBonos();
    setState(() {
      bonos = lista;
    });
  }

  int _frecuenciaToInt(String frecuencia) {
    switch (frecuencia.toLowerCase()) {
      case 'mensual':
        return 12;
      case 'bimestral':
        return 6;
      case 'trimestral':
        return 4;
      case 'semestral':
        return 2;
      case 'anual':
        return 1;
      default:
        return 1;
    }
  }

  void calcularFlujoCaja() {
    if (bonoSeleccionado != null) {
      setState(() {
        flujoCaja = calcularFlujosCaja(bonoSeleccionado!);

        // El flujo de caja ya incluye la inversión inicial en el período 0
        // Obtenemos la inversión inicial del período 0
        double inversionInicial = 0.0;
        if (flujoCaja.isNotEmpty && flujoCaja.first['Periodo'] == 0) {
          inversionInicial =
              -flujoCaja
                  .first['Pago Total']; // Es negativo, lo convertimos a positivo
        }

        // Calcular TIR periódica (usando todos los flujos incluido el período 0)
        double tirPeriodica = calcularTIRPeriodica(flujoCaja, inversionInicial);

        // Calcular TCEA
        _tcea = calcularTCEA(
          tirPeriodica,
          _frecuenciaToInt(bonoSeleccionado!.frecuenciaPago),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body:
          bonos.isEmpty
              ? const Center(child: Text('No hay bonos creados.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona un Bono:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<BonoModel>(
                      value: bonoSeleccionado,
                      hint: const Text('Selecciona un bono'),
                      items:
                          bonos.map((bono) {
                            return DropdownMenuItem(
                              value: bono,
                              child: Text(bono.nombre),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          bonoSeleccionado = value;
                          flujoCaja =
                              []; // Limpiar flujo de caja al cambiar bono
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: calcularFlujoCaja,
                      child: const Text('Calcular Flujo de Caja'),
                    ),
                    const SizedBox(height: 24),
                    if (flujoCaja.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      // Mostrar TCEA
                      Text(
                        'TCEA : ${_tcea!.toStringAsFixed(2)} %',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Flujo de Caja (Método Americano)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Periodo')),
                            DataColumn(label: Text('Intereses')),
                            DataColumn(label: Text('Pago Principal')),
                            DataColumn(label: Text('Pago Total')),
                          ],
                          rows:
                              flujoCaja.map((flujo) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(flujo['Periodo'].toString())),
                                    DataCell(
                                      Text(flujo['Intereses'].toString()),
                                    ),
                                    DataCell(
                                      Text(flujo['Pago Principal'].toString()),
                                    ),
                                    DataCell(
                                      Text(flujo['Pago Total'].toString()),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Depuración de Cálculos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Mostrar inversión inicial
                      Text(
                        'Inversión Inicial: ${flujoCaja.isNotEmpty && flujoCaja.first['Periodo'] == 0 ? (-flujoCaja.first['Pago Total']).toStringAsFixed(2) : "No disponible"}',
                      ),
                      const SizedBox(height: 8),
                      // Mostrar TIR periódica
                      Text(
                        'TIR Periódica: ${flujoCaja.isNotEmpty ? calcularTIRPeriodica(flujoCaja, flujoCaja.first['Periodo'] == 0 ? -flujoCaja.first['Pago Total'] : 0.0).toStringAsFixed(4) : "No disponible"}',
                      ),
                      const SizedBox(height: 8),
                      // Mostrar TCEA
                      Text('TCEA: ${_tcea!.toStringAsFixed(2)} %'),
                    ],
                  ],
                ),
              ),
    );
  }
}
