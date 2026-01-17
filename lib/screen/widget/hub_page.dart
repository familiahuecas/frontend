import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'common_header.dart';

/// Modelo de datos para un item de navegación en una pantalla hub
class HubNavItem {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const HubNavItem({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}

/// Widget contenedor para pantallas hub con estilo consistente
class HubPage extends StatelessWidget {
  final String title;
  final List<HubNavItem> items;
  final Widget? header;

  const HubPage({
    Key? key,
    required this.title,
    required this.items,
    this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonHeader(title: title),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? AppSpacing.xxl : AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (header != null) ...[
                  header!,
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Título de sección
                _buildSectionTitle(),
                const SizedBox(height: AppSpacing.md),

                // Lista de opciones
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _HubNavCard(item: item),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Opciones disponibles',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HubNavCard extends StatefulWidget {
  final HubNavItem item;

  const _HubNavCard({required this.item});

  @override
  State<_HubNavCard> createState() => _HubNavCardState();
}

class _HubNavCardState extends State<_HubNavCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.item.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.item.color.withOpacity(0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isHovered
                  ? widget.item.color.withOpacity(0.25)
                  : AppColors.border,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.item.color.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : AppShadows.sm,
          ),
          transform: _isPressed
              ? (Matrix4.identity()..scale(0.98))
              : (_isHovered
                  ? (Matrix4.identity()..translate(0.0, -2.0))
                  : Matrix4.identity()),
          transformAlignment: Alignment.center,
          child: Row(
            children: [
              // Icono
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.item.color.withOpacity(0.15)
                      : widget.item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.color,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.label,
                      style: AppTypography.h4.copyWith(
                        color: _isHovered
                            ? widget.item.color
                            : AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.item.subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Flecha
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? widget.item.color.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: _isHovered ? widget.item.color : AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
