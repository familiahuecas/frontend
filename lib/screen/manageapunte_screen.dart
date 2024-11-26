import 'package:familiahuecasfrontend/screen/widget/common_header.dart';
import 'package:flutter/material.dart';
import '../model/conceptogastoadelanto.dart';
import '../apirest/api_service.dart';

class ManageApunteScreen extends StatefulWidget {
  final ConceptoGastoAdelanto? apunte;

  ManageApunteScreen({this.apunte});

  @override
  _ManageApunteScreenState createState() => _ManageApunteScreenState();
}

class _ManageApunteScreenState extends State<ManageApunteScreen> {
  late TextEditingController descripcionController;
  late TextEditingController totalController;
  String? usuarioSeleccionado;
  List<String> usuarios = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    descripcionController = TextEditingController(text: widget.apunte?.descripcion ?? '');
    totalController = TextEditingController(text: widget.apunte?.total.toString() ?? '');
    usuarioSeleccionado = widget.apunte?.usuario;
    _fetchUsuarios();
  }

  Future<void> _fetchUsuarios() async {
    setState(() => isLoading = true);
    try {
      final fetchedUsuarios = await ApiService().getUsuariosConApuntes();
      setState(() {
        usuarios = fetchedUsuarios.map((u) => u.nombre).toList();
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
    if (descripcionController.text.isEmpty || totalController.text.isEmpty || usuarioSeleccionado == null) {
      _showErrorDialog('Por favor, rellena todos los campos.');
      return;
    }

    if (double.tryParse(totalController.text) == null) {
      _showErrorDialog('Por favor, ingresa un total válido.');
      return;
    }

    final apuntePayload = ConceptoGastoAdelanto(
      id: widget.apunte?.id ?? 0,
      descripcion: descripcionController.text,
      total: double.parse(totalController.text),
      fecha: "",
      usuario: usuarioSeleccionado!,
    );

    ApiService()
        .crearApunte(apuntePayload)
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
                child: Text(widget.apunte == null
                    ? 'Apunte creado exitosamente.'
                    : 'Apunte actualizado exitosamente.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context, true); // Notifica que hubo una actualización
              },
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      _showErrorDialog('Error al guardar el apunte: $error');
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

      appBar: CommonHeader(title: widget.apunte == null ? 'Crear Apunte' : 'Editar Apunte'),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              controller: descripcionController,
              label: 'Descripción',
              icon: Icons.description,
            ),
            _buildInputField(
              controller: totalController,
              label: 'Total',
              icon: Icons.euro,
              keyboardType: TextInputType.number,
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
                      widget.apunte == null ? 'Crear Apunte' : 'Actualizar Apunte',
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
            value: usuario,
            child: Text(usuario),
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
