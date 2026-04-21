import 'package:flutter/material.dart';

class AppTransitions {
  // 1. Slide Up (Sesuai slide_up.xml)
  static Route slideUp(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0); // dari bawah (100%)
        const end = Offset.zero;        // ke tempat semula (0%)
        // decelerate_quad di Android setara dengan easeOutQuad di Flutter
        const curve = Curves.easeOutQuad; 

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // 2. Slide Down (Sesuai slide_down.xml)
  static Route slideDown(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset.zero;      // dari tempat semula (0%)
        const end = Offset(0.0, 1.0);   // ke bawah (100%)
        // accelerate_quad di Android setara dengan easeInQuad di Flutter
        const curve = Curves.easeInQuad;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // 3. Fade Out (Sesuai fade_out.xml)
  static Route fadeOut(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 1.0; // fromAlpha
        const end = 0.0;   // toAlpha

        var tween = Tween(begin: begin, end: end);

        // Karena ini pindah halaman, biasanya gabungan fade in/out. 
        // Kalau lu pengen strictly fade out layarnya:
        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}