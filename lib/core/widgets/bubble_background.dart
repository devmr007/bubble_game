import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BubbleBackground extends StatelessWidget {
  final Widget child;
  final Color? color;

  const BubbleBackground({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: color ?? AppColors.background,
      child: child,
    );
  }
}
