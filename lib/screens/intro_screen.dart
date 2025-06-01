import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: GlassmorphicContainer(
          width: 320,
          height: 420,
          borderRadius: 24,
          blur: 18,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              theme.colorScheme.onPrimary.withAlpha((0.10 * 255).round()),
              theme.colorScheme.onPrimary.withAlpha((0.05 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [
              theme.colorScheme.onPrimary.withAlpha((0.50 * 255).round()),
              theme.colorScheme.onPrimary.withAlpha((0.50 * 255).round()),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Calorie Tracker',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/chat');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: theme.textTheme.titleMedium,
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
