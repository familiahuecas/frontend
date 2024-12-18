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
        final response = await apiService.post(
          '/auth/login',
          {
            'name': _nameController.text,
            'password': _passwordController.text,
          },
          requiresAuth: false,
        );

        if (!response.containsKey('token') || !response.containsKey('user')) {
          throw Exception('La respuesta no contiene los datos necesarios.');
        }

        final token = response['token'];
        final userJson = response['user'];
        final user = User.fromJson(userJson);

        await apiService.saveToken(token);
        await apiService.saveUser(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
        );
      } catch (e, stackTrace) {
        setState(() {
          _isLoading = false;
          _errorMessage = _parseErrorMessage(e.toString(), stackTrace);
        });
        print('Error al iniciar sesión: $e');
        print('StackTrace: $stackTrace');
      }
    }
  }

  String _parseErrorMessage(String error, [StackTrace? stackTrace]) {
    if (error.contains('401')) {
      return 'Credenciales incorrectas. Verifica tu usuario y contraseña.';
    } else {
      return 'Error inesperado: $error';
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
            constraints: BoxConstraints(maxWidth: 600),
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
                    SizedBox(height: 30),
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
        height: 200,
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
              decoration: _inputDecoration('Nombre de usuario'),
              style: TextStyle(color: Color(0xff742d2d)),
              validator: _validateUsername,
              onFieldSubmitted: (_) => _login(), // Captura "Enter"
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: TextFormField(
              controller: _passwordController,
              textAlign: TextAlign.center,
              decoration: _inputDecoration('Contraseña'),
              obscureText: true,
              style: TextStyle(color: Color(0xff742d2d)),
              validator: _validatePassword,
              onFieldSubmitted: (_) => _login(), // Captura "Enter"
            ),
          ),
          SizedBox(height: 20),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      label: Center(
        child: Text(
          label,
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
    );
  }
}
