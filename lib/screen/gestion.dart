import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/manageadelanto_screen.dart';
import 'package:familiahuecasfrontend/screen/manageapunte_screen.dart';
import 'package:familiahuecasfrontend/screen/totaladelanto_screen.dart';
import 'package:familiahuecasfrontend/screen/veranticipos_screen.dart';
import 'package:familiahuecasfrontend/screen/verapuntes_screen.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import '../apirest/api_service.dart';

class GestionScreen extends StatelessWidget {
  GestionScreen({super.key});

  final List<_GestionItem> items = [
    _GestionItem('Totales', Icons.account_balance_wallet, Colors.lightBlueAccent, TotalAdelantoScreen()),
    _GestionItem('Ver Apuntes', Icons.book, Colors.lightGreenAccent, VerApuntesScreen()),
    _GestionItem('Mis Apuntes', Icons.assignment, Colors.amberAccent, null, requiresUser: true),
    _GestionItem('Crear Apunte', Icons.create, Colors.deepPurpleAccent.shade100, ManageApunteScreen()),
    _GestionItem('Poner Anticipo', Icons.add_circle, Colors.pinkAccent.shade100, ManageAdelantoScreen()),
    _GestionItem('Listar Anticipos', Icons.view_list, Colors.cyanAccent, VerAnticiposScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(title: 'Gestión'),
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

  Widget _buildItem(BuildContext context, _GestionItem item) {
    return InkWell(
      onTap: () async {
        if (item.requiresUser) {
          final user = await ApiService().getUser();
          if (user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VerApuntesScreen(usuario: user.name!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo obtener el usuario logado')),
            );
          }
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => item.screen!));
        }
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

class _GestionItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? screen;
  final bool requiresUser;

  _GestionItem(this.title, this.icon, this.color, this.screen, {this.requiresUser = false});
}
