import 'package:familiahuecasfrontend/screen/ubicacion.dart';
import 'package:familiahuecasfrontend/screen/user.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';

import 'documentos.dart';
import 'gestion.dart';
import 'maquinas.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: 'Home',
        showBackButton: false, // No muestra la flecha de volver
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Saludo al usuario
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildMenuButton(
                        title: 'Usuarios',
                        icon: Icons.person,
                        backgroundColor: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UsuariosScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildMenuButton(
                        title: 'Gestión',
                        icon: Icons.settings,
                        backgroundColor: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GestionScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildMenuButton(
                        title: 'Máquinas',
                        icon: Icons.computer,
                        backgroundColor: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MaquinasScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildMenuButton(
                        title: 'Documentos',
                        icon: Icons.folder,
                        backgroundColor: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DocumentosScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildMenuButton(
                        title: 'Ubicaciones',
                        icon: Icons.map,
                        backgroundColor: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UbicacionScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(double.infinity, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
