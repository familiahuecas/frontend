import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/model/recaudaciones.dart';
import '../apirest/api_service.dart';

class RecaudacionesScreen extends StatefulWidget {
  @override
  _RecaudacionesScreenState createState() => _RecaudacionesScreenState();
}

class _RecaudacionesScreenState extends State<RecaudacionesScreen> {
  List<Recaudaciones> recaudaciones = [];
  int currentPage = 0;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRecaudaciones();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchRecaudaciones();
      }
    });
  }

  Future<void> _fetchRecaudaciones() async {
    setState(() => isLoading = true);
    final recaudacionPage =
    await ApiService().getRecaudaciones(currentPage, 10); // Ajusta el tamaño de la página si es necesario
    setState(() {
      recaudaciones.addAll(recaudacionPage.content);
      currentPage++;
      isLoading = false;
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Recaudaciones'),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: recaudaciones.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == recaudaciones.length) {
            return Center(child: CircularProgressIndicator());
          }
          final recaudacion = recaudaciones[index];
          return Card(
            color: Colors.blueGrey[50],
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Alineación superior
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bar: ${recaudacion.bar}, Fecha: ${recaudacion.fecha}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Recaudación Total: ${recaudacion.recaudaciontotal}€\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              TextSpan(
                                text: 'Recaudación Parcial (50%): ${recaudacion.recaudacionparcial}€\n',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              TextSpan(
                                text: 'Máquina 1: ${recaudacion.maquina1}€, Máquina 2: ${recaudacion.maquina2}€',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
