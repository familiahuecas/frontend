import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/screen/recaudaciones.dart';
import 'hacerrecaudacion_screen.dart';
import 'numeraciones.dart';

class MaquinasScreen extends StatefulWidget {
  @override
  _MaquinasScreenState createState() => _MaquinasScreenState();
}

class _MaquinasScreenState extends State<MaquinasScreen> with TickerProviderStateMixin {
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
          // 1. FONDO LÍQUIDO
          const _LiquidBackground(),

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
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 30),
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
          "PANEL DE MÁQUINAS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Control y Recaudación",
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
        title: 'Hacer Recaudación',
        subtitle: 'Registrar cobro y contadores',
        icon: Icons.point_of_sale_rounded,
        color1: const Color(0xFF10B981), // Verde Esmeralda
        color2: const Color(0xFF047857),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HacerRecaudacionScreen())),
      ),
      _ActionItem(
        title: 'Histórico',
        subtitle: 'Consultar recaudaciones pasadas',
        icon: Icons.history_rounded,
        color1: const Color(0xFF3B82F6), // Azul
        color2: const Color(0xFF1E40AF),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecaudacionesScreen())),
      ),
      _ActionItem(
        title: 'Numeraciones',
        subtitle: 'Gestión técnica de máquinas',
        icon: Icons.pin_rounded,
        color1: const Color(0xFF8B5CF6), // Violeta
        color2: const Color(0xFF6D28D9),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NumeracionesScreen())),
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 2 : 1,
        childAspectRatio: isWide ? 1.6 : 1.3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _HeroActionCard(item: actions[index]),
    );
  }
}

// ============================================================================
// COMPONENTES REUTILIZABLES (Estándar Visual Glassmorphism)
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
                // 1. DECORACIÓN DE FONDO
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

                // 2. BRILLO SUPERIOR
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

                // 3. CONTENIDO
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: widget.item.color1.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: widget.item.color1.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                            ]
                        ),
                        child: Icon(widget.item.icon, color: widget.item.color1, size: 36),
                      ),
                      const Spacer(),
                      Text(
                        widget.item.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
                      ),
                      const SizedBox(height: 20),
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

class _LiquidBackground extends StatefulWidget {
  const _LiquidBackground();
  @override
  State<_LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<_LiquidBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final x1 = 0.5 * math.cos(t * 2 * math.pi);
        final y1 = 0.3 * math.sin(t * 2 * math.pi);
        final x2 = -0.5 * math.cos(t * 2 * math.pi + 1);
        final y2 = -0.3 * math.sin(t * 2 * math.pi + 1);
        final x3 = 0.3 * math.cos(t * 2 * math.pi + 2);
        final y3 = 0.5 * math.sin(t * 2 * math.pi + 2);

        return Stack(
          children: [
            Container(color: const Color(0xFFF5F7FA)),
            Align(alignment: Alignment(x1 - 0.5, y1 - 0.5), child: _Blob(color: const Color(0xFF64B5F6), size: 400)),
            Align(alignment: Alignment(x2 + 0.5, y2 + 0.5), child: _Blob(color: const Color(0xFFBA68C8), size: 450)),
            Align(alignment: Alignment(x3, y3), child: _Blob(color: const Color(0xFFFFB74D), size: 350)),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
              child: Container(color: Colors.white.withOpacity(0.4)),
            ),
          ],
        );
      },
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
        gradient: RadialGradient(colors: [color.withOpacity(0.6), color.withOpacity(0.0)], radius: 0.8),
      ),
    );
  }
}