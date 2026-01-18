import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/apirest/api_service.dart';

import '../model/recaudacionrequest.dart';
import '../model/recaudacionresponse.dart';

class HacerRecaudacionScreen extends StatefulWidget {
  @override
  _HacerRecaudacionScreenState createState() => _HacerRecaudacionScreenState();
}

class _HacerRecaudacionScreenState extends State<HacerRecaudacionScreen> with TickerProviderStateMixin {
  final TextEditingController entradaM1Controller = TextEditingController();
  final TextEditingController salidaM1Controller = TextEditingController();
  final TextEditingController entradaM2Controller = TextEditingController();
  final TextEditingController salidaM2Controller = TextEditingController();

  final ApiService apiService = ApiService();
  bool isCalculating = false;

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
    entradaM1Controller.dispose();
    salidaM1Controller.dispose();
    entradaM2Controller.dispose();
    salidaM2Controller.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onAceptarPressed() async {
    if (entradaM1Controller.text.isEmpty ||
        salidaM1Controller.text.isEmpty ||
        entradaM2Controller.text.isEmpty ||
        salidaM2Controller.text.isEmpty) {
      _showErrorDialog('Por favor, rellena todos los contadores.');
      return;
    }

    if (int.tryParse(entradaM1Controller.text) == null ||
        int.tryParse(salidaM1Controller.text) == null ||
        int.tryParse(entradaM2Controller.text) == null ||
        int.tryParse(salidaM2Controller.text) == null) {
      _showErrorDialog('Los contadores deben ser numéricos.');
      return;
    }

    setState(() => isCalculating = true);

    try {
      Recaudacionrequest request = Recaudacionrequest(
        bar: "lucy",
        entradaM1: int.parse(entradaM1Controller.text),
        salidaM1: int.parse(salidaM1Controller.text),
        entradaM2: int.parse(entradaM2Controller.text),
        salidaM2: int.parse(salidaM2Controller.text),
      );

      Recaudacionresponse response = await apiService.calculateRec(request);

      _showResultDialog(response);

      await apiService.guardarRecaudacion(request);

    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => isCalculating = false);
    }
  }

  void _showResultDialog(Recaudacionresponse response) {
    // CAMBIO: Cálculo actualizado al 50%
    double porcentajeM1 = (response.totalm1 ?? 0) * 0.50;
    double porcentajeM2 = (response.totalm2 ?? 0) * 0.50;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Resultados Completos'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECCIÓN M1
                _buildResultSection(
                  title: 'Máquina 1 (Unidesa)',
                  color: Colors.blue,
                  lines: [
                    'Entrada Actual: ${response.entradaM1}',
                    'Salida Actual: ${response.salidaM1}',
                    'Entrada Anterior: ${response.lastEntradaM1}',
                    'Salida Anterior: ${response.lastSalidaM1}',
                  ],
                  totalBruto: response.totalm1,
                  porcentaje: porcentajeM1,
                ),
                SizedBox(height: 16),

                // SECCIÓN M2
                _buildResultSection(
                  title: 'Máquina 2 (Franco)',
                  color: Colors.orange,
                  lines: [
                    'Entrada Actual: ${response.entradaM2}',
                    'Salida Actual: ${response.salidaM2}',
                    'Entrada Anterior: ${response.lastEntradaM2}',
                    'Salida Anterior: ${response.lastSalidaM2}',
                  ],
                  totalBruto: response.totalm2,
                  porcentaje: porcentajeM2,
                ),

                Divider(height: 30, thickness: 1),

                // TOTALES FINALES
                Text('RESUMEN FINAL', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.0)),
                SizedBox(height: 10),
                _buildTotalRow('Total Caja:', '${response.total?.toStringAsFixed(2)} €', isBold: true, fontSize: 18),
                _buildTotalRow('A cada uno:', '${response.totalCadaUno?.toStringAsFixed(2)} €', color: const Color(0xFF10B981), isBold: true, fontSize: 18),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultSection({
    required String title,
    required Color color,
    required List<String> lines,
    double? totalBruto,
    double? porcentaje,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 16, color: color, margin: EdgeInsets.only(right: 8)),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 14)),
          ],
        ),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contadores
              ...lines.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(l, style: TextStyle(fontSize: 12, fontFamily: 'Monospace', color: Colors.grey[700])),
              )).toList(),

              Divider(height: 16),

              // Totales de la máquina
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recaudado:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text("${totalBruto?.toStringAsFixed(2) ?? '0.00'} €", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CAMBIO: Etiqueta actualizada
                  Text("Parte (50%):", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  Text("${porcentaje?.toStringAsFixed(2) ?? '0.00'} €", style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ... (El resto del código: _buildTotalRow, _showErrorDialog, build, _buildHeader, _buildFormCard, _buildSectionTitle, _buildGlassInput y clases de fondo _StaticBackground y _Blob se mantienen idénticos)

  // Incluyo el resto para que puedas copiar y pegar el archivo completo sin errores:

  Widget _buildTotalRow(String label, String value, {bool isBold = false, Color? color, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, color: Colors.grey[800])),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.w900 : FontWeight.normal, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 10), Text('Error')]),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar', style: TextStyle(color: Colors.red)))],
      ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 30),
                          _buildFormCard(),
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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          "Nueva Recaudación",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("UNIDESA", Icons.gamepad_rounded),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildGlassInput(controller: entradaM1Controller, label: 'Entrada M1', icon: Icons.input_rounded)),
              const SizedBox(width: 15),
              Expanded(child: _buildGlassInput(controller: salidaM1Controller, label: 'Salida M1', icon: Icons.output_rounded)),
            ],
          ),

          const SizedBox(height: 30),

          _buildSectionTitle("FRANCO", Icons.casino_rounded),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildGlassInput(controller: entradaM2Controller, label: 'Entrada M2', icon: Icons.input_rounded)),
              const SizedBox(width: 15),
              Expanded(child: _buildGlassInput(controller: salidaM2Controller, label: 'Salida M2', icon: Icons.output_rounded)),
            ],
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isCalculating ? null : _onAceptarPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: const Color(0xFF10B981).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isCalculating
                  ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_rounded),
                  const SizedBox(width: 10),
                  Text('Calcular y Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.0),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(Icons.close_rounded, size: 16, color: Colors.grey[400]),
            onPressed: () => controller.clear(),
          ),
        ),
      ),
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