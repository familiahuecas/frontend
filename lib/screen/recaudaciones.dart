import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/model/recaudaciones.dart';
import '../apirest/api_service.dart';

class RecaudacionesScreen extends StatefulWidget {
  @override
  _RecaudacionesScreenState createState() => _RecaudacionesScreenState();
}

class _RecaudacionesScreenState extends State<RecaudacionesScreen> with TickerProviderStateMixin {
  List<Recaudaciones> recaudaciones = [];
  int currentPage = 0;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Animaciones de entrada
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchRecaudaciones();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchRecaudaciones();
      }
    });

    // Configuración de animación
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
    _scrollController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecaudaciones() async {
    setState(() => isLoading = true);
    try {
      final recaudacionPage = await ApiService().getRecaudaciones(currentPage, 10);
      setState(() {
        recaudaciones.addAll(recaudacionPage.content);
        currentPage++;
      });
    } catch (e) {
      print("Error cargando recaudaciones: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // 1. FONDO ESTÁTICO
          const _StaticBackground(),

          // 2. CONTENIDO
          SafeArea(
            child: Center(
              // Contenedor restringido
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                      child: _buildHeader(),
                    ),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                            itemCount: recaudaciones.length + (isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == recaudaciones.length) {
                                return Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()));
                              }
                              return _buildCompactMoneyCard(recaudaciones[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
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
        const SizedBox(height: 5),
        Text(
          "Histórico Recaudación",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMoneyCard(Recaudaciones item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // 1. CABECERA
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Icon(Icons.history_edu_rounded, size: 18, color: const Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.bar ?? "Desconocido",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    item.fecha ?? "--/--/--",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            // 2. CUERPO
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Columna TOTAL BRUTO
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TOTAL CAJA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text(
                        "${item.recaudaciontotal}€",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                    ],
                  ),

                  // Columna NETO
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("TU PARTE (50%)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                        SizedBox(height: 2),
                        Text(
                          "${item.recaudacionparcial}€",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. PIE DE PÁGINA
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                children: [
                  _buildMachineTag("M1", item.maquina1, Colors.blue),
                  SizedBox(width: 15),
                  _buildMachineTag("M2", item.maquina2, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CORRECCIÓN AQUÍ: Usamos 'num?' en lugar de 'double?' ---
  Widget _buildMachineTag(String label, num? amount, MaterialColor color) {
    return Row(
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6),
        Text("$label: ", style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        Text(
          "${amount ?? 0}€",
          style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.bold, fontFamily: 'Monospace'),
        ),
      ],
    );
  }
}

// ============================================================================
// FONDO ESTÁTICO
// ============================================================================
class _StaticBackground extends StatelessWidget {
  const _StaticBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFF5F7FA)),
        Positioned(top: -100, left: -100, child: _Blob(color: const Color(0xFF64B5F6), size: 500)),
        Positioned(bottom: -100, right: -100, child: _Blob(color: const Color(0xFFBA68C8), size: 500)),
        Positioned(top: MediaQuery.of(context).size.height * 0.3, right: -50, child: _Blob(color: const Color(0xFFFFB74D), size: 400)),
        Positioned(bottom: 50, left: -80, child: _Blob(color: const Color(0xFF81C784).withOpacity(0.5), size: 350)),
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