// lib/screens/meal_list_screen.dart
import 'package:flutter/material.dart';
import '../widgets/meal_card.dart';

class MealListScreen extends StatefulWidget {
  const MealListScreen({super.key});
  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _meals = [
    {'title': 'Avocado Toast', 'cal': '320 kcal'},
    {'title': 'Berry Smoothie', 'cal': '250 kcal'},
    {'title': 'Quinoa Salad', 'cal': '410 kcal'},
  ];

  late final AnimationController _controller;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimations = List.generate(
      _meals.length,
      (index) {
        final start = index * 0.1;
        final end = start + 0.6;
        return Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );
      },
    );

    _fadeAnimations = List.generate(
      _meals.length,
      (index) {
        final start = index * 0.1;
        final end = start + 0.6;
        return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeIn),
          ),
        );
      },
    );

    // Start the staggered animations
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMealTap(int index) {
    // For example, show meal detail or a toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tapped: ${_meals[index]['title']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meals')),
      body: ListView.builder(
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: _slideAnimations[index],
            child: FadeTransition(
              opacity: _fadeAnimations[index],
              child: MealCard(
                mealTitle: _meals[index]['title']!,
                calories: _meals[index]['cal']!,
                onTap: () => _onMealTap(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
