import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/presentation/screens/home_emisor.dart';
import 'package:flutter_finanzasapp/presentation/screens/home_inversor.dart';
import '../../data/models/user_model.dart';


class ConfiguracionScreen extends StatefulWidget {
  final UserModel usuario;

  const ConfiguracionScreen({super.key, required this.usuario});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String moneda = 'PEN';
  String tipoTasa = 'Nominal';
  String frecuencia = 'Mensual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color.fromRGBO(62, 62, 240, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Seleccione los parámetros iniciales:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              value: moneda,
              decoration: const InputDecoration(labelText: 'Moneda'),
              items: const [
                DropdownMenuItem(value: 'PEN', child: Text('Soles (PEN)')),
                DropdownMenuItem(value: 'USD', child: Text('Dólares (USD)')),
              ],
              onChanged: (value) => setState(() => moneda = value!),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: tipoTasa,
              decoration: const InputDecoration(labelText: 'Tipo de Tasa de Interés'),
              items: const [
                DropdownMenuItem(value: 'Nominal', child: Text('Nominal')),
                DropdownMenuItem(value: 'Efectiva', child: Text('Efectiva')),
              ],
              onChanged: (value) => setState(() => tipoTasa = value!),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: frecuencia,
              decoration: const InputDecoration(labelText: 'Frecuencia de Capitalización'),
              items: const [
                DropdownMenuItem(value: 'Mensual', child: Text('Mensual')),
                DropdownMenuItem(value: 'Trimestral', child: Text('Trimestral')),
                DropdownMenuItem(value: 'Semestral', child: Text('Semestral')),
                DropdownMenuItem(value: 'Anual', child: Text('Anual')),
              ],
              onChanged: (value) => setState(() => frecuencia = value!),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Aquí puedes guardar la configuración y navegar a la siguiente pantalla
                // Por ejemplo, podrías usar Navigator.push para ir a HomeInversorScreen o HomeEmisorScreen
                if (widget.usuario.rol == 'inversor') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeInversorScreen(usuario: widget.usuario),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeEmisorScreen(usuario: widget.usuario),
                    ),
                  );
                }
              },
              child: const Text('Guardar y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
