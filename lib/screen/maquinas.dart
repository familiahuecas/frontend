import 'package:familiahuecasfrontend/screen/recaudaciones.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

import 'hacerrecaudacion_screen.dart';
import 'numeraciones.dart';

class MaquinasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Máquinas'), // Usa CommonHeader
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Align(
          alignment: Alignment.topCenter, // Centra el contenido horizontalmente
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón "Hacer Recaudación"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HacerRecaudacionScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue[900]!, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on, color: Colors.blue[900]!, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Hacer Recaudación',
                        style: TextStyle(
                          color: Colors.blue[900]!,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Botón "Histórico de Recaudaciones"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecaudacionesScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue[900]!, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: Colors.blue[900]!, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Histórico de Recaudaciones',
                        style: TextStyle(
                          color: Colors.blue[900]!,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Botón "Numeraciones"
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NumeracionesScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue[900]!, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_list_numbered, color: Colors.blue[900]!, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Numeraciones',
                        style: TextStyle(
                          color: Colors.blue[900]!,
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
