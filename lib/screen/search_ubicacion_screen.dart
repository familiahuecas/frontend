import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../apirest/api_service.dart';
import '../model/ubicacion.dart';

class SearchUbicacionScreen extends StatefulWidget {
  final Ubicacion? ubicacion;

  SearchUbicacionScreen({this.ubicacion});

  @override
  _SearchUbicacionScreenState createState() => _SearchUbicacionScreenState();
}

class _SearchUbicacionScreenState extends State<SearchUbicacionScreen> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(0.0, 0.0); // Posición inicial
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeLocation();
  }

  void _initializeLocation() {
    if (widget.ubicacion != null) {
      try {
        // Extraer coordenadas desde el campo ubicacion
        final coords = widget.ubicacion!.ubicacion.split(',');
        final double latitude = double.parse(coords[0]);
        final double longitude = double.parse(coords[1]);

        setState(() {
          _currentLocation = LatLng(latitude, longitude);
        });
      } catch (e) {
        _showErrorDialog('Error al procesar la ubicación: $e');
      }
    }
  }

  Future<void> _buscarUbicacion() async {
    String nombre = _searchController.text;

    if (nombre.isEmpty) {
      _showErrorDialog('Por favor, ingresa un nombre para buscar.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Llamada al servicio real para buscar la ubicación por nombre
      Ubicacion ubicacion = await ApiService().getUbicacionByNombre(nombre);

      // Extraer coordenadas desde el campo ubicacion
      final coords = ubicacion.ubicacion.split(',');
      final double latitude = double.parse(coords[0]);
      final double longitude = double.parse(coords[1]);

      setState(() {
        _currentLocation = LatLng(latitude, longitude);
      });

      _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
    } catch (e) {
      _showErrorDialog('Error al buscar la ubicación: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _abrirEnGoogleMaps() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${_currentLocation.latitude},${_currentLocation.longitude}&travelmode=driving';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      _showErrorDialog('No se pudo abrir Google Maps.');
    }
  }

  void _showErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Detalle de Ubicación'),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('selectedLocation'),
                  position: _currentLocation,
                ),
              },
            ),
          ),
          if (widget.ubicacion == null) ...[
            // Campo de búsqueda visible solo si no se pasa una ubicación
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Ubicación',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _buscarUbicacion,
                    child: Text('Buscar Ubicación'),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _abrirEnGoogleMaps,
              child: Text('Abrir en Google Maps'),
            ),
          ),
        ],
      ),
    );
  }
}
