import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(0.0, 0.0); // Posición inicial
  final TextEditingController _locationController = TextEditingController();
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

  void _saveLocation() {
    String description = _locationController.text;
    print("Ubicación guardada: $_currentLocation, Descripción: $description");
    // Aquí puedes guardar la ubicación en una base de datos o similar
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
                target: _currentLocation,
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onCameraMove: (position) =>
              _currentLocation = position.target,
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
