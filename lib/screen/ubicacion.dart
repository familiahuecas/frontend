import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/map_screen.dart';
import 'package:familiahuecasfrontend/screen/search_ubicacion_screen.dart';
import 'package:familiahuecasfrontend/screen/listubicaciones_screen.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

class UbicacionScreen extends StatelessWidget {
  UbicacionScreen({super.key});

  final List<_UbicacionItem> items = [
    _UbicacionItem('Guardar ubicación', Icons.map, Colors.lightGreenAccent, MapScreen()),
    _UbicacionItem('Buscar por nombre', Icons.search, Colors.amberAccent.shade100, SearchUbicacionScreen()),
    _UbicacionItem('Listado de ubicaciones', Icons.location_on_outlined, Colors.cyanAccent.shade100, VerUbicacionesScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(title: 'Ubicación'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: items.map((item) => _buildItem(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _UbicacionItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => item.screen));
      },
      borderRadius: BorderRadius.circular(80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: item.color.withOpacity(0.7),
            shape: const CircleBorder(),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Icon(item.icon, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _UbicacionItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  _UbicacionItem(this.title, this.icon, this.color, this.screen);
}
