import 'dart:typed_data';
import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class PDFViewerWeb extends StatelessWidget {
  final Uint8List pdfData;

  PDFViewerWeb({Key? key, required this.pdfData}) : super(key: key) {
    // Registra la vista personalizada solo en Flutter Web
    platformViewRegistry.registerViewFactory(
      'pdf-viewer',
          (int viewId) {
        // Fuerza el tipo MIME a PDF
        final blob = html.Blob([pdfData], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Crea el iframe para mostrar el PDF
        final iframe = html.IFrameElement()
          ..src = url
          ..style.border = 'none' // Sin bordes
          ..style.height = '100%' // Altura completa
          ..style.width = '100%'; // Anchura completa

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity, // Altura completa
      width: double.infinity, // Anchura completa
      child: HtmlElementView(viewType: 'pdf-viewer'),
    );
  }
}
