import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/data/datasources/user_datasource.dart';
import 'package:flutter_finanzasapp/presentation/screens/configuration.dart';
import 'package:flutter_finanzasapp/presentation/screens/register.dart';
import 'package:flutter_finanzasapp/presentation/widgets/input_decoration.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            _Background(size: size),
            _PersonIcon(),
            _LoginForm(emailCtrl: emailCtrl, passwordCtrl: passwordCtrl),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailCtrl,
    required this.passwordCtrl,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 350),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text('Iniciar sesión', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecorations.inputDecoration(
                          hintText: 'ejemplo@gmail.com',
                          labelText: 'Correo electrónico',
                          icon: Icons.alternate_email,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration: InputDecorations.inputDecoration(
                          hintText: '********',
                          labelText: 'Contraseña',
                          icon: Icons.lock,
                        ),
                      ),
                      const SizedBox(height: 30),
                      MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: const Color.fromRGBO(62, 62, 240, 1),
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        child: const Text('Ingresar', style: TextStyle(color: Colors.white, fontSize: 18)),
                        onPressed: () async {
                          final user = await UserDataSource.db.validarUsuario(
                            emailCtrl.text.trim(),
                            passwordCtrl.text.trim(),
                          );
                          if (!context.mounted) return; // Check if the context is still mounted
                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfiguracionScreen(usuario: user),
                              ),
                            );

                            // Aquí puedes manejar la navegación según el rol del usuario
                            // if (user.rol == 'emisor') {
                            //   Navigator.pushNamed(context, 'emisor_dashboard');
                            // } else if (user.rol == 'inversor') {
                            //   Navigator.pushNamed(context, 'inversor_dashboard');
                            // }
                          } else {
                            //mostrar alerta
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Usuario o contraseña incorrectos')),
                            );
                          }
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            child: const Text('Crear una nueva cuenta'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Register()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PersonIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 100),
        child: const Icon(Icons.person_pin, color: Colors.white, size: 150),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(62, 62, 240, 1),
            Color.fromRGBO(49, 119, 230, 1),
          ],
        ),
      ),
    );
  }
}
