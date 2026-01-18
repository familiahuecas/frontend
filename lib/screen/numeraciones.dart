import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/model/numeracion.dart';
import '../apirest/api_service.dart';

class NumeracionesScreen extends StatefulWidget {
  @override
  _NumeracionesScreenState createState() => _NumeracionesScreenState();
}

class _NumeracionesScreenState extends State<NumeracionesScreen> with TickerProviderStateMixin {
  List<Numeracion> numeraciones = [];
  int currentPage = 0;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchNumeraciones();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent &&
          !isLoading) {
        _fetchNumeraciones();
      }
    });

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

  Future<void> _fetchNumeraciones() async {
    setState(() => isLoading = true);
    try {
      final numeracionPage = await ApiService().getNumeraciones(currentPage, 10);
      setState(() {
        numeraciones.addAll(numeracionPage.content);
        currentPage++;
      });
    } catch (e) {
      print("Error cargando numeraciones: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteNumeracion(int id) async {
    await ApiService().deleteNumeracion(id);
    setState(() {
      numeraciones.removeWhere((numeracion) => numeracion.id == id);
    });
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red), SizedBox(width: 10), Text('Eliminar')]),
          content: Text('¿Estás seguro de que deseas eliminar esta numeración?'),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNumeracion(id);
              },
            ),
          ],
        );
      },
    );
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
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const _StaticBackground(),

          SafeArea(
            child: Center(
              // CAMBIO AQUÍ: Contenedor restringido para que no ocupe todo el ancho
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), // Ancho máximo controlado
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
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5), // Un poco más de margen lateral
                            itemCount: numeraciones.length + (isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == numeraciones.length) {
                                return Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()));
                              }
                              return _buildCompactCard(numeraciones[index]);
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
          "GESTIÓN TÉCNICA",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        Text(
          "Numeraciones",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0),
        ),
      ],
    );
  }

  Widget _buildCompactCard(Numeracion numeracion) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Icon(Icons.store_mall_directory_rounded, size: 18, color: const Color(0xFF8B5CF6)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      numeracion.bar ?? "Desconocido",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    numeracion.fecha ?? "--/--/--",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showDeleteConfirmationDialog(numeracion.id),
                    child: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red[300]),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  _buildMachineCompactRow(
                      "M1",
                      Icons.looks_one_rounded,
                      Colors.blue[700]!,
                      numeracion.entrada_m1,
                      numeracion.salida_m1
                  ),
                  SizedBox(height: 6),
                  _buildMachineCompactRow(
                      "M2",
                      Icons.looks_two_rounded,
                      Colors.orange[800]!,
                      numeracion.entrada_m2,
                      numeracion.salida_m2
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineCompactRow(String label, IconData icon, Color color, int? entrada, int? salida) {
    return Row(
      children: [
        Container(
          width: 50,
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactValue("Ent:", entrada.toString()),
              _buildCompactValue("Sal:", salida.toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactValue(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        SizedBox(width: 4),
        Text(
            value,
            style: TextStyle(fontSize: 13, fontFamily: 'Monospace', fontWeight: FontWeight.w600, color: Colors.grey[800])
        ),
      ],
    );
  }
}

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