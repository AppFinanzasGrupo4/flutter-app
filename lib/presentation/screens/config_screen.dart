import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/presentation/screens/home_emisor_screen.dart';
import '../../../../../core/constants/monedas.dart'; // lista de monedas

import '../../../../../core/constants/input_decoration.dart';

import '../../../domain/entities/config_entity.dart';
import '../../../data/repositories/config_repository_impl.dart';
import '../../../data/datasources/config_local_datasource.dart';

class ConfigScreen extends StatefulWidget {
  final VoidCallback onSave; // Callback para notificar al padre

  const ConfigScreen({super.key, required this.onSave});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String selectedMoneda = 'PEN';
  String selectedTipoTasa = 'Efectiva';
  String? selectedCapitalizacion;

  final capitalizaciones = [
    'Mensual',
    'Bimestral',
    'Trimestral',
    'Semestral',
    'Anual',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración Inicial')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: inputDecoration('Moneda'),
              value: selectedMoneda,
              items:
                  monedas
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
              onChanged: (value) => setState(() => selectedMoneda = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: inputDecoration('Tipo de Tasa'),
              value: selectedTipoTasa,
              items:
                  ['Efectiva', 'Nominal']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedTipoTasa = value!;
                  if (selectedTipoTasa == 'Efectiva') {
                    selectedCapitalizacion = null;
                  }
                });
              },
            ),
            if (selectedTipoTasa == 'Nominal') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: inputDecoration('Capitalización'),
                value: selectedCapitalizacion,
                items:
                    capitalizaciones
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged:
                    (value) => setState(() => selectedCapitalizacion = value),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                // aquí luego guardaremos en SQLite
                final config = ConfigEntity(
                  moneda: selectedMoneda,
                  tipoTasa: selectedTipoTasa,
                  capitalizacion:
                      selectedTipoTasa == 'Nominal'
                          ? selectedCapitalizacion
                          : null,
                );
                final repo = ConfigRepositoryImpl(ConfigLocalDatasource());
                await repo.saveConfig(config);

                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            HomeEmisorScreen(), // Cambia a tu pantalla principal
                  ),
                );
              },
              child: const Text('Guardar y Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
