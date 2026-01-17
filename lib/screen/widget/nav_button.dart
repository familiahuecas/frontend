import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// Botón de navegación elegante con efectos hover y animaciones
/// Usado en las pantallas hub (Home, Usuarios, Gestión, etc.)
class NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isCompact;

  const NavButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? AppColors.primary;
    final bgColor = widget.backgroundColor ?? AppColors.surface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  vertical: widget.isCompact ? AppSpacing.md : AppSpacing.lg,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: _isHovered ? AppColors.surfaceVariant : bgColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: _isHovered ? iconColor.withOpacity(0.3) : AppColors.border,
                    width: _isHovered ? 1.5 : 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: iconColor.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : AppShadows.sm,
                ),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono con fondo circular
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? iconColor.withOpacity(0.15)
                      : iconColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: iconColor,
                  size: widget.isCompact ? 28 : 32,
                ),
              ),
              SizedBox(height: widget.isCompact ? AppSpacing.sm : AppSpacing.md),
              // Label
              Text(
                widget.label,
                style: AppTypography.labelLarge.copyWith(
                  color: _isHovered ? iconColor : AppColors.textPrimary,
                  fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Versión con gradiente del botón de navegación
class NavButtonGradient extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final LinearGradient? gradient;

  const NavButtonGradient({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.gradient,
  }) : super(key: key);

  @override
  State<NavButtonGradient> createState() => _NavButtonGradientState();
}

class _NavButtonGradientState extends State<NavButtonGradient> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppColors.primaryGradient;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: _isHovered ? AppShadows.primaryGlow : AppShadows.md,
          ),
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -2.0))
              : Matrix4.identity(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.textOnPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.label,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget contenedor para grid de botones de navegación
class NavButtonGrid extends StatelessWidget {
  final List<NavButton> buttons;
  final int crossAxisCount;
  final double spacing;

  const NavButtonGrid({
    Key? key,
    required this.buttons,
    this.crossAxisCount = 2,
    this.spacing = AppSpacing.md,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // En móvil, usar una columna simple
        if (constraints.maxWidth < 500) {
          return Column(
            children: buttons
                .map((button) => Padding(
                      padding: EdgeInsets.only(bottom: spacing),
                      child: button,
                    ))
                .toList(),
          );
        }

        // En pantallas más grandes, usar grid
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1.5,
          children: buttons,
        );
      },
    );
  }
}
