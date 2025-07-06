import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/bono_entity.dart';

class AnalisisBonoScreen extends StatelessWidget {
  final BonoEntity bono;
  final double cok;
  final Map<String, double> resultados;
  final double trea;

  const AnalisisBonoScreen({
    super.key,
    required this.bono,
    required this.cok,
    required this.resultados,
    required this.trea,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PE',
      symbol: bono.moneda == 'USD' ? '\$' : 'S/.',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis de ${bono.nombre}'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del bono
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
                          'Información del Bono',
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
                    _buildInfoRow(
                      'Valor Nominal',
                      currencyFormat.format(bono.valorNominal),
                    ),
                    _buildInfoRow(
                      'Tasa de Interés',
                      '${bono.tasaInteres.toStringAsFixed(2)}%',
                    ),
                    _buildInfoRow('Frecuencia de Pago', bono.frecuenciaPago),
                    _buildInfoRow('Plazo', '${bono.plazo} años'),
                    _buildInfoRow(
                      'COK para este Bono',
                      '${(cok * 100).toStringAsFixed(2)}%',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Métricas de riesgo
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
                        Icon(
                          Icons.analytics,
                          color: Colors.blue[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Métricas de Riesgo',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Duración
                    _buildMetricCard(
                      'Duración',
                      '${resultados['duracion']?.toStringAsFixed(2)} ${_getUnidadTiempo()}',
                      'Mide la sensibilidad del precio del bono ante cambios en las tasas de interés',
                      Icons.schedule,
                      Colors.orange,
                    ),

                    const SizedBox(height: 16),

                    // Duración Modificada
                    _buildMetricCard(
                      'Duración Modificada',
                      '${resultados['duracionModificada']?.toStringAsFixed(2)}',
                      'Aproxima el cambio porcentual en el precio por cada 1% de cambio en la tasa',
                      Icons.trending_down,
                      Colors.red,
                    ),

                    const SizedBox(height: 16),

                    // Convexidad
                    _buildMetricCard(
                      'Convexidad',
                      '${resultados['convexidad']?.toStringAsFixed(2)}',
                      'Mide la curvatura de la relación precio-rendimiento del bono',
                      Icons.show_chart,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rentabilidad
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
                          Icons.trending_up,
                          color: Colors.green[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Análisis de Rentabilidad',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildMetricCard(
                      'TREA',
                      '${(trea * 100).toStringAsFixed(2)}%',
                      'Tasa de Rentabilidad Efectiva Anual considerando la frecuencia de capitalización',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),

                    const SizedBox(height: 16),

                    _buildMetricCard(
                      'Precio Calculado',
                      currencyFormat.format(resultados['precio']),
                      'Valor presente del bono usando el COK como tasa de descuento',
                      Icons.attach_money,
                      Colors.amber,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Interpretación
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
                          Icons.lightbulb,
                          color: Colors.amber[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Interpretación',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInterpretationText(),
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
                  'Cerrar Análisis',
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
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlight ? 16 : 15,
              color: isHighlight ? Colors.indigo[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpretationText() {
    final duracion = resultados['duracion'] ?? 0;
    final convexidad = resultados['convexidad'] ?? 0;
    final duracionMod = resultados['duracionModificada'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInterpretationItem(
          '• COK efectivo ${(cok * 100).toStringAsFixed(2)}% ${_getUnidadTiempo()} fue convertido automáticamente según la frecuencia de pago del bono.',
        ),
        const SizedBox(height: 8),
        _buildInterpretationItem(
          '• Duración de ${duracion.toStringAsFixed(2)} ${_getUnidadTiempo()} significa que el bono es ${duracion > 5 ? 'sensible' : 'poco sensible'} a cambios en tasas.',
        ),
        const SizedBox(height: 8),
        _buildInterpretationItem(
          '• Por cada 1% de aumento en tasas, el precio disminuirá aproximadamente ${duracionMod.toStringAsFixed(2)}%.',
        ),
        const SizedBox(height: 8),
        _buildInterpretationItem(
          '• Convexidad de ${convexidad.toStringAsFixed(2)} indica ${convexidad > 50 ? 'alta' : 'baja'} curvatura precio-rendimiento.',
        ),
        const SizedBox(height: 8),
        _buildInterpretationItem(
          '• TREA de ${(trea * 100).toStringAsFixed(2)}% es la rentabilidad anual efectiva esperada.',
        ),
      ],
    );
  }

  String _getUnidadTiempo() {
    switch (bono.frecuenciaPago.toLowerCase()) {
      case 'mensual':
        return 'meses';
      case 'bimestral':
        return 'bimestres';
      case 'trimestral':
        return 'trimestres';
      case 'cuatrimestral':
        return 'cuatrimestres';
      case 'semestral':
        return 'semestres';
      case 'anual':
        return 'años';
      default:
        return 'períodos';
    }
  }

  Widget _buildInterpretationItem(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
    );
  }
}
