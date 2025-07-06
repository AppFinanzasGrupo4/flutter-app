import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/core/services/session_service.dart';
import 'package:flutter_finanzasapp/presentation/screens/config_screen.dart';
import 'package:flutter_finanzasapp/presentation/screens/crear_bono_screen.dart';
import 'dashboard_screen.dart';
import 'ver_bonos_screen.dart';

class HomeEmisorScreen extends StatefulWidget {
  const HomeEmisorScreen({super.key});

  @override
  State<HomeEmisorScreen> createState() => _HomeEmisorScreenState();
}

class _HomeEmisorScreenState extends State<HomeEmisorScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const CrearBonoScreen(),
      const VerBonosScreen(),
      ConfigScreen(onSave: () {}), // Reutilizamos la misma pantalla
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Emisor'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // Mostrar diálogo de confirmación
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text(
                      '¿Estás seguro de que quieres cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cerrar diálogo
                          // Cerrar sesión en SessionService
                          SessionService().logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', // Ruta del login
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('Cerrar Sesión'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Mostrar mensaje de bienvenida solo en la pestaña de Inicio (índice 0)
          if (_currentIndex == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                'Bienvenido, ${SessionService().currentUser?.nombre ?? 'Emisor'}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Crear Bono',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Ver Bonos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
