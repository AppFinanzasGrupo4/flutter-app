import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_datasource.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';


class HomeEmisorScreen extends StatelessWidget {
  final UserModel usuario;
  const HomeEmisorScreen({super.key, required this.usuario});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Bienvenido, ${usuario.nombre}')),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _buildResumen()),
                    // Quita el Scaffold de RegisterBonoScreen
                  ],
                )
              : ListView(
                  children: [
                    _buildResumen(),
                  ],
                ),
        );
      },
    ),
  );
}
Widget _buildResumen() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Resumen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      FutureBuilder<List<BonoModel>>(
        future: BonoDataSource.db.obtenerBonos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No hay bonos registrados');
          }

          return Column(
            children: snapshot.data!
                .map((bono) => Card(
                      child: ListTile(
                        title: Text('S/ ${bono.valorNominal} - ${bono.frecuenciaPago}'),
                        subtitle: Text('Tasa: ${bono.tasa} - Vence: ${bono.fechaVencimiento}'),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    ],
  );
}


  Widget _placeholderCard() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
