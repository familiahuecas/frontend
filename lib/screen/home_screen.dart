import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'documentos.dart';
import 'gestion.dart';
import 'maquinas.dart';
import 'ubicacion.dart';
import 'user.dart';
import 'widget/common_header.dart';
import '../apirest/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _primaryAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _pulseAnimationController;

  late Animation<double> _welcomeScaleAnimation;
  late Animation<double> _welcomeOpacityAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;

  List<Particle> particles = [];

  final List<_MenuItem> menuItems = [
    _MenuItem(
        'Usuarios',
        Icons.people_alt_rounded,
        const [Color(0xFF667eea), Color(0xFF764ba2)],
        const [Color(0xFF9253f1), Color(0xFF34d8eb)],
        UsuariosScreen(),
        '👥'
    ),
    _MenuItem(
        'Gestión',
        Icons.dashboard_customize_rounded,
        const [Color(0xFFf093fb), Color(0xFFf5576c)],
        const [Color(0xFFff6b9d), Color(0xFFf7931e)],
        GestionScreen(),
        '⚡'
    ),
    _MenuItem(
        'Máquinas',
        Icons.precision_manufacturing_rounded,
        const [Color(0xFF4facfe), Color(0xFF00f2fe)],
        const [Color(0xFF00c6ff), Color(0xFF0072ff)],
        MaquinasScreen(),
        '🚀'
    ),
    _MenuItem(
        'Documentos',
        Icons.auto_stories_rounded,
        const [Color(0xFF43e97b), Color(0xFF38f9d7)],
        const [Color(0xFF88f5a3), Color(0xFF4dd0e1)],
        DocumentosScreen(),
        '📚'
    ),
    _MenuItem(
        'Ubicaciones',
        Icons.explore_rounded,
        const [Color(0xFFfa709a), Color(0xFFfee140)],
        const [Color(0xFFff9a9e), Color(0xFFfecfef)],
        UbicacionScreen(),
        '🌍'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    //_generateParticles();
    _startAnimations();
  }

  void _initializeControllers() {
    _primaryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  void _initializeAnimations() {
    _welcomeScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _welcomeOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryAnimationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleAnimationController);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    final random = math.Random();
    particles = List.generate(15, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 0.5,
        size: 2 + random.nextDouble() * 4,
        opacity: 0.3 + random.nextDouble() * 0.4,
      );
    });
  }

  void _startAnimations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primaryAnimationController.forward();
      _particleAnimationController.repeat();
      _pulseAnimationController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _primaryAnimationController.dispose();
    _particleAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<String?> _fetchUserName() async {
    final user = await ApiService().getUser();
    return user?.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(title: 'Home', showBackButton: false),
      body: Stack(
        children: [
          // Fondo estático con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF24243e),
                  Color(0xFF302b63),
                ],
              ),
            ),
          ),

          // Partículas flotantes
          _buildFloatingParticles(),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildMagicalWelcomeSection(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildEpicMenuGrid()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ParticlePainter(particles, _particleAnimation.value),
        );
      },
    );
  }

  Widget _buildMagicalWelcomeSection() {
    return AnimatedBuilder(
      animation: _primaryAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _welcomeScaleAnimation.value,
          child: Opacity(
            opacity: _welcomeOpacityAnimation.value,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildWelcomeContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeContent() {
    return FutureBuilder<String?>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? '';
        return Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: const Text(
                    '🌟',
                    style: TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Bienvenido a la Familia!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
            if (userName.isNotEmpty) ...[
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFA500),
                    Color(0xFFFF6B6B),
                    Color(0xFF4ECDC4),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFFFD700),
                    Color(0xFF4ECDC4),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEpicMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 30,
      mainAxisSpacing: 40,
      childAspectRatio: 1.3,
      children: menuItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildMagicalMenuItem(item, index);
      }).toList(),
    );
  }

  Widget _buildMagicalMenuItem(_MenuItem item, int index) {
    return AnimatedBuilder(
      animation: _primaryAnimationController,
      builder: (context, child) {
        final delay = index * 0.15;
        final animationValue = Curves.elasticOut.transform(
          ((_primaryAnimationController.value - delay).clamp(0.0, 1.0) / (1.0 - delay)).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, (1 - animationValue) * 100),
          child: Transform.scale(
            scale: animationValue,
            child: _buildGlowingCard(item),
          ),
        );
      },
    );
  }

  Widget _buildGlowingCard(_MenuItem item) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.gradientColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.gradientColors.first.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: item.glowColors.first.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 5),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => item.screen,
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                            ),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 600),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Color> glowColors;
  final Widget screen;
  final String emoji;

  _MenuItem(this.title, this.icon, this.gradientColors, this.glowColors, this.screen, this.emoji);
}

class Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      particle.y = (particle.y - particle.speed * 0.01) % 1.0;
      if (particle.y < 0) particle.y = 1.0;

      paint.color = Colors.white.withOpacity(particle.opacity * 0.6);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}