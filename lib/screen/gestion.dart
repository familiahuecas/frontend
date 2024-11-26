import 'package:familiahuecasfrontend/screen/manageadelanto_screen.dart';
import 'package:familiahuecasfrontend/screen/manageapunte_screen.dart';
import 'package:familiahuecasfrontend/screen/totaladelanto_screen.dart';
import 'package:familiahuecasfrontend/screen/verapuntes_screen.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

import '../apirest/api_service.dart';

class GestionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Gestión'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón "Ver Total Adelanto"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TotalAdelantoScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.green, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.green, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Totales',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Botón "Ver Apuntes"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerApuntesScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, color: Colors.blue, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Ver Apuntes',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Botón "Mis Apuntes"
                TextButton(
                  onPressed: () async {
                    // Obtener el usuario logado
                    final user = await ApiService().getUser();
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerApuntesScreen(usuario: user!.name!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No se pudo obtener el usuario logado')),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.purple, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment, color: Colors.purple, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Mis Apuntes',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Botón "Crear Apunte"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageApunteScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.orange, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.create, color: Colors.orange, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Crear Apunte',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Botón "Crear Apunte"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageAdelantoScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.indigo, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.create, color: Colors.indigo, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Poner anticipo',
                        style: TextStyle(
                          color: Colors.indigo,
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
      ),
    );
  }
}
