import 'package:flutter/material.dart';

final class ConveyGridTheme {
  const ConveyGridTheme({
    this.primaryColor = const Color(0xFF2F64F5),
    this.secondaryColor = const Color(0xFF0F172A),
    this.surfaceColor = Colors.white,
    this.borderRadius = 16,
    this.spacing = 16,
    this.useBottomSheet = true,
    this.titleTextStyle,
    this.bodyTextStyle,
    this.buttonTextStyle,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final double borderRadius;
  final double spacing;
  final bool useBottomSheet;
  final TextStyle? titleTextStyle;
  final TextStyle? bodyTextStyle;
  final TextStyle? buttonTextStyle;
}
