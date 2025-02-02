import 'dart:convert';

import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../model/ubicacion.dart';
import 'search_ubicacion_screen.dart';
import 'package:share_plus/share_plus.dart';

class VerUbicacionesScreen extends StatefulWidget {
  @override
  _VerUbicacionesScreenState createState() => _VerUbicacionesScreenState();
}

class _VerUbicacionesScreenState extends State<VerUbicacionesScreen> {
  List<Ubicacion> ubicaciones = [];
  bool isLoading = false;
  int currentPage = 0;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUbicaciones();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchUbicaciones();
      }
    });
  }

  Future<void> _fetchUbicaciones() async {
    setState(() => isLoading = true);
    try {
      List<Ubicacion> fetchedData =
      await ApiService().getUbicacionesPaginated(currentPage, pageSize);
      setState(() {
        ubicaciones.addAll(fetchedData);
        currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ubicaciones: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteUbicacion(int id) async {
    try {
      await ApiService().deleteUbicacion(id);
      setState(() {
        ubicaciones.removeWhere((ubicacion) => ubicacion.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ubicación eliminada con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la ubicación: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta ubicación?'),
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
                _deleteUbicacion(id); // Llama al método de eliminación
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToUbicacionDetails(Ubicacion ubicacion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchUbicacionScreen(ubicacion: ubicacion),
      ),
    );
  }

  Widget _buildUbicacionCard(Ubicacion ubicacion) {
    return GestureDetector(
      onTap: () => _navigateToUbicacionDetails(ubicacion),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Card(
            color: Colors.white,
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ubicacion.foto != null && ubicacion.foto!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.memory(
                              base64Decode(ubicacion.foto!),
                              fit: BoxFit.cover,
                              height: 150,
                              width: double.infinity,
                            ),
                          ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.place, color: Colors.blue, size: 24),
                            SizedBox(width: 8),
                            Text(
                              ubicacion.nombre ?? 'Desconocido',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ubicacion.ubicacion ?? 'No disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.blue),
                        onPressed: () => _compartirUbicacion(ubicacion),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(ubicacion.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _compartirUbicacion(Ubicacion ubicacion) {
    String mensaje = '📍 *Ubicación*: ${ubicacion.nombre ?? 'Desconocida'}\n'
        '📌 *Dirección*: ${ubicacion.ubicacion ?? 'No disponible'}\n\n'
        '🌍 Ver en Google Maps: https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(ubicacion.ubicacion ?? '')}';

    Share.share(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Ubicaciones')),
      body: isLoading && ubicaciones.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: ubicaciones.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == ubicaciones.length) {
            return Center(child: CircularProgressIndicator());
          }
          return _buildUbicacionCard(ubicaciones[index]);
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
