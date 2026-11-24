import 'package:flutter/material.dart';

/// Every color in the app, defined once. Widgets use these instead of
/// hard-coded colors, so changing a color here updates the whole app.
class AppColors {
  static const green = Color(0xFF15803D); // App bars, buttons, active nav item
  static const darkGreen = Color(0xFF166534); // Small emphasis text ("128 attended")
  static const lightGreen = Color(0xFFE8F5EC); // "Open" chip, success messages
  static const background = Color(0xFFF6FAF7); // Page background behind cards
  static const white = Color(0xFFFFFFFF); // Cards, inputs, Login screen
  static const text = Color(0xFF1F2937); // Main text
  static const muted = Color(0xFF6B7280); // Secondary text (venue, date)
  static const border = Color(0xFFE5E7EB); // Card and input borders
}
