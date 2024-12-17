import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Importar la librería de permisos
import '../apirest/api_service.dart';
import '../model/user.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Realizar la petición
        final response = await apiService.post(
          '/auth/login',
          {
            'name': _nameController.text,
            'password': _passwordController.text,
          },
          requiresAuth: false,
        );

        // Validar que la respuesta tiene el token y el usuario
        if (!response.containsKey('token') || !response.containsKey('user')) {
          throw Exception('La respuesta no contiene los datos necesarios.');
        }

        final token = response['token'];
        final userJson = response['user'];
        final user = User.fromJson(userJson);

        await apiService.saveToken(token);
        await apiService.saveUser(user);

        // Solicitar permisos antes de navegar a la pantalla principal
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          throw Exception('Permisos de almacenamiento denegados.');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
        );
      } catch (e, stackTrace) {
        setState(() {
          _isLoading = false;
          _errorMessage = _parseErrorMessage(e.toString(), stackTrace); // Envía también el StackTrace
        });
        print('Error al iniciar sesión: $e');
        print('StackTrace: $stackTrace');
        // Imprime el error en la consola para mayor detalle
        print('Error al iniciar sesión: $e');
        print('StackTrace: $stackTrace');
      }

    }
  }

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  String _parseErrorMessage(String error, [StackTrace? stackTrace]) {
    if (error.contains('401')) {
      return 'Credenciales incorrectas. Por favor, verifica tu nombre de usuario y contraseña.';
    } else if (error.contains('500')) {
      return 'Error del servidor. Inténtalo de nuevo más tarde.';
    } else if (error.contains('timeout')) {
      return 'El servidor no responde. Verifica tu conexión a Internet.';
    } else if (error.contains('Permisos de almacenamiento denegados')) {
      return 'Por favor, concede permisos de almacenamiento para continuar.';
    } else if (error.contains('La respuesta no contiene los datos necesarios')) {
      return 'El servidor no devolvió los datos esperados. Inténtalo más tarde.';
    } else {
      // Si ocurre un error inesperado, devuelve el mensaje completo y la traza
      String detailedError = 'Error inesperado: $error';
      if (stackTrace != null) {
        detailedError += '\nStackTrace:\n$stackTrace';
      }
      return detailedError;
    }
  }


  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El usuario no puede estar vacío';
    } else if (value.length < 5 || value.length > 15) {
      return 'El usuario debe tener entre 5 y 15 caracteres';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña no puede estar vacía';
    } else if (value.length < 5) {
      return 'La contraseña debe tener al menos 5 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600), // Tamaño reducido de ancho
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey, width: 1.5),
                ),
                padding: const EdgeInsets.all(16.0),
                child: isMobile
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildImage(),
                    SizedBox(height: 30), // Mantiene el alto original
                    _buildForm(),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildImage(),
                    ),
                    SizedBox(width: 30),
                    Expanded(
                      flex: 1,
                      child: _buildForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: _login,
      child: Image.asset(
        'assets/images/olivoFHsinfondo.png',
        height: 200, // Mantiene el alto original
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                label: Center(
                  child: Text(
                    'Nombre de usuario',
                    style: TextStyle(
                      color: Color(0xff742d2d),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Color(0xff742d2d)),
              validator: _validateUsername,
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: TextFormField(
              controller: _passwordController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                label: Center(
                  child: Text(
                    'Contraseña',
                    style: TextStyle(
                      color: Color(0xff742d2d),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Color(0xff742d2d)),
              validator: _validatePassword,
            ),
          ),
          SizedBox(height: 20), // Mantiene el alto original
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
