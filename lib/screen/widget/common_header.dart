import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CommonHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.limeAccent, // Color de fondo
      centerTitle: true, // Centrar el título
      title: Text(
        'Familia Huecas - $title',
        style: TextStyle(color: Colors.black), // Color del texto
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          onPressed: () {
            // Mostrar el diálogo de confirmación
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  // Método para mostrar el diálogo de confirmación
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: Text('¿Estás seguro de que deseas cerrar la sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
            TextButton(
              child: Text('Salir'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _logout(context); // Llamar al método de logout
              },
            ),
          ],
        );
      },
    );
  }

  // Método para manejar el logout
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Eliminar todos los datos de la sesión
    Navigator.of(context).pushReplacementNamed('/login'); // Redirigir al login
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
