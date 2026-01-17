import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../model/user.dart';
import 'home_screen.dart';
import 'dart:math' as math;

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

  List<int> _buttonSequence = []; // Para registrar la secuencia de pulsaciones

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> requestBody;

      // Verificar si el login es por secuencia
      if (_buttonSequence.length == 4) {
        final sequenceString = _buttonSequence.join('');
        print('Iniciando sesión con secuencia: $sequenceString');

        requestBody = {
          'secuencia': sequenceString,
        };

        _buttonSequence.clear(); // Reiniciar la secuencia después de usarla
      } else {
        // Validar formulario para usuario/contraseña
        if (!_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        print('Iniciando sesión con usuario y contraseña');

        requestBody = {
          'name': _nameController.text,
          'password': _passwordController.text,
        };
      }

      // Siempre llamar al mismo endpoint
      const endpoint = '/auth/login';

      // Realizar la llamada al servicio
      final response = await apiService.post(endpoint, requestBody, requiresAuth: false);

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

  void _handleButtonPress(int buttonId) {
    setState(() {
      _buttonSequence.add(buttonId); // Añadir el botón pulsado a la secuencia
      print('Secuencia actual: $_buttonSequence');
      if (_buttonSequence.length == 4) {
        print('Secuencia completa: $_buttonSequence');
        _login(); // Llamar al login cuando la secuencia esté completa
      }
    });
  }

  String _parseErrorMessage(String error, [StackTrace? stackTrace]) {
    if (error.contains('401')) {
      return 'Credenciales incorrectas. Por favor, verifica tu nombre de usuario y contraseña.';
    } else if (error.contains('500')) {
      return 'Error del servidor. Inténtalo de nuevo más tarde.';
    } else if (error.contains('timeout')) {
      return 'El servidor no responde. Verifica tu conexión a Internet.';
    } else if (error.contains('La respuesta no contiene los datos necesarios')) {
      return 'El servidor no devolvió los datos esperados. Inténtalo más tarde.';
    } else {
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
      body: Stack(
        children: [
          // MURAL DE ICONOS DE FONDO
          const _IconMural(),

          // CONTENIDO ORIGINAL
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Container(
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
                            Expanded(flex: 1, child: _buildImage()),
                            SizedBox(width: 30),
                            Expanded(flex: 1, child: _buildForm()),
                          ],
                        ),
                      ),
                      // Botones invisibles en las esquinas
                      Positioned(
                        top: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => _handleButtonPress(1),
                          child: Container(
                            color: Colors.transparent,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _handleButtonPress(2),
                          child: Container(
                            color: Colors.transparent,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: GestureDetector(
                          onTap: () => _handleButtonPress(3),
                          child: Container(
                            color: Colors.transparent,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _handleButtonPress(4),
                          child: Container(
                            color: Colors.transparent,
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
          TextFormField(
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
          SizedBox(height: 15),
          TextFormField(
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
}

// ============================================================================
// MURAL DE ICONOS - GRANDES Y VISIBLES
// ============================================================================

// ============================================================================
// MURAL DE ICONOS - DINÁMICO (Cambia al entrar, estático al escribir)
// ============================================================================

// ============================================================================
// MURAL DE ICONOS - HÍBRIDO (Mezcla de Sólidos y Contornos)
// ============================================================================

class _IconMural extends StatefulWidget {
  const _IconMural();

  @override
  State<_IconMural> createState() => _IconMuralState();
}

class _IconMuralState extends State<_IconMural> {
  late final int _randomSeed;

  @override
  void initState() {
    super.initState();
    _randomSeed = DateTime.now().millisecondsSinceEpoch;
  }

  static const List<IconData> _icons = [
    Icons.agriculture, Icons.eco, Icons.person, Icons.spa, Icons.euro,
    Icons.receipt_long, Icons.folder, Icons.description, Icons.insert_chart,
    Icons.assessment, Icons.people, Icons.account_balance_wallet, Icons.settings,
    Icons.local_atm, Icons.trending_up, Icons.point_of_sale, Icons.payments,
    Icons.analytics, Icons.history, Icons.savings, Icons.nature, Icons.park,
    Icons.grass, Icons.forest, Icons.monetization_on, Icons.currency_exchange,
    Icons.precision_manufacturing, Icons.inventory_2, Icons.note_add,
    Icons.construction, Icons.work, Icons.handshake, Icons.business_center,
    Icons.calculate, Icons.water_drop, Icons.sunny, Icons.landscape
  ];

  static const List<Color> _colors = [
    Color(0xFF2E7D32), Color(0xFF7B1FA2), Color(0xFF1565C0), Color(0xFF00897B),
    Color(0xFFF9A825), Color(0xFF0097A7), Color(0xFFFF8F00), Color(0xFF8E24AA),
    Color(0xFF43A047), Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF00C853),
    Color(0xFF6A1B9A), Color(0xFFFFC107), Color(0xFF00ACC1), Color(0xFF388E3C),
    Color(0xFF039BE5), Color(0xFF7C4DFF), Color(0xFF1976D2), Color(0xFFFF7043),
    Color(0xFF5E35B1), Color(0xFFEF6C00), Color(0xFF546E7A), Color(0xFF5D4037),
    Color(0xFF00695C), Color(0xFFD84315)
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final random = math.Random(_randomSeed);

    // Un poco más de densidad para que la mezcla se aprecie bien
    final int iconCount = (size.width * size.height / 2500).clamp(60, 140).toInt();

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.white,
      child: Stack(
        children: List.generate(iconCount, (index) {
          final iconData = _icons[random.nextInt(_icons.length)];
          final color = _colors[random.nextInt(_colors.length)];
          final double iconSize = random.nextInt(100) + 40.0;
          final double rotation = (random.nextDouble() - 0.5) * 0.8;

          final double left = random.nextDouble() * size.width - 20;
          final double top = random.nextDouble() * size.height - 20;

          // Decisión aleatoria: ¿Será contorno o sólido? (50% probabilidad)
          final bool isOutlined = random.nextBool();

          return Positioned(
            left: left,
            top: top,
            child: Transform.rotate(
              angle: rotation,
              child: isOutlined
                  ? _buildOutlinedIcon(iconData, iconSize, color)
                  : _buildSolidIcon(iconData, iconSize, color),
            ),
          );
        }),
      ),
    );
  }

  // Opción 1: Icono solo con borde (Wireframe)
  Widget _buildOutlinedIcon(IconData icon, double size, Color color) {
    return Text(
      String.fromCharCode(icon.codePoint),
      style: TextStyle(
        inherit: false,
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = color.withOpacity(0.3), // Más opacidad para que la línea fina se vea
      ),
    );
  }

  // Opción 2: Icono sólido (Relleno)
  Widget _buildSolidIcon(IconData icon, double size, Color color) {
    return Icon(
      icon,
      size: size,
      color: color.withOpacity(0.12), // Muy transparente para no manchar el fondo
    );
  }
}