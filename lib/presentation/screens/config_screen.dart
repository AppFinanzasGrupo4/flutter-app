import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/presentation/screens/home_emisor_screen.dart';
import 'package:flutter_finanzasapp/presentation/screens/login.dart'; // <-- Asegúrate de tener esta pantalla

import '../../../../../core/constants/monedas.dart'; // lista de monedas

import '../../../domain/entities/config_entity.dart';
import '../../../data/repositories/config_repository_impl.dart';
import '../../../data/datasources/config_local_datasource.dart';

class ConfigScreen extends StatefulWidget {
  final VoidCallback onSave;

  const ConfigScreen({super.key, required this.onSave});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String selectedMoneda = 'PEN';
  String selectedTipoTasa = 'Efectiva';
  String? selectedFrecuencia;

  final frecuencias = [
    'Mensual',
    'Bimestral',
    'Trimestral',
    'Cuatrimestral',
    'Semestral',
    'Anual',
  ];

  // Método para logout
  void _logout() {
    // Aquí puedes borrar datos de sesión, SharedPreferences, etc.
    // Por ahora solo navega a LoginScreen.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => Login()));
  }

  Widget _buildStyledDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Emisor'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                        const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Configuración Inicial',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Configure las preferencias para sus bonos',
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

                // Configuración Card
                Expanded(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.blue[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tune,
                                color: Colors.blue[700],
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Preferencias de Bonos',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Moneda
                          _buildStyledDropdown<String>(
                            value: selectedMoneda,
                            label: 'Moneda',
                            icon: Icons.attach_money,
                            items:
                                monedas
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (value) =>
                                    setState(() => selectedMoneda = value!),
                          ),

                          const SizedBox(height: 20),

                          // Tipo de Tasa
                          _buildStyledDropdown<String>(
                            value: selectedTipoTasa,
                            label: 'Tipo de Tasa',
                            icon: Icons.percent,
                            items:
                                ['Efectiva', 'Nominal']
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTipoTasa = value!;
                                if (selectedTipoTasa == 'Efectiva') {
                                  selectedFrecuencia = null;
                                }
                              });
                            },
                          ),

                          if (selectedTipoTasa == 'Nominal') ...[
                            const SizedBox(height: 20),
                            _buildStyledDropdown<String>(
                              value: selectedFrecuencia,
                              label: 'Capitalización',
                              icon: Icons.repeat,
                              items:
                                  frecuencias
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (value) => setState(
                                    () => selectedFrecuencia = value,
                                  ),
                            ),
                          ],

                          const Spacer(),

                          // Botón de Guardar
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green[500]!,
                                  Colors.green[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final config = ConfigEntity(
                                  moneda: selectedMoneda,
                                  tipoTasa: selectedTipoTasa,
                                  frecuenciaTasa: selectedFrecuencia,
                                  capitalizacion:
                                      selectedTipoTasa == 'Nominal'
                                          ? selectedFrecuencia
                                          : null,
                                );

                                final repo = ConfigRepositoryImpl(
                                  ConfigLocalDatasource(),
                                );
                                await repo.saveConfig(config);

                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeEmisorScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                'Guardar y Continuar',
                                style: TextStyle(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
