import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../model/usuarioconadelanto.dart';
import 'widget/common_header.dart';

class VerAnticiposScreen extends StatefulWidget {
  @override
  _VerAnticiposScreenState createState() => _VerAnticiposScreenState();
}

class _VerAnticiposScreenState extends State<VerAnticiposScreen> {
  List<UsuarioConAdelanto> anticipos = [];
  bool isLoading = false;
  int currentPage = 0;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAnticipos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchAnticipos();
      }
    });
  }

  Future<void> _fetchAnticipos() async {
    setState(() => isLoading = true);
    try {
      final fetchedData = await ApiService().getAnticiposPaginated(currentPage, pageSize);

      setState(() {
        if (currentPage == 0) {
          anticipos = fetchedData;
        } else {
          anticipos.addAll(fetchedData);
        }
        currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar anticipos: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildAnticipoCard(UsuarioConAdelanto anticipo) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: Card(
          color: Colors.white,
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text(
       //                'Sin nombre',
                     anticipo.name?.toUpperCase() ?? 'Sin nombre',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  anticipo.descripcion,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: Colors.grey[300]),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailColumn(
                      title: 'Cantidad',
                      value: '${anticipo.cantidadSolicitada.toStringAsFixed(2)}€',
                      icon: Icons.euro,
                      color: Colors.green,
                    ),
                    _buildDetailColumn(
                      title: 'Fecha',
                      value: anticipo.fecha.split('T').first,
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Listado de Anticipos'),
      body: isLoading && anticipos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: anticipos.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == anticipos.length) {
            return Center(child: CircularProgressIndicator());
          }
          return _buildAnticipoCard(anticipos[index]);
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
