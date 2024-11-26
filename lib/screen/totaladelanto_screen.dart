import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../model/usuarioconapuntes.dart';

class TotalAdelantoScreen extends StatefulWidget {
  @override
  _TotalAdelantoScreenState createState() => _TotalAdelantoScreenState();
}

class _TotalAdelantoScreenState extends State<TotalAdelantoScreen> {
  List<UsuarioConApuntes> usuariosConApuntes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsuariosConApuntes();
  }

  Future<void> _fetchUsuariosConApuntes() async {
    setState(() => isLoading = true);
    try {
      final List<UsuarioConApuntes> fetchedData = await ApiService().getUsuariosConApuntes();
      setState(() {
        usuariosConApuntes = fetchedData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildUsuarioCard(UsuarioConApuntes usuario) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600, // Máximo ancho para las tarjetas en la web
        ),
        child: Card(
          color: Colors.white,
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.brown, size: 28),
                    SizedBox(width: 8),
                    Text(
                      usuario.nombre.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountColumn(
                      title: 'Asignada',
                      amount: usuario.cantidadAsignada,
                      color: Colors.blue, // Siempre azul
                      icon: Icons.attach_money,
                    ),
                    _buildAmountColumn(
                      title: 'Restante',
                      amount: usuario.cantidadRestante,
                      color: Colors.red, // Por defecto rojo, pero dinámico con `isRestante`
                      icon: Icons.money_off,
                      isRestante: true, // Aplicar reglas dinámicas
                    ),
                  ],
                ),

                Divider(height: 24, thickness: 1, color: Colors.grey[300]),
                Row(
                  children: [
                    Icon(Icons.note, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Número de Apuntes: ${usuario.numeroDeApuntes}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountColumn({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    bool isRestante = false, // Indicamos si es la columna de "Restante"
  }) {
    // Calculamos el color dinámico si es "Restante"
    Color dynamicColor = color;
    if (isRestante) {
      if (amount < 0) {
        dynamicColor = Colors.amberAccent; // Negativo
      } else if (amount < 2000) {
        dynamicColor = Colors.green; // Menor a 2000
      } else {
        dynamicColor = Colors.red; // Mayor a 2000
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: dynamicColor, size: 20),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dynamicColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '${amount.toStringAsFixed(2)}€',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: dynamicColor,
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Gestión-Totales'),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : usuariosConApuntes.isEmpty
          ? Center(child: Text('No hay datos disponibles'))
          : ListView.builder(
        itemCount: usuariosConApuntes.length,
        itemBuilder: (context, index) {
          final usuario = usuariosConApuntes[index];
          return _buildUsuarioCard(usuario);
        },
      ),
    );
  }
}
