import 'dart:ui';
import 'package:flutter/material.dart';
import '../apirest/api_service.dart';

class AplicacionesListScreen extends StatefulWidget {
  const AplicacionesListScreen({Key? key}) : super(key: key);

  @override
  State<AplicacionesListScreen> createState() => _AplicacionesListScreenState();
}

class _AplicacionesListScreenState extends State<AplicacionesListScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _aplicaciones = [];
  bool _isLoading = true;
  String? _error;

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _loadAplicaciones();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _loadAplicaciones() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final apps = await _apiService.getAplicaciones();
      setState(() {
        _aplicaciones = apps;
        _isLoading = false;
      });
      _entryController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _entryController.forward();
    }
  }

  Future<void> _downloadApp(int id, String fileName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Descargando $fileName...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      await _apiService.downloadAppWeb(id, fileName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName descargado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteApp(int id, String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar aplicación'),
        content: Text('¿Estás seguro de que deseas eliminar "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Eliminando $fileName...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      await _apiService.deleteApp(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAplicaciones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.black87, size: 20),
            ),
            onPressed: _loadAplicaciones,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const _StaticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        Expanded(child: _buildContent()),
                      ],
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
          "DESCARGAR",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Aplicaciones Disponibles",
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar aplicaciones',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAplicaciones,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_aplicaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay aplicaciones disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Las aplicaciones subidas apareceran aqui',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _aplicaciones.length,
      itemBuilder: (context, index) {
        final app = _aplicaciones[index];
        return _AppCard(
          app: app,
          onDownload: () => _downloadApp(app['id'], app['nombre']),
          onDelete: () => _deleteApp(app['id'], app['nombre']),
        );
      },
    );
  }
}

class _AppCard extends StatefulWidget {
  final Map<String, dynamic> app;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _AppCard({required this.app, required this.onDownload, required this.onDelete});

  @override
  State<_AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<_AppCard> {
  bool _isHovered = false;

  IconData _getAppIcon(String nombre) {
    final ext = nombre.split('.').last.toLowerCase();
    switch (ext) {
      case 'apk':
        return Icons.android;
      case 'ipa':
        return Icons.phone_iphone;
      case 'exe':
        return Icons.computer;
      case 'dmg':
        return Icons.laptop_mac;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      default:
        return Icons.apps;
    }
  }

  Color _getAppColor(String nombre) {
    final ext = nombre.split('.').last.toLowerCase();
    switch (ext) {
      case 'apk':
        return const Color(0xFF3DDC84); // Android green
      case 'ipa':
        return const Color(0xFF007AFF); // iOS blue
      case 'exe':
        return const Color(0xFF00A4EF); // Windows blue
      case 'dmg':
        return const Color(0xFFA2AAAD); // macOS gray
      default:
        return const Color(0xFF6366F1); // Default indigo
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.app['nombre'] ?? 'Sin nombre';
    final appColor = _getAppColor(nombre);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_isHovered ? 1.0 : 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? appColor.withOpacity(0.3) : Colors.white.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: appColor.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getAppIcon(nombre),
              color: appColor,
              size: 28,
            ),
          ),
          title: Text(
            nombre,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: widget.app['fechaCreacion'] != null
              ? Text(
                  'Subido: ${_formatDate(widget.app['fechaCreacion'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: appColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: widget.onDownload,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.download_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Descargar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: widget.onDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
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
        Positioned(top: -100, left: -100, child: _Blob(color: const Color(0xFF6366F1), size: 500)),
        Positioned(bottom: -100, right: -100, child: _Blob(color: const Color(0xFF8B5CF6), size: 500)),
        Positioned(top: MediaQuery.of(context).size.height * 0.4, right: -50, child: _Blob(color: const Color(0xFF06B6D4), size: 400)),
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
