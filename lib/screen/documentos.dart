import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

class DocumentosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Documentos'), // Usa CommonHeader
      body: Center(
        child: Text('Pantalla de Documentos'),
      ),
    );
  }
}
