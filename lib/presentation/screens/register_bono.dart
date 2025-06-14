import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_datasource.dart';


class RegisterBonoScreen extends StatefulWidget {
  final bool embedded;
  const RegisterBonoScreen({super.key, this.embedded = false});

  @override
  State<RegisterBonoScreen> createState() => _RegisterBonoScreenState();
}

class _RegisterBonoScreenState extends State<RegisterBonoScreen> {
  final _formKey = GlobalKey<FormState>();

  final valorController = TextEditingController();
  final tasaController = TextEditingController();
  final plazoController = TextEditingController();
  final fechaEmisionController = TextEditingController();
  final fechaVencimientoController = TextEditingController();
  String frecuenciaPago = 'Mensual';

  @override
  void dispose() {
    // Siempre liberar controladores para evitar memory leaks
    valorController.dispose();
    tasaController.dispose();
    plazoController.dispose();
    fechaEmisionController.dispose();
    fechaVencimientoController.dispose();
    super.dispose();
  }

void _calcular() async {
  if (_formKey.currentState!.validate()) {
    final bono = BonoModel(
      valorNominal: double.parse(valorController.text),
      tasa: double.parse(tasaController.text),
      frecuenciaPago: frecuenciaPago,
      plazoAnios: int.parse(plazoController.text),
      fechaEmision: fechaEmisionController.text,
      fechaVencimiento: fechaVencimientoController.text,
    );

    await BonoDataSource.db.insertarBono(bono); // <- Guarda en SQLite

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bono registrado/calculado')),
    );

    if (!widget.embedded) {
      Navigator.pop(context); // Volver a Home si no está embebido
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final form = Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Valor nominal', valorController),
            _buildTextField('Tasa', tasaController),
            _buildDropdownField((value) => setState(() => frecuenciaPago = value!)),
            _buildTextField('Plazo en años', plazoController),
            _buildTextField('Fecha de emisión', fechaEmisionController),
            _buildTextField('Fecha de vencimiento', fechaVencimientoController),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _calcular, child: const Text('Calcular')),
            OutlinedButton(onPressed: () {}, child: const Text('Editar bono')),
            OutlinedButton(onPressed: () {}, child: const Text('Eliminar bono')),
          ],
        ),
      ),
    );

    return widget.embedded
        ? form
        : Scaffold(
            appBar: AppBar(title: const Text('Registrar bono')),
            body: ListView(children: [form]),
          );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _buildDropdownField(ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: frecuenciaPago,
        decoration: const InputDecoration(labelText: 'Frecuencia de pago', border: OutlineInputBorder()),
        items: ['Mensual', 'Trimestral', 'Anual']
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
