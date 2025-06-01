import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../db/meal_entity.dart';
import '../db/item_entity.dart';
import '../db/totals_entity.dart';
import '../objectbox.g.dart';

class HistoryScreen extends StatefulWidget {
  final Store store;
  const HistoryScreen({Key? key, required this.store}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box<MealEntity> mealBox;
  late Box<ItemEntity> itemBox;
  late Box<TotalsEntity> totalsBox;

  List<MealEntity> _meals = [];

  @override
  void initState() {
    super.initState();
    mealBox = widget.store.box<MealEntity>();
    itemBox = widget.store.box<ItemEntity>();
    totalsBox = widget.store.box<TotalsEntity>();
    _loadMeals();
  }

  void _loadMeals() {
    // Query all MealEntity objects, ordered by date descending
    final query = mealBox.query()
      ..order(MealEntity_.date, flags: Order.descending);
    _meals = query.build().find();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal History")),
      body: ListView.builder(
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          final meal = _meals[index];
          // Fetch associated totals
          final totals = meal.totals.target;
          // Fetch associated items
          final items = meal.items;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ExpansionTile(
              title: Text(
                "${meal.mealType} • ${_formatDate(meal.date)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: totals != null
                  ? Text("Total Calories: ${totals.calories}")
                  : null,
              children: [
                if (totals != null) _buildTotalsRow(totals),
                ...items.map((it) => _buildItemRow(it)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalsRow(TotalsEntity totals) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Calories: ${totals.calories} kcal"),
          Text("Protein: ${totals.proteinG} g"),
          Text("Fat: ${totals.fatG} g"),
          Text("Carbs: ${totals.carbohydratesG} g"),
          Text("Fiber: ${totals.fiberG} g"),
          Text("Sugar: ${totals.sugarG} g"),
        ],
      ),
    );
  }

  Widget _buildItemRow(ItemEntity item) {
    return ListTile(
      title: Text("${item.name} (x${item.quantity})"),
      subtitle: Text(item.details),
    );
  }

  String _formatDate(DateTime dt) {
    // Format as YYYY-MM-DD
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }
}
