import 'dart:convert';
import 'dart:io';

import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../apirest/api_service.dart';
import '../model/ubicacion.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(0.0, 0.0); // Posición inicial por defecto
  final TextEditingController _locationController = TextEditingController();
  File? _imageFile; // Archivo de la imagen seleccionada
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Solicita permisos al iniciar
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
    } else {
      setState(() {
        _locationPermissionGranted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permisos de ubicación no concedidos.'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Cargar la imagen seleccionada
      });
    }
  }

  String? _imageToBase64(File? imageFile) {
    if (imageFile == null) return null;

    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes); // Convertir imagen a Base64
  }

  void _saveLocation() {
    String nombre = _locationController.text;

    if (nombre.isEmpty) {
      _showErrorDialog('Por favor, ingresa un nombre para la ubicación.');
      return;
    }

    // Convertir la imagen a Base64 solo si está presente
    final fotoBase64 = _imageFile != null ? _imageToBase64(_imageFile) : null;

    final nuevaUbicacion = Ubicacion(
      id: 0,
      nombre: nombre,
      ubicacion: '${_currentLocation.latitude},${_currentLocation.longitude}',
      foto: fotoBase64, // Puede ser null si no hay imagen
    );

    print('Preparando para guardar ubicación: ${nuevaUbicacion.toJson()}');

    ApiService()
        .crearUbicacion(nuevaUbicacion)
        .then((_) {
      _showSuccessDialog('Ubicación guardada exitosamente.');
    }).catchError((error) {
      _showErrorDialog('Error al guardar la ubicación: $error');
    });
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

  void _showSuccessDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Éxito'),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(width: 16),
            Expanded(child: Text(mensaje)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              Navigator.pop(context, true); // Notifica que se guardó correctamente
            },
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Guardar Ubicación'),
      body: Column(
        children: [
          Expanded(
            child: _locationPermissionGranted
                ? GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: LatLng(40.416775, -3.703790), // Posición inicial (Madrid)
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onCameraMove: (position) {
                _currentLocation = position.target; // Actualiza la ubicación actual
              },
            )
                : Center(
              child: Text(
                'No se puede mostrar el mapa sin permisos de ubicación.',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Tomar Foto'),
                ),
                if (_imageFile != null) ...[
                  SizedBox(height: 10),
                  Image.file(
                    _imageFile!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ],
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveLocation,
                  child: Text('Guardar ubicación'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
