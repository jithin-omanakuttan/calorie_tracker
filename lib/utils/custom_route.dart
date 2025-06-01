import 'package:flutter/material.dart';
import '../screens/intro_screen.dart';
import '../screens/chat_screen.dart';

Route<T> fadeSlideRoute<T>({
  required Widget page,
  Duration duration = const Duration(milliseconds: 400),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Fade transition
      final fadeTween = Tween<double>(begin: 0, end: 1)
          .chain(CurveTween(curve: Curves.easeInOut));
      // Slide from right to left
      final slideTween = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        ),
      );
    },
  );
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => const IntroScreen());
    case '/chat':
      return MaterialPageRoute(builder: (context) => const ChatScreen());
    // Add more routes as needed
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}
