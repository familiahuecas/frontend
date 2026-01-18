import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'listusuarios_screen.dart';
import 'manageusuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

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
          // 1. FONDO ESTÁTICO (Optimizado)
          const _StaticBackground(),

          // 2. CONTENIDO
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          Expanded(child: _buildActionGrid(isWide)),
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
          "Administración",
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

  Widget _buildActionGrid(bool isWide) {
    final actions = [
      _ActionItem(
        title: 'Ver Listado',
        subtitle: 'Consultar y editar usuarios existentes',
        icon: Icons.people_alt_rounded,
        color1: const Color(0xFF3B82F6), // Blue
        color2: const Color(0xFF1E40AF),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListUsuariosScreen())),
      ),
      _ActionItem(
        title: 'Crear Nuevo',
        subtitle: 'Dar de alta un nuevo empleado',
        icon: Icons.person_add_alt_1_rounded,
        color1: const Color(0xFF10B981), // Emerald
        color2: const Color(0xFF047857),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageUsuarioScreen())),
      ),
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 2 : 1,
        childAspectRatio: isWide ? 1.4 : 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _HeroActionCard(item: actions[index]),
    );
  }
}

// ... (Las clases _ActionItem y _HeroActionCard se mantienen IGUAL que antes) ...
// Si no las tienes a mano, avísame y te las pego, pero el cambio importante está abajo:

// ============================================================================
// TARJETAS "HERO" (Variante para Submenús)
// ============================================================================

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.onTap,
  });
}

class _HeroActionCard extends StatefulWidget {
  final _ActionItem item;
  const _HeroActionCard({required this.item});

  @override
  State<_HeroActionCard> createState() => _HeroActionCardState();
}

class _HeroActionCardState extends State<_HeroActionCard> {
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.item.color1.withOpacity(_isHovered ? 0.3 : 0.05),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // DECORACIÓN FONDO
                Positioned(
                  right: -40, bottom: -20,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(widget.item.icon, size: 200, color: widget.item.color1.withOpacity(0.08)),
                  ),
                ),
                // BRILLO SUPERIOR
                Positioned(
                  top: 0, left: 0, right: 0, height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white.withOpacity(0.5), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // CONTENIDO (Aquí está el ajuste principal)
                Padding(
                  // CAMBIO: Reducido de 30.0 a 24.0 para ganar espacio
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Badge
                      Container(
                        padding: const EdgeInsets.all(14), // Reducido un poco
                        decoration: BoxDecoration(
                          color: widget.item.color1.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.item.icon, color: widget.item.color1, size: 36), // Icono un pelín más pequeño
                      ),

                      const Spacer(), // Esto empuja todo hacia los extremos

                      Text(
                          widget.item.title,
                          style: const TextStyle(
                              fontSize: 24, // Reducido de 26 a 24
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                          )
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        maxLines: 2, // Aseguramos que no crezca infinitamente
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16), // Reducido de 20 a 16

                      // Botón
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: widget.item.color1,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Acceder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      )
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
// FONDO ESTÁTICO (Optimizado para rendimiento)
// ============================================================================

class _StaticBackground extends StatelessWidget {
  const _StaticBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Fondo base sólido
        Container(color: const Color(0xFFF5F7FA)),

        // 2. Manchas de color fijas
        Positioned(
          top: -100,
          left: -100,
          child: _Blob(color: const Color(0xFF64B5F6), size: 500),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _Blob(color: const Color(0xFFBA68C8), size: 500),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          right: -50,
          child: _Blob(color: const Color(0xFFFFB74D), size: 400),
        ),
        Positioned(
          bottom: 50,
          left: -80,
          child: _Blob(color: const Color(0xFF81C784).withOpacity(0.5), size: 350),
        ),

        // 3. Filtro de desenfoque único
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0),
          child: Container(
            color: Colors.white.withOpacity(0.3),
          ),
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