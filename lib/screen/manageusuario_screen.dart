import 'package:flutter/material.dart';
import '../model/user.dart';
import '../apirest/api_service.dart';

class ManageUsuarioScreen extends StatefulWidget {
  final User? user;

  ManageUsuarioScreen({this.user});

  @override
  _ManageUsuarioScreenState createState() => _ManageUsuarioScreenState();
}

class _ManageUsuarioScreenState extends State<ManageUsuarioScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool enabled = true;
  List<int> selectedRoleIds = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.name ?? '');
    emailController = TextEditingController(text: widget.user?.email ?? '');
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    enabled = widget.user?.enabled ?? true;
    selectedRoleIds = widget.user?.roles
        ?.map((role) => _roleNameToId(role))
        .toList() ??
        [];
  }

  int _roleNameToId(String roleName) {
    switch (roleName) {
      case 'SUPERADMIN':
        return 1;
      case 'ADMIN':
        return 2;
      case 'CLIENTE':
        return 3;
      default:
        return 0;
    }
  }

  String _roleIdToName(int roleId) {
    switch (roleId) {
      case 1:
        return 'SUPERADMIN';
      case 2:
        return 'ADMIN';
      case 3:
        return 'CLIENTE';
      default:
        return '';
    }
  }

  void _onSubmitPressed() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        (widget.user == null && passwordController.text.isEmpty) ||
        (widget.user == null &&
            passwordController.text != confirmPasswordController.text)) {
      _showErrorDialog(
        widget.user == null
            ? 'Por favor, rellena todos los campos y asegúrate de que las contraseñas coinciden.'
            : 'Por favor, rellena todos los campos.',
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      _showErrorDialog('Por favor, ingresa un email válido.');
      return;
    }

    if (selectedRoleIds.isEmpty) {
      _showErrorDialog('Por favor, selecciona al menos un rol.');
      return;
    }

    // Convertir los IDs de roles a cadenas antes de incluirlos en el payload
    final userPayload = {
      'id': widget.user?.id ?? 0, // Si es un usuario nuevo, usa 0 como ID
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'enabled': enabled,
      'roles': selectedRoleIds.map((roleId) => roleId.toString()).toList(), // Convertir IDs a cadenas
      'message': null,
    };

    print('Preparando para guardar usuario: $userPayload');

    ApiService()
        .createUser(User.fromJson(userPayload))
        .then((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Éxito'),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.user == null
                      ? 'Usuario creado exitosamente.'
                      : 'Usuario actualizado exitosamente.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                if (widget.user != null) {
                  Navigator.pop(context, true); // Notifica que hubo una actualización
                }
              },
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      _showErrorDialog('Error al guardar el usuario: $error');
    });
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Crear Usuario' : 'Editar Usuario'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              controller: nameController,
              label: 'Nombre',
              icon: Icons.person,
            ),
            _buildInputField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
            ),
           // if (widget.user == null)
              _buildInputField(
                controller: passwordController,
                label: 'Contraseña',
                icon: Icons.lock,
                obscureText: true,
              ),
           // if (widget.user == null)
              _buildInputField(
                controller: confirmPasswordController,
                label: 'Confirmar Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
            SwitchListTile(
              title: Text('Habilitado'),
              value: enabled,
              onChanged: (value) => setState(() => enabled = value),
            ),
            SizedBox(height: 10),
            Text('Roles', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCompactCheckboxTile(
                  title: 'SUPERADMIN',
                  value: selectedRoleIds.contains(1),
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? selectedRoleIds.add(1)
                          : selectedRoleIds.remove(1);
                    });
                  },
                ),
                _buildCompactCheckboxTile(
                  title: 'ADMIN',
                  value: selectedRoleIds.contains(2),
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? selectedRoleIds.add(2)
                          : selectedRoleIds.remove(2);
                    });
                  },
                ),
                _buildCompactCheckboxTile(
                  title: 'CLIENTE',
                  value: selectedRoleIds.contains(3),
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? selectedRoleIds.add(3)
                          : selectedRoleIds.remove(3);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _onSubmitPressed,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                  elevation: 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.blueAccent, size: 32),
                    SizedBox(height: 8),
                    Text(
                      widget.user == null ? 'Crear Usuario' : 'Actualizar Usuario',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCheckboxTile({
    required String title,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Expanded(
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
