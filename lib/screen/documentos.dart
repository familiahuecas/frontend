import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'document_tree_screen_movil.dart';

class DocumentosScreen extends StatelessWidget {
  DocumentosScreen({super.key});

  final List<_DocumentItem> items = [
    _DocumentItem(
      'Gestionar Documentos',
      Icons.manage_accounts,
      Colors.indigoAccent.shade100,
      DocumentTreeScreenMobile(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(title: 'Gestión Documental'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          children: items.map((item) => _buildItem(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _DocumentItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => kIsWeb ? item.screen : item.screen),
        );
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

class _DocumentItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  _DocumentItem(this.title, this.icon, this.color, this.screen);
}
