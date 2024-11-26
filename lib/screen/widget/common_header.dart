import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton; // Nueva propiedad para controlar la visibilidad del botón de volver

  const CommonHeader({Key? key, required this.title, this.showBackButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Fondo blanco para un diseño limpio
      elevation: 2, // Sombra sutil para el AppBar
      centerTitle: true,
      automaticallyImplyLeading: showBackButton, // Controla si se muestra el botón
      title: Text(
        'FH - $title',
        style: TextStyle(
          color: Colors.black87, // Color del texto más oscuro para mayor contraste
          fontWeight: FontWeight.bold, // Texto en negrita
          fontSize: 20, // Tamaño de fuente más grande
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.black54), // Icono más sutil
          onPressed: () {
            _showLogoutDialog(context); // Mostrar el diálogo de cierre de sesión
          },
          tooltip: 'Cerrar sesión',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          title: Text(
            'Cerrar sesión',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Título en negrita
              color: Colors.redAccent, // Color llamativo para resaltar
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas cerrar la sesión?',
            style: TextStyle(color: Colors.black54), // Texto más sobrio
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey), // Botón cancelar en gris
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
            TextButton(
              child: Text(
                'Salir',
                style: TextStyle(color: Colors.redAccent), // Botón salir en rojo
              ),
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
