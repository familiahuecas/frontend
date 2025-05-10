import 'package:flutter/material.dart';
import '../model/adelantorequest.dart';
import '../model/usuarioconadelanto.dart';
import '../apirest/api_service.dart';
import 'widget/common_header.dart';

class ManageAdelantoScreen extends StatefulWidget {
  final UsuarioConAdelanto? adelanto;

  ManageAdelantoScreen({this.adelanto});

  @override
  _ManageAdelantoScreenState createState() => _ManageAdelantoScreenState();
}

class _ManageAdelantoScreenState extends State<ManageAdelantoScreen> {
  late TextEditingController cantidadController;
  late TextEditingController descripcionController;
  String? usuarioSeleccionado;
  bool isLoading = false;
  List<Map<String, dynamic>> usuarios = [];

  @override
  void initState() {
    super.initState();
    cantidadController = TextEditingController(
        text: widget.adelanto?.cantidadSolicitada.toString() ?? '');
    descripcionController = TextEditingController(
        text: widget.adelanto?.descripcion ?? '');
    usuarioSeleccionado = widget.adelanto?.idUsuario.toString();
    _fetchUsuarios();
  }

  @override
  void dispose() {
    cantidadController.dispose();
    descripcionController.dispose();
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
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSubmitPressed() {
    if (cantidadController.text.isEmpty ||
        descripcionController.text.isEmpty ||
        usuarioSeleccionado == null) {
      _showErrorDialog('Por favor, rellena todos los campos.');
      return;
    }

    if (double.tryParse(cantidadController.text) == null) {
      _showErrorDialog('Por favor, ingresa una cantidad válida.');
      return;
    }

    final adelanto = Adelantorequest(
      idUsuario: int.parse(usuarioSeleccionado!),
      cantidadSolicitada: double.parse(cantidadController.text),
      descripcion: descripcionController.text,
      fecha: DateTime.now().toIso8601String(),
    );
    ApiService()
        .crearAdelanto(adelanto.toJson())
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
                child: Text(widget.adelanto == null
                    ? 'Adelanto creado exitosamente.'
                    : 'Adelanto actualizado exitosamente.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      _showErrorDialog('Error al guardar el adelanto: $error');
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
      appBar: CommonHeader(
        title: widget.adelanto == null ? 'Crear Adelanto' : 'Editar Adelanto',
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              controller: cantidadController,
              label: 'Cantidad Asignada',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              controller: descripcionController,
              label: 'Descripción',
              icon: Icons.description,
            ),
            _buildDropdownUsuarios(),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _onSubmitPressed,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side:
                    BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                  elevation: 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.blueAccent, size: 32),
                    SizedBox(height: 8),
                    Text(
                      widget.adelanto == null
                          ? 'Crear Adelanto'
                          : 'Actualizar Adelanto',
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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

  Widget _buildDropdownUsuarios() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: usuarioSeleccionado,
        hint: Text('Selecciona un usuario'),
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: usuarios.map((usuario) {
          return DropdownMenuItem(
            value: usuario['id'].toString(),
            child: Text(usuario['name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            usuarioSeleccionado = value;
          });
        },
      ),
    );
  }
}
