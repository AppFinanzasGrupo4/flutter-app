import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/datasources/user_datasource.dart';
import 'package:flutter_finanzasapp/data/models/user_model.dart';
import 'package:flutter_finanzasapp/presentation/widgets/input_decoration.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController claveCtrl = TextEditingController();
  String _rolSeleccionado = 'emisor';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            _rectanguloAzul(size),
            _iconoPersona(),
            _formularioRegistro(),
          ],
        ),
      ),
    );
  }

  Widget _rectanguloAzul(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromRGBO(62, 62, 240, 1),
          Color.fromRGBO(49, 119, 230, 1),
        ]),
      ),
    );
  }

  Widget _iconoPersona() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 100),
        child: const Icon(Icons.person_pin, color: Colors.white, size: 150),
      ),
    );
  }

  Widget _formularioRegistro() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 350),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, 5))
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text('Crear cuenta', style: TextStyle(fontFamily: 'Montserrat', fontSize: 30)),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: nombreCtrl,
                    decoration: InputDecorations.inputDecoration(
                      hintText: 'Nombre completo',
                      labelText: 'Nombre',
                      icon: Icons.person,
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: correoCtrl,
                    decoration: InputDecorations.inputDecoration(
                      hintText: 'ejemplo@email.com',
                      labelText: 'Correo electrónico',
                      icon: Icons.email,
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese un correo' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: claveCtrl,
                    obscureText: true,
                    decoration: InputDecorations.inputDecoration(
                      hintText: '********',
                      labelText: 'Contraseña',
                      icon: Icons.lock,
                    ),
                    validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: _rolSeleccionado,
                    decoration: const InputDecoration(labelText: 'Tipo de usuario'),
                    items: const [
                      DropdownMenuItem(value: 'emisor', child: Text('Emisor')),
                      DropdownMenuItem(value: 'inversor', child: Text('Inversor')),
                    ],
                    onChanged: (value) {
                      setState(() => _rolSeleccionado = value!);
                    },
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(62, 62, 240, 1),
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _registrarUsuario,
                    child: const Text('Registrar', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('¿Ya tienes cuenta? Inicia sesión'),
          ),
        ],
      ),
    );
  }

  void _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final nuevoUsuario = UserModel(
        nombre: nombreCtrl.text.trim(),
        correo: correoCtrl.text.trim(),
        clave: claveCtrl.text.trim(),
        rol: _rolSeleccionado,
      );

      await UserDataSource.db.insertarUsuario(nuevoUsuario);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente')),
      );

      Navigator.pop(context); // Regresa al login
    }
  }
}
