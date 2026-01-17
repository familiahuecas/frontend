import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/model/user.dart';
import '../apirest/api_service.dart';
import 'manageusuario_screen.dart';

class ListUsuariosScreen extends StatefulWidget {
  @override
  _ListUsuariosScreenState createState() => _ListUsuariosScreenState();
}

class _ListUsuariosScreenState extends State<ListUsuariosScreen> {
  List<User> users = [];
  int currentPage = 0;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchUsers();
      }
    });
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final userPage = await ApiService().getUsersPaginated(currentPage, 10);
      setState(() {
        users.addAll(userPage.content);
        currentPage++;
      });
    } catch (e) {
      // Manejar errores si es necesario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteUser(int id) async {
    try {
      await ApiService().deleteUser(id);
      setState(() {
        users.removeWhere((user) => user.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario eliminado con éxito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el usuario: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteUser(id); // Llama al método de eliminación
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(User user) {
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
                          user.name ?? 'Desconocido',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.email ?? 'No disponible',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Habilitado: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: user.enabled ? "Sí" : "No",
                            style: TextStyle(
                              fontSize: 16,
                              color: user.enabled ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Roles:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: user.roles?.map((role) {
                        Color roleColor;
                        switch (role) {
                          case 'SUPERADMIN':
                            roleColor = Colors.red;
                            break;
                          case 'ADMIN':
                            roleColor = Colors.orange;
                            break;
                          case 'CLIENTE':
                            roleColor = Colors.green;
                            break;
                          default:
                            roleColor = Colors.grey;
                        }
                        return Chip(
                          label: Text(
                            role,
                            style: TextStyle(
                              color: roleColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 8, // 👈 fuente más pequeña
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0), // 👈 reduce el relleno
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 👈 reduce área táctil
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2), // 👈 compacta aún más
                          backgroundColor: Colors.white,
                          shape: StadiumBorder(
                            side: BorderSide(color: roleColor, width: 1),
                          ),
                        );
                      }).toList() ?? [
                        Chip(
                          label: const Text('Sin roles asignados', style: TextStyle(fontSize: 11)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        )
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
                        _navigateToEditUser(user);
                        break;
                      case 'delete':
                        _showDeleteConfirmationDialog(user.id);
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
                     /* PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),*/
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Usuarios-Listado'),
      body: isLoading && users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: users.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return Center(child: CircularProgressIndicator());
          }
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  void _navigateToEditUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageUsuarioScreen(user: user),
      ),
    );

    if (result == true) {
      setState(() {
        currentPage = 0; // Reiniciar la paginación
        users.clear(); // Limpiar la lista de usuarios actual
        _fetchUsers(); // Recargar la lista de usuarios
      });
    }
  }

}
