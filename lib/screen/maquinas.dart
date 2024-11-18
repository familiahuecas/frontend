import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

import 'numeraciones.dart';



class MaquinasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Máquinas'), // Usa CommonHeader
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showMenuDialog(context);
                },
                icon: Icon(Icons.menu, color: Colors.white),
                label: Text('Menú', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Pantalla de Máquinas'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Menú de Máquinas'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // Lógica para "Hacer recaudación"
              },
              child: Text('Hacer recaudación'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // Lógica para "Histórico de recaudaciones"
              },
              child: Text('Histórico de recaudaciones'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NumeracionesScreen()),
                );
              },
              child: Text('Numeraciones'),
            ),
          ],
        );
      },
    );
  }

}
