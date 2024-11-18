import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Usuarios'), // Usa CommonHeader
      body: Center(
        child: Text('Pantalla de Usuarios'),
      ),
    );
  }
}
