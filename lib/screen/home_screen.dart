import 'package:familiahuecasfrontend/screen/user.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../model/user.dart';
import 'documentos.dart';
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
  User? currentUser;
  bool _isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await apiService.getUser();
      setState(() {
        currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

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
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : currentUser == null
              ? Center(child: Text('Error al cargar la información del usuario'))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Saludo al usuario fuera de la columna de los botones
              Text(
                'Bienvenido, ${currentUser!.name}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 24), // Espacio entre el saludo y los botones
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Botón "Usuarios"
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UsuariosScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(0xFFFFB74D), width: 1.5), // Naranja pastel
                          ),
                          elevation: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: Color(0xFFFFB74D), size: 32), // Naranja pastel
                            SizedBox(height: 8),
                            Text(
                              'Usuarios',
                              style: TextStyle(
                                color: Color(0xFFFFB74D), // Naranja pastel
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botón "Gestión"
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GestionScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(0xFFA5D6A7), width: 1.5), // Verde pastel
                          ),
                          elevation: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings, color: Color(0xFFA5D6A7), size: 32), // Verde pastel
                            SizedBox(height: 8),
                            Text(
                              'Gestión',
                              style: TextStyle(
                                color: Color(0xFFA5D6A7), // Verde pastel
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botón "Máquinas"
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MaquinasScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(0xFF81D4FA), width: 1.5), // Azul pastel
                          ),
                          elevation: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.computer, color: Color(0xFF81D4FA), size: 32), // Azul pastel
                            SizedBox(height: 8),
                            Text(
                              'Máquinas',
                              style: TextStyle(
                                color: Color(0xFF81D4FA), // Azul pastel
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botón "Documentos"
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DocumentosScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(0xFFCE93D8), width: 1.5), // Morado pastel
                          ),
                          elevation: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder, color: Color(0xFFCE93D8), size: 32), // Morado pastel
                            SizedBox(height: 8),
                            Text(
                              'Documentos',
                              style: TextStyle(
                                color: Color(0xFFCE93D8), // Morado pastel
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
}
