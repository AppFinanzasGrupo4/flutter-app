import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';
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

  void calcularFlujoCaja() {
    if (bonoSeleccionado != null) {
      setState(() {
        flujoCaja = calcularFlujosCaja(bonoSeleccionado!);
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
                    ],
                  ],
                ),
              ),
    );
  }
}
