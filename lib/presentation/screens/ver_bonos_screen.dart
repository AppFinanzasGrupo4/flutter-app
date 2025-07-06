import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';
import 'package:flutter_finanzasapp/presentation/screens/crear_bono_screen.dart';

class VerBonosScreen extends StatefulWidget {
  const VerBonosScreen({super.key});

  @override
  State<VerBonosScreen> createState() => _VerBonosScreenState();
}

class _VerBonosScreenState extends State<VerBonosScreen> {
  late Future<List<BonoModel>> _bonosFuture;

  @override
  void initState() {
    super.initState();
    _bonosFuture = BonoLocalDatasource().getAllBonos();
  }

  Future<void> _recargar() async {
    setState(() {
      _bonosFuture = BonoLocalDatasource().getAllBonos();
    });
  }

  Future<void> _eliminarBono(int id) async {
    final db = await BonoLocalDatasource().database;
    await db.delete('bonos', where: 'id = ?', whereArgs: [id]);
    _recargar();
  }

  void _confirmarEliminacion(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('¿Eliminar bono?'),
            content: const Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _eliminarBono(id);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _editarBono(BonoModel bono) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CrearBonoScreen(
              bonoExistente: bono, // pasamos el bono existente para editar
            ),
      ),
    ).then((_) => _recargar());
  }

  Widget _buildBonoCard(BonoModel bono) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del bono
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.indigo[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bono.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${bono.moneda} • ${bono.tipoTasa}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información del bono
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Valor Nominal',
                      _formatCurrency(bono.valorNominal, bono.moneda),
                      Icons.monetization_on,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Tasa de Interés',
                      '${bono.tasaInteres.toStringAsFixed(2)}%',
                      Icons.percent,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Plazo',
                      '${bono.plazo} años',
                      Icons.schedule,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Frecuencia',
                      bono.frecuenciaPago,
                      Icons.repeat,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _editarBono(bono),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmarEliminacion(bono.id!),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo[600], size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  String _formatCurrency(double amount, String currency) {
    final symbol = currency == 'USD' ? '\$' : 'S/.';
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[50]!, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Card(
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
                      const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mis Bonos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gestiona y edita tus bonos creados',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _recargar,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Actualizar lista',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lista de bonos
            Expanded(
              child: FutureBuilder<List<BonoModel>>(
                future: _bonosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando bonos...'),
                        ],
                      ),
                    );
                  }

                  final bonos = snapshot.data ?? [];

                  if (bonos.isEmpty) {
                    return Center(
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
                              Icons.account_balance_wallet,
                              size: 64,
                              color: Colors.indigo[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No hay bonos registrados',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea tu primer bono desde la pestaña "Crear Bono"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bonos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final bono = bonos[index];
                      return _buildBonoCard(bono);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
