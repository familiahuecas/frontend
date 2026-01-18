import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../apirest/api_service.dart';

class ManageUsuarioScreen extends StatefulWidget {
  final User? user;

  ManageUsuarioScreen({this.user});

  @override
  _ManageUsuarioScreenState createState() => _ManageUsuarioScreenState();
}

class _ManageUsuarioScreenState extends State<ManageUsuarioScreen> with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool enabled = true;
  List<int> selectedRoleIds = [];
  bool isSaving = false; // Estado de carga del botón

  // Animaciones de entrada
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    // Configuración de animación
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutQuad));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  int _roleNameToId(String roleName) {
    switch (roleName) {
      case 'SUPERADMIN': return 1;
      case 'ADMIN': return 2;
      case 'CLIENTE': return 3;
      default: return 0;
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
            ? 'Por favor, rellena todos los campos y comprueba las contraseñas.'
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

    setState(() => isSaving = true);

    final userPayload = {
      'id': widget.user?.id ?? 0,
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'enabled': enabled,
      'roles': selectedRoleIds.map((roleId) => roleId.toString()).toList(),
      'message': null,
    };

    ApiService().createUser(User.fromJson(userPayload)).then((_) {
      _showSuccessDialog();
    }).catchError((error) {
      _showErrorDialog('Error al guardar el usuario: $error');
    }).whenComplete(() {
      setState(() => isSaving = false);
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('¡Éxito!'),
          ],
        ),
        content: Text(widget.user == null
            ? 'Usuario creado correctamente.'
            : 'Usuario actualizado correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              if (widget.user != null) {
                Navigator.pop(context, true); // Vuelve atrás si es edición
              } else {
                Navigator.pop(context, true); // Vuelve atrás también si es creación (opcional)
              }
            },
            child: Text('Aceptar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. FONDO ESTÁTICO
          const _StaticBackground(),

          // 2. CONTENIDO
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 30),
                          _buildFormCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GESTIÓN DE USUARIOS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.user == null ? 'Crear Usuario' : 'Editar Usuario',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Datos Personales
          _buildGlassInput(
            controller: nameController,
            label: 'Nombre Completo',
            hint: 'Ej. Juan Pérez',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildGlassInput(
            controller: emailController,
            label: 'Correo Electrónico',
            hint: 'ejemplo@empresa.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          // Contraseñas (Solo visibles si es nuevo o si se desea implementar cambio)
          // Mantenemos la lógica original: siempre visible para poder editarla si se quiere
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGlassInput(
                  controller: passwordController,
                  label: 'Contraseña',
                  hint: '******',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGlassInput(
                  controller: confirmPasswordController,
                  label: 'Confirmar',
                  hint: '******',
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 15),

          // Switch Habilitado
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Usuario Habilitado', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800])),
            subtitle: Text('Permitir acceso al sistema', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            activeColor: const Color(0xFF10B981),
            value: enabled,
            onChanged: (value) => setState(() => enabled = value),
          ),

          const SizedBox(height: 15),

          // Roles
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Roles Asignados", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildCheckboxTile(title: 'SUPERADMIN', roleId: 1),
                _buildCheckboxTile(title: 'ADMIN', roleId: 2),
                _buildCheckboxTile(title: 'CLIENTE', roleId: 3),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Botón de Acción
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isSaving ? null : _onSubmitPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Verde Esmeralda
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isSaving
                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.user == null ? Icons.person_add_rounded : Icons.save_as_rounded),
                  const SizedBox(width: 10),
                  Text(
                    widget.user == null ? 'Crear Usuario' : 'Actualizar Datos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({required String title, required int roleId}) {
    final isSelected = selectedRoleIds.contains(roleId);
    return CheckboxListTile(
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      value: isSelected,
      activeColor: const Color(0xFF10B981),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedRoleIds.add(roleId);
          } else {
            selectedRoleIds.remove(roleId);
          }
        });
      },
    );
  }
}

// ============================================================================
// FONDO ESTÁTICO
// ============================================================================
class _StaticBackground extends StatelessWidget {
  const _StaticBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFF5F7FA)),
        Positioned(top: -100, left: -100, child: _Blob(color: const Color(0xFF64B5F6), size: 500)),
        Positioned(bottom: -100, right: -100, child: _Blob(color: const Color(0xFFBA68C8), size: 500)),
        Positioned(top: MediaQuery.of(context).size.height * 0.3, right: -50, child: _Blob(color: const Color(0xFFFFB74D), size: 400)),
        Positioned(bottom: 50, left: -80, child: _Blob(color: const Color(0xFF81C784).withOpacity(0.5), size: 350)),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(color: Colors.white.withOpacity(0.3)),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
          radius: 0.7,
        ),
      ),
    );
  }
}