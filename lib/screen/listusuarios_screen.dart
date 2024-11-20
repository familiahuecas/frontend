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
    return Card(
      color: Colors.blueGrey[50],
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usuario: ${user.name}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: ${user.email},\nHabilitado: ${user.enabled ? "Sí" : "No"}\n'
                        'Roles: ${user.roles?.join(", ")}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToEditUser(user),
            ),

            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(user.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: 'Usuarios'),
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
