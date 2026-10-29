import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.icon,
    this.isLoading = false,
    this.height = 54,
    this.width,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        widget.gradient ??
        (widget.backgroundColor != null ? null : AppColors.buttonPrimary);

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  (_isPressed
                          ? Colors.transparent
                          : (widget.backgroundColor ?? AppColors.primaryDark))
                      .withValues(alpha: 0.4),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onHighlightChanged: (pressed) {
              setState(() => _isPressed = pressed);
            },
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Text(widget.text, style: AppStyles.buttonText),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
