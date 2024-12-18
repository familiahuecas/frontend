
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:familiahuecasfrontend/screen/widget/common_header.dart';

import 'document_tree_explorer_web.dart';
import 'document_tree_screen_web.dart';
import 'dart:html' as html;
//import 'document_tree_screen_movil.dart';


class DocumentosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Gestión Documental'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón "Subir Documentos"


                TextButton(
                 /* onPressed: () {
                    Navigator.push(
                      context,
                        MaterialPageRoute(
                          builder: (context) => kIsWeb
                              ? const DocumentTreeExplorerWeb()
                              : const DocumentTreeScreenWeb(),
                        )
                    );
                  },*/
                  onPressed: () {
                    final width = html.window.innerWidth;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => width! <= 768
                            ? const DocumentTreeScreenWeb() // Móvil (pantallas pequeñas)
                            : const DocumentTreeExplorerWeb(), // Escritorio (pantallas grandes)
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue[900]!, width: 1.5),
                    ),
                    elevation: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.manage_accounts, color: Colors.blue[900]!, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Gestionar Documentos',
                        style: TextStyle(
                          color: Colors.blue[900]!,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
