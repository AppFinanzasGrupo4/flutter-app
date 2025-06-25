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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<BonoModel>>(
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
              final bono = bonos[index];
              return ListTile(
                title: Text(bono.nombre),
                subtitle: Text('${bono.moneda} - ${bono.tipoTasa}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarBono(bono),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmarEliminacion(bono.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
