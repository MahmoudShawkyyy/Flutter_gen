import 'package:flutter/material.dart';

/// Generic fade + slide transition for all pages
Route createRoute(Widget page, {Offset beginOffset = const Offset(0.0, 0.1)}) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slideTween =
          Tween<Offset>(begin: beginOffset, end: Offset.zero).chain(
        CurveTween(curve: Curves.easeInOut),
      );
      return SlideTransition(
        position: curved.drive(slideTween),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
