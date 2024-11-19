import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/model/numeracion.dart';
import '../apirest/api_service.dart';

class NumeracionesScreen extends StatefulWidget {
  @override
  _NumeracionesScreenState createState() => _NumeracionesScreenState();
}

class _NumeracionesScreenState extends State<NumeracionesScreen> {
  List<Numeracion> numeraciones = [];
  int currentPage = 0;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNumeraciones();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchNumeraciones();
      }
    });
  }

  Future<void> _fetchNumeraciones() async {
    setState(() => isLoading = true);
    final numeracionPage =
    await ApiService().getNumeraciones(currentPage, 10); // Ajusta el tamaño de la página si es necesario
    setState(() {
      numeraciones.addAll(numeracionPage.content);
      currentPage++;
      isLoading = false;
    });
  }

  Future<void> _deleteNumeracion(int id) async {
    await ApiService().deleteNumeracion(id); // Llama al método de eliminación en tu ApiService
    setState(() {
      numeraciones.removeWhere((numeracion) => numeracion.id == id);
    });
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta numeración?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteNumeracion(id); // Llama al método de eliminación
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Numeraciones'),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: numeraciones.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == numeraciones.length) {
            return Center(child: CircularProgressIndicator());
          }
          final numeracion = numeraciones[index];
          return Card(
            color: Colors.blueGrey[50],
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Alineación superior
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bar: ${numeracion.bar}, Fecha: ${numeracion.fecha}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Entrada M1: ${numeracion.entrada_m1}, Salida M1: ${numeracion.salida_m1}\n'
                              'Entrada M2: ${numeracion.entrada_m2}, Salida M2: ${numeracion.salida_m2}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(numeracion.id),
                    alignment: Alignment.topRight, // Alineación en la parte superior derecha
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
