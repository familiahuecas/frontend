import 'dart:ui'; // Necesario para ImageFilter
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../core/app_theme.dart';
import '../model/user.dart';
import 'aplicaciones.dart';
import 'documentos.dart';
import 'gestion.dart';
import 'maquinas.dart';
import 'user.dart';
import 'widget/common_header.dart';


class HomeScreen extends StatefulWidget {
  final String token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  User? currentUser;
  bool _isLoading = true;
  final ApiService apiService = ApiService();

  // Controladores para la animación de entrada
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    fetchCurrentUser();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await apiService.getUser();
      setState(() {
        currentUser = user;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _fadeController.forward(); // Mostrar aunque sea el error con animación
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un LayoutBuilder para adaptabilidad
    return Scaffold(
      extendBodyBehindAppBar: true, // Importante para que el fondo llegue arriba
      appBar: CommonHeader(title: '', showBackButton: false), // Header transparente
      body: Stack(
        children: [
          // 1. FONDO ANIMADO (Ambient Background)
          const _StaticBackground(),

          // 2. CAPA DE CRISTAL (Opcional, para unificar el tono)
          Container(color: Colors.white.withOpacity(0.3)),

          // 3. CONTENIDO PRINCIPAL
          SafeArea(
            child: _isLoading
                ? _buildLoading()
                : currentUser == null
                ? _buildError()
                : FadeTransition(
              opacity: _fadeAnimation,
              child: _buildDashboardContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER PERSONALIZADO
              _buildWelcomeSection(),

              const SizedBox(height: 30),

              Text(
                "PANEL DE CONTROL",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 15),

              // GRID DE NAVEGACIÓN (BENTO GRID)
              _buildBentoGrid(isWide),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Buenos días' : (hour < 20 ? 'Buenas tardes' : 'Buenas noches');

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(
                  currentUser?.name?.substring(0, 1).toUpperCase() ?? "U",
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  Text(
                    currentUser?.name ?? "Usuario",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoGrid(bool isWide) {
    // Definimos los items
    final items = [
      _BentoItem(
        title: "Usuarios",
        subtitle: "Gestión de personal",
        icon: Icons.people_outline_rounded,
        color1: Color(0xFF64B5F6),
        color2: Color(0xFF1976D2),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UsuariosScreen())),
      ),
      _BentoItem(
        title: "Gestión",
        subtitle: "Analíticas y datos",
        icon: Icons.bar_chart_rounded,
        color1: Color(0xFFBA68C8),
        color2: Color(0xFF7B1FA2),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GestionScreen())),
      ),
      _BentoItem(
        title: "Máquinas",
        subtitle: "Estado y control",
        icon: Icons.precision_manufacturing_outlined,
        color1: Color(0xFF81C784),
        color2: Color(0xFF388E3C),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MaquinasScreen())),
      ),
      _BentoItem(
        title: "Documentos",
        subtitle: "Archivos y reportes",
        icon: Icons.folder_open_rounded,
        color1: Color(0xFFFFB74D),
        color2: Color(0xFFF57C00),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentosScreen())),
      ),
      _BentoItem(
        title: "Aplicaciones",
        subtitle: "Subir y descargar apps",
        icon: Icons.apps_rounded,
        color1: Color(0xFF10B981),
        color2: Color(0xFF059669),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AplicacionesScreen())),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isWide ? 4 : 2; // 4 columnas en PC, 2 en móvil
        // Aspect Ratio cercano a 1.0 hace las tarjetas cuadradas
        double aspectRatio = isWide ? 0.9 : 0.85;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _BentoCard(item: items[index]),
        );
      },
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());
  Widget _buildError() => const Center(child: Text("Error cargando perfil"));
}

// ============================================================================
// WIDGETS DECORATIVOS & TARJETAS
// ============================================================================

class _BentoItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  _BentoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.onTap,
  });
}

class _BentoCard extends StatefulWidget {
  final _BentoItem item;
  const _BentoCard({required this.item});

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.02)..translate(0.0, -5.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            // Fondo blanco semitransparente o degradado sutil
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.item.color1.withOpacity(_isHovered ? 0.4 : 0.1),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 1. ICONO GIGANTE DE FONDO (Marca de agua)
                Positioned(
                  right: -25,
                  bottom: -25,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      widget.item.icon,
                      size: 140, // ¡Super Grande!
                      color: widget.item.color1.withOpacity(0.08),
                    ),
                  ),
                ),

                // 2. DECORACIÓN SUPERIOR (Brillo)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. CONTENIDO PRINCIPAL
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icono Principal (Badge)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [widget.item.color1, widget.item.color2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.item.color2.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      // Texto
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[800],
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Ver detalles", // Texto genérico o usa widget.item.subtitle
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: widget.item.color1,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FONDO "MESH" ESTÁTICO (Alto rendimiento, mismo look)
// ============================================================================

class _StaticBackground extends StatelessWidget {
  const _StaticBackground();

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño para posicionar relativamente si queremos,
    // o usamos posiciones fijas que funcionan bien en general.
    return Stack(
      children: [
        // 1. Fondo base sólido (Gris muy claro / Blanco sucio)
        Container(color: const Color(0xFFF5F7FA)),

        // 2. Orbe Azul (Esquina superior izquierda)
        Positioned(
          top: -100,
          left: -100,
          child: _Blob(color: const Color(0xFF64B5F6), size: 500),
        ),

        // 3. Orbe Violeta (Esquina inferior derecha)
        Positioned(
          bottom: -100,
          right: -100,
          child: _Blob(color: const Color(0xFFBA68C8), size: 500),
        ),

        // 4. Orbe Ámbar (Centro-Derecha, para dar calidez)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: -50,
          child: _Blob(color: const Color(0xFFFFB74D), size: 400),
        ),

        // 5. Orbe Verde Sutil (Abajo Izquierda, para equilibrar)
        Positioned(
          bottom: 50,
          left: -80,
          child: _Blob(color: const Color(0xFF81C784).withOpacity(0.5), size: 350),
        ),

        // 6. BLUR MASIVO (Unifica todo en un degradado suave)
        // Al ser estático, este filtro se aplica una sola vez al pintar.
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(
            color: Colors.white.withOpacity(0.3), // Capa unificadora
          ),
        ),
      ],
    );
  }
}

// Reutilizamos tu clase _Blob, no hace falta cambiarla, pero asegúrate de tenerla:
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