import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';
import 'package:flutter_finanzasapp/domain/calc/calc_tcea.dart';
import 'package:flutter_finanzasapp/domain/calc/flujo_caja.dart';
import 'package:intl/intl.dart';

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
  bool _calculando = false;

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

  Future<void> calcularFlujoCaja() async {
    if (bonoSeleccionado != null) {
      setState(() {
        _calculando = true;
      });

      // Simular un pequeño delay para mostrar el loading
      await Future.delayed(const Duration(milliseconds: 500));

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
        _calculando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bonos.isEmpty ? _buildEmptyState() : _buildDashboard(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[50]!, Colors.white],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.indigo[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance,
                size: 64,
                color: Colors.indigo[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay bonos creados',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primer bono para comenzar a analizar',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/crear-bono');
              },
              icon: const Icon(Icons.add_circle),
              label: const Text('Crear Primer Bono'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[50]!, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.indigo[600]!, Colors.indigo[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Análisis de Bonos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Calcula flujos de caja y TCEA de tus bonos',
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
              ),
            ),

            const SizedBox(height: 24),
            _buildBonoSelectionCard(),
            const SizedBox(height: 20),
            if (bonoSeleccionado != null) ...[
              _buildBonoDetailsCard(),
              const SizedBox(height: 20),
              _buildCalculateButton(),
              const SizedBox(height: 20),
            ],
            if (flujoCaja.isNotEmpty && _tcea != null) ...[
              _buildTceaCard(),
              const SizedBox(height: 20),
              _buildFlujoCajaCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBonoSelectionCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                Icon(Icons.account_balance, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Seleccionar Bono',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue[300]!),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BonoModel>(
                  value: bonoSeleccionado,
                  hint: Text(
                    'Selecciona un bono para analizar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
                  items:
                      bonos.map((bono) {
                        return DropdownMenuItem(
                          value: bono,
                          child: Text(
                            bono.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      bonoSeleccionado = value;
                      flujoCaja = [];
                      _tcea = null;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonoDetailsCard() {
    final bono = bonoSeleccionado!;
    final formatCurrency = NumberFormat.currency(
      symbol: bono.moneda == 'USD' ? '\$' : 'S/',
      decimalDigits: 2,
    );

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                Icon(Icons.info_outline, color: Colors.green[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Detalles del Bono',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Valor Nominal',
                    formatCurrency.format(bono.valorNominal),
                    Icons.monetization_on,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Tasa de Interés',
                    '${bono.tasaInteres.toStringAsFixed(2)}% ${bono.tipoTasa}',
                    Icons.percent,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Frecuencia de Pago',
                    bono.frecuenciaPago,
                    Icons.schedule,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Plazo',
                    '${bono.plazo} años',
                    Icons.access_time,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Moneda', bono.moneda, Icons.attach_money),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.orange[500]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed:
            bonoSeleccionado != null && !_calculando ? calcularFlujoCaja : null,
        icon:
            _calculando
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.calculate, color: Colors.white),
        label: Text(
          _calculando ? 'Calculando...' : 'Calcular Flujo de Caja y TCEA',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildTceaCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.purple[600]!, Colors.purple[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'TCEA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_tcea!.toStringAsFixed(2)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasa de Costo Efectivo Anual',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlujoCajaCard() {
    final formatCurrency = NumberFormat.currency(
      symbol: bonoSeleccionado!.moneda == 'USD' ? '\$' : 'S/',
      decimalDigits: 2,
    );

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                Icon(Icons.table_chart, color: Colors.orange[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Flujo de Caja(Americano)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      Colors.orange[100],
                    ),
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(label: Text('Período')),
                      DataColumn(label: Text('Intereses')),
                      DataColumn(label: Text('Pago Principal')),
                      DataColumn(label: Text('Pago Total')),
                    ],
                    rows:
                        flujoCaja.map((flujo) {
                          final periodo = flujo['Periodo'] as int;
                          final intereses = flujo['Intereses'] as double;
                          final principal = flujo['Pago Principal'] as double;
                          final total = flujo['Pago Total'] as double;

                          final isInversionInicial = periodo == 0;

                          return DataRow(
                            color:
                                isInversionInicial
                                    ? WidgetStateProperty.all(Colors.orange[50])
                                    : null,
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isInversionInicial
                                            ? Colors.orange[200]
                                            : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    periodo.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isInversionInicial
                                              ? Colors.orange[800]
                                              : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  formatCurrency.format(intereses),
                                  style: TextStyle(
                                    color:
                                        intereses >= 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  formatCurrency.format(principal),
                                  style: TextStyle(
                                    color:
                                        principal >= 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  formatCurrency.format(total),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        total >= 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
            if (flujoCaja.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'El período 0 representa la inversión inicial. Los valores negativos indican salidas de efectivo.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
