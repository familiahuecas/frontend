import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/hacerrecaudacion_screen.dart';
import 'package:familiahuecasfrontend/screen/numeraciones.dart';
import 'package:familiahuecasfrontend/screen/recaudaciones.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

class MaquinasScreen extends StatelessWidget {
  MaquinasScreen({super.key});

  final List<_MaquinaItem> items = [
    _MaquinaItem('Hacer Recaudación', Icons.monetization_on, Colors.lightGreenAccent, HacerRecaudacionScreen()),
    _MaquinaItem('Histórico de Recaudaciones', Icons.history, Colors.purpleAccent.shade100, RecaudacionesScreen()),
    _MaquinaItem('Numeraciones', Icons.format_list_numbered, Colors.orangeAccent.shade100, NumeracionesScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(title: 'Máquinas'),
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

  Widget _buildItem(BuildContext context, _MaquinaItem item) {
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

class _MaquinaItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  _MaquinaItem(this.title, this.icon, this.color, this.screen);
}
