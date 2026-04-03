import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../responsive/app_responsive.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({super.key, required this.label, this.onPressed, this.icon, this.isLoading = false});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final buttonHeight = AppResponsive.isTablet(context) ? 58.0 : 54.0;
    final fontSize = AppResponsive.scaleText(context, 16);
    final foregroundColor = isDisabled ? AppTheme.lightGrey.withValues(alpha: 0.78) : AppTheme.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.985 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDisabled ? null : widget.onPressed,
          child: Ink(
            width: double.infinity,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isDisabled
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                    ),
              color: isDisabled ? AppTheme.dark600.withValues(alpha: 0.92) : null,
              border: Border.all(color: isDisabled ? AppTheme.dark500 : AppTheme.primaryGreenLight.withValues(alpha: 0.45)),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 22,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!isDisabled)
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.20),
                              Colors.white.withValues(alpha: 0.02),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.25, 0.5],
                          ),
                        ),
                      ),
                    ),
                  if (!isDisabled)
                    IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          return FractionalTranslation(
                            translation: Offset(-1.6 + (_shimmerController.value * 3.2), 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: _pressed ? 0.08 : 0.16),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: foregroundColor),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon, color: foregroundColor),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.label,
                                style: TextStyle(
                                  color: foregroundColor,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25,
                                  shadows: isDisabled
                                      ? null
                                      : [
                                          Shadow(
                                            color: AppTheme.dark900.withValues(alpha: 0.35),
                                            blurRadius: 6,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
