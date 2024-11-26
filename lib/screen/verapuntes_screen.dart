import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../model/conceptogastoadelanto.dart';
import 'manageapunte_screen.dart';

class VerApuntesScreen extends StatefulWidget {
  final String? usuario; // Parámetro para filtrar por usuario

  VerApuntesScreen({this.usuario});

  @override
  _VerApuntesScreenState createState() => _VerApuntesScreenState();
}

class _VerApuntesScreenState extends State<VerApuntesScreen> {
  List<ConceptoGastoAdelanto> conceptos = [];
  List<String> usuarios = [];
  String? usuarioSeleccionado;
  bool isLoading = false;
  int currentPage = 0;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    usuarioSeleccionado = widget.usuario; // Inicializar con el usuario recibido
    _fetchConceptos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchConceptos();
      }
    });
  }

  Future<void> _fetchConceptos() async {
    setState(() => isLoading = true);
    try {
      List<ConceptoGastoAdelanto> fetchedData;

      if (usuarioSeleccionado != null && usuarioSeleccionado!.isNotEmpty) {
        fetchedData = await ApiService().getConceptosGastoByUsuario(
            usuarioSeleccionado!, currentPage, pageSize);
      } else {
        fetchedData = await ApiService().getConceptosGastoPaginated(
            currentPage, pageSize);
      }

      final nuevosUsuarios =
      fetchedData.map((concepto) => concepto.usuario).toSet().toList();

      setState(() {
        if (currentPage == 0) {
          conceptos = fetchedData;
        } else {
          conceptos.addAll(fetchedData);
        }
        usuarios.addAll(
            nuevosUsuarios.where((u) => !usuarios.contains(u)));
        currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar conceptos: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteApunte(int id) async {
    try {
      await ApiService().deleteApunte(id);
      setState(() {
        conceptos.removeWhere((concepto) => concepto.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apunte eliminado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el apunte: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este apunte?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteApunte(id);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildConceptoCard(ConceptoGastoAdelanto concepto) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600, // Limita el ancho para pantallas grandes
        ),
        child: Card(
          color: Colors.white, // Fondo blanco para la tarjeta
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          concepto.usuario.toUpperCase(),
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
                      concepto.descripcion,
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
                          title: 'Total',
                          value: '${concepto.total.toStringAsFixed(2)}€',
                          icon: Icons.euro,
                          color: Colors.green,
                        ),
                        _buildDetailColumn(
                          title: 'Fecha',
                          value: concepto.fecha,
                          icon: Icons.calendar_today,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (String value) {
                    switch (value) {
                      case 'edit':
                        _navigateToEditApunte(concepto);
                        break;
                      case 'delete':
                        _showDeleteConfirmationDialog(concepto.id);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _navigateToEditApunte(ConceptoGastoAdelanto concepto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageApunteScreen(apunte: concepto),
      ),
    );

    if (result == true) {
      setState(() {
        currentPage = 0;
        conceptos.clear();
        _fetchConceptos();
      });
    }
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
      appBar: CommonHeader(title: 'Gestión-Apuntes'),
      body: Column(
        children: [
          _buildFiltroUsuarios(),
          Expanded(
            child: isLoading && conceptos.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: conceptos.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == conceptos.length) {
                  return Center(child: CircularProgressIndicator());
                }
                return _buildConceptoCard(conceptos[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFiltroUsuarios() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<String>(
        value: usuarioSeleccionado, // Usar el valor seleccionado
        hint: Text('Selecciona un usuario'),
        isExpanded: true,
        items: usuarios.map((usuario) {
          return DropdownMenuItem<String>(
            value: usuario,
            child: Text(usuario),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            usuarioSeleccionado = value; // Actualizar el filtro
            currentPage = 0;
            conceptos.clear();
            _fetchConceptos(); // Recargar los datos
          });
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
