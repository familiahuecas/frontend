import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/listusuarios_screen.dart';
import 'package:familiahuecasfrontend/screen/manageusuario_screen.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

class UsuariosScreen extends StatelessWidget {
  UsuariosScreen({super.key});

  final List<_UsuarioItem> items = [
    _UsuarioItem('Listado Usuarios', Icons.list, Colors.lightBlueAccent, ListUsuariosScreen()),
    _UsuarioItem('Crear Usuario', Icons.person_add, Colors.tealAccent, ManageUsuarioScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(title: 'Usuarios'),
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

  Widget _buildItem(BuildContext context, _UsuarioItem item) {
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

class _UsuarioItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  _UsuarioItem(this.title, this.icon, this.color, this.screen);
}
