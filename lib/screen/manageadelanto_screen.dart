import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../model/usuarioconadelanto.dart';
import '../apirest/api_service.dart';

class ManageAdelantoScreen extends StatefulWidget {
  final UsuarioConAdelanto? adelanto;

  ManageAdelantoScreen({this.adelanto});

  @override
  _ManageAdelantoScreenState createState() => _ManageAdelantoScreenState();
}

class _ManageAdelantoScreenState extends State<ManageAdelantoScreen> with TickerProviderStateMixin {
  late TextEditingController cantidadController;
  String? usuarioSeleccionado;
  bool isLoading = false;
  bool isSaving = false;
  List<Map<String, dynamic>> usuarios = []; // Guardará ID y nombre

  // Animaciones de entrada
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    cantidadController = TextEditingController(
        text: widget.adelanto?.cantidadSolicitada.toString() ?? '');
    usuarioSeleccionado = widget.adelanto?.idUsuario.toString();

    _fetchUsuarios();

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
    cantidadController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsuarios() async {
    setState(() => isLoading = true);
    try {
      final fetchedUsuarios = await ApiService().getUsers();
      setState(() {
        usuarios = fetchedUsuarios
            .map((u) => {'id': u.id, 'name': u.name ?? 'Sin nombre'})
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSubmitPressed() {
    if (cantidadController.text.isEmpty || usuarioSeleccionado == null) {
      _showErrorDialog('Por favor, rellena todos los campos.');
      return;
    }

    if (double.tryParse(cantidadController.text) == null) {
      _showErrorDialog('Por favor, ingresa una cantidad válida.');
      return;
    }

    setState(() => isSaving = true);

    final adelantoPayload = UsuarioConAdelanto(
      idUsuario: int.tryParse(usuarioSeleccionado!) ?? 0,
      cantidadSolicitada: double.parse(cantidadController.text),
    );

    ApiService().crearAdelanto(adelantoPayload).then((_) {
      _showSuccessDialog();
    }).catchError((error) {
      _showErrorDialog('Error al guardar el adelanto: $error');
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
        content: Text(widget.adelanto == null
            ? 'Adelanto creado correctamente.'
            : 'Adelanto actualizado correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              Navigator.pop(context, true); // Vuelve atrás
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
              child: isLoading
                  ? CircularProgressIndicator(color: const Color(0xFFF59E0B))
                  : SingleChildScrollView(
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
          "GESTIÓN DE ADELANTOS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.adelanto == null ? 'Crear Adelanto' : 'Editar Adelanto',
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
          _buildGlassInput(
            controller: cantidadController,
            label: 'Cantidad Asignada (€)',
            hint: '0.00',
            icon: Icons.attach_money_rounded,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          _buildGlassDropdown(),
          const SizedBox(height: 40),

          // BOTÓN DE ACCIÓN (Color Ámbar para distinguir de Apuntes)
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isSaving ? null : _onSubmitPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B), // Ámbar / Naranja
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: const Color(0xFFF59E0B).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isSaving
                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.adelanto == null ? Icons.save_rounded : Icons.update_rounded),
                  const SizedBox(width: 10),
                  Text(
                    widget.adelanto == null ? 'Guardar Adelanto' : 'Actualizar',
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text("Usuario Asignado", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: usuarioSeleccionado,
              hint: Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: Colors.grey[500]),
                  SizedBox(width: 12),
                  Text('Selecciona usuario', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
              items: usuarios.map((usuario) {
                return DropdownMenuItem(
                  value: usuario['id'].toString(),
                  child: Text(usuario['name'], style: TextStyle(color: Colors.black87)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  usuarioSeleccionado = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FONDO ESTÁTICO REUTILIZABLE
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