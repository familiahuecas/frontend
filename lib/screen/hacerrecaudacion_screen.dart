import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/apirest/api_service.dart';

import '../model/recaudacionrequest.dart';
import '../model/recaudacionresponse.dart';

class HacerRecaudacionScreen extends StatefulWidget {
  @override
  _HacerRecaudacionScreenState createState() => _HacerRecaudacionScreenState();
}

class _HacerRecaudacionScreenState extends State<HacerRecaudacionScreen> {
  final TextEditingController entradaM1Controller = TextEditingController();
  final TextEditingController salidaM1Controller = TextEditingController();
  final TextEditingController entradaM2Controller = TextEditingController();
  final TextEditingController salidaM2Controller = TextEditingController();

  final ApiService apiService = ApiService();

  @override
  void dispose() {
    entradaM1Controller.dispose();
    salidaM1Controller.dispose();
    entradaM2Controller.dispose();
    salidaM2Controller.dispose();
    super.dispose();
  }

  void _onAceptarPressed() async {
    // Validar que ningún campo esté vacío
    if (entradaM1Controller.text.isEmpty ||
        salidaM1Controller.text.isEmpty ||
        entradaM2Controller.text.isEmpty ||
        salidaM2Controller.text.isEmpty) {
      _showErrorDialog('Por favor, rellena todos los campos antes de continuar.');
      return;
    }

    // Validar que todos los campos sean numéricos
    if (int.tryParse(entradaM1Controller.text) == null ||
        int.tryParse(salidaM1Controller.text) == null ||
        int.tryParse(entradaM2Controller.text) == null ||
        int.tryParse(salidaM2Controller.text) == null) {
      _showErrorDialog('Por favor, ingresa solo valores numéricos en los campos.');
      return;
    }

    try {
      // Crear RecaudacionRequest con los datos de los inputs
      Recaudacionrequest request = Recaudacionrequest(
        bar: "lucy",
        entradaM1: int.parse(entradaM1Controller.text),
        salidaM1: int.parse(salidaM1Controller.text),
        entradaM2: int.parse(entradaM2Controller.text),
        salidaM2: int.parse(salidaM2Controller.text),
      );

      // Llamar al servicio para obtener los totales
      Recaudacionresponse response = await apiService.calculateRec(request);

      // Mostrar el diálogo con los resultados
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Resultados de Recaudación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detalles de M1:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Entrada M1: ${response.entradaM1}'),
                Text('Salida M1: ${response.salidaM1}'),
                Text('Última Entrada M1: ${response.lastEntradaM1}'),
                Text('Última Salida M1: ${response.lastSalidaM1}'),
                SizedBox(height: 16),
                Text('Detalles de M2:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Entrada M2: ${response.entradaM2}'),
                Text('Salida M2: ${response.salidaM2}'),
                Text('Última Entrada M2: ${response.lastEntradaM2}'),
                Text('Última Salida M2: ${response.lastSalidaM2}'),
                SizedBox(height: 16),
                Text('Resultados Totales:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Total: ${response.total?.toStringAsFixed(2)} €'),
                Text('Total por Cada Uno: ${response.totalCadaUno?.toStringAsFixed(2)} €'),
                Text('Total M1: ${(response.totalm1! * 0.2)?.toStringAsFixed(2)} €'),
                Text('Total M2: ${(response.totalm2! * 0.2)?.toStringAsFixed(2)} €'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );

      // Llamar al servicio para guardar los datos automáticamente después de mostrar el diálogo
      await apiService.guardarRecaudacion(request);
      print("Recaudación guardada con éxito");

    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Recaudación'), // Usa CommonHeader
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20),
            // Encabezado para Unidesa
            Text(
              'Unidesa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            _buildInputField(
              controller: entradaM1Controller,
              label: 'Entrada M1',
              icon: Icons.input,
            ),
            _buildInputField(
              controller: salidaM1Controller,
              label: 'Salida M1',
              icon: Icons.output,
            ),
            SizedBox(height: 20),
            // Encabezado para Franco
            Text(
              'Franco',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            _buildInputField(
              controller: entradaM2Controller,
              label: 'Entrada M2',
              icon: Icons.input,
            ),
            _buildInputField(
              controller: salidaM2Controller,
              label: 'Salida M2',
              icon: Icons.output,
            ),
            SizedBox(height: 30),
            Center(
              child: TextButton(
                onPressed: _onAceptarPressed,
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
                    Icon(Icons.check_circle, color: Colors.blue[900]!, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Aceptar',
                      style: TextStyle(
                        color: Colors.blue[900]!,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              setState(() {
                controller.clear();
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
