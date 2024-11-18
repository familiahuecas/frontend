import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/model/numeracion.dart';
import '../apirest/api_service.dart';
import '../apirest/basicPagination.dart';

class NumeracionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Numeraciones'),
      body: BasicPagination(
        fetchItems: (page, size) async {
          // Llama al servicio y obtiene NumeracionPage
          final numeracionPage = await ApiService().getNumeraciones(page, size);
          // Devuelve la lista de Numeracion
          return numeracionPage.content;
        },
        itemBuilder: (context, numeracion) {
          return ListTile(
            title: Text( 'Bar: ${numeracion.bar}, Fecha: ${numeracion.fecha.toLocal()}'),
            subtitle: Text(

              'Entrada M1: ${numeracion.entrada_m1}, Salida M1: ${numeracion.salida_m1}'
                  'Entrada M2: ${numeracion.entrada_m2}, Salida M2: ${numeracion.salida_m2}\n'
                  ,
            ),
          );
        },
      ),
    );
  }
}
