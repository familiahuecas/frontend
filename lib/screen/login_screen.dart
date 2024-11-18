import 'package:flutter/material.dart';
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
        // Llamada al servicio de login
        final response = await apiService.post(
          '/auth/login',
          {
            'name': _nameController.text,
            'password': _passwordController.text,
          },
          requiresAuth: false,
        );

        setState(() {
          _isLoading = false;
        });

        // Parsear el token y el usuario de la respuesta
        final token = response['token'];
        final userJson = response['user'];
        final user = User.fromJson(userJson);

        // Guardar el token y el usuario en SharedPreferences
        await apiService.saveToken(token);
        await apiService.saveUser(user); // Guardar el usuario

        // Imprimir para verificar
        print('Token recibido: $token');
        print('Usuario guardado: ${user.name}');

        // Redirige a la pantalla Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // Validaciones
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
    } else if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si estamos en un dispositivo móvil o en la web
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Container(
            height: isMobile
                ? MediaQuery.of(context).size.height // Ocupa toda la pantalla en móvil
                : 500, // Altura fija en la web
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffffffff), Color(0xffffffff)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 1), // Espacio adicional en la parte superior
                  GestureDetector(
                    onTap: _login,
                    child: Image.asset(
                      'assets/images/olivoFHsinfondo.png',
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 30), // Espacio entre la imagen y los campos de texto
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: TextStyle(color: Color(0xff742d2d)),
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
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Color(0xff742d2d)),
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
                  SizedBox(height: 20),
                  if (_isLoading)
                    CircularProgressIndicator(color: Colors.purpleAccent),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
