import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get modal => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 32,
          offset: const Offset(0, 20),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get input => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 80,
          offset: const Offset(0, 32),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 1,
          offset: const Offset(0, 0),
        ),
      ];

  static List<BoxShadow> get bubble => [
        BoxShadow(
          color: const Color(0xFF6450C8).withOpacity(0.1),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get petGlow => [
        BoxShadow(
          color: const Color(0xFF6450C8).withOpacity(0.18),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}
