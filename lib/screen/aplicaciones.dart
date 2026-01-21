import 'dart:ui';
import 'package:flutter/material.dart';
import 'aplicaciones_list_screen.dart';
import 'aplicaciones_upload_screen.dart';

class AplicacionesScreen extends StatefulWidget {
  @override
  _AplicacionesScreenState createState() => _AplicacionesScreenState();
}

class _AplicacionesScreenState extends State<AplicacionesScreen> with TickerProviderStateMixin {
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
          const _StaticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 30),
                          Expanded(child: _buildActionGrid(context, isWide)),
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
          "APLICACIONES",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Subir y Descargar Apps",
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

  Widget _buildActionGrid(BuildContext context, bool isWide) {
    final actions = [
      _ActionItem(
        title: 'Subir Aplicacion',
        subtitle: 'Cargar nuevas aplicaciones',
        icon: Icons.cloud_upload_rounded,
        color1: const Color(0xFF10B981), // Verde esmeralda
        color2: const Color(0xFF059669),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AplicacionesUploadScreen()),
          );
        },
      ),
      _ActionItem(
        title: 'Descargar Apps',
        subtitle: 'Ver listado de aplicaciones',
        icon: Icons.download_rounded,
        color1: const Color(0xFF6366F1), // Indigo
        color2: const Color(0xFF4F46E5),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AplicacionesListScreen()),
          );
        },
      ),
    ];

    return GridView.count(
      crossAxisCount: isWide ? 2 : 1,
      childAspectRatio: isWide ? 1.4 : 1.2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: actions.map((action) => _HeroActionCard(item: action)).toList(),
    );
  }
}

// ============================================================================
// CLASES AUXILIARES
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
                Positioned(
                  right: -40,
                  bottom: -20,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      widget.item.icon,
                      size: 200,
                      color: widget.item.color1.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0, height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: widget.item.color1.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.item.icon, color: widget.item.color1, size: 36),
                      ),
                      const Spacer(),
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [widget.item.color1, widget.item.color2]),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(color: widget.item.color1.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                            ]
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Acceder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
// FONDO ESTATICO
// ============================================================================

class _StaticBackground extends StatelessWidget {
  const _StaticBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFF5F7FA)),
        Positioned(top: -100, left: -100, child: _Blob(color: const Color(0xFF10B981), size: 500)),
        Positioned(bottom: -100, right: -100, child: _Blob(color: const Color(0xFF6366F1), size: 500)),
        Positioned(top: MediaQuery.of(context).size.height * 0.3, right: -50, child: _Blob(color: const Color(0xFF8B5CF6), size: 400)),
        Positioned(bottom: 50, left: -80, child: _Blob(color: const Color(0xFF14B8A6).withOpacity(0.5), size: 350)),
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
