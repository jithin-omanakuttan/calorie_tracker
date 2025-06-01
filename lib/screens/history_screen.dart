import 'package:flutter/material.dart';
import '../db/meal_entity.dart';
import '../db/item_entity.dart';
import '../db/totals_entity.dart';
import '../objectbox.g.dart';
import '../constants/colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.store});

  final Store store;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box<MealEntity> mealBox;
  late Box<ItemEntity> itemBox;
  late Box<TotalsEntity> totalsBox;

  final Map<String, bool> _isExpanded = {};
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey();
  List<MealEntity> _meals = [];
  List<_HistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    mealBox = widget.store.box<MealEntity>();
    itemBox = widget.store.box<ItemEntity>();
    totalsBox = widget.store.box<TotalsEntity>();
    _loadMeals();
  }

  void _loadMeals() {
    final query = mealBox.query()
      ..order(MealEntity_.date, flags: Order.descending);
    _meals = query.build().find();
    _entries = _groupMealsByDate(_meals);
    for (var entry in _entries) {
      if (entry.isHeader) _isExpanded[entry.date] = false;
    }
    setState(() {});
  }

  List<_HistoryEntry> _groupMealsByDate(List<MealEntity> meals) {
    final List<_HistoryEntry> entries = [];
    String? lastDate;
    for (final meal in meals) {
      final dateStr = _formatDate(meal.date);
      if (dateStr != lastDate) {
        entries.add(_HistoryEntry.header(dateStr));
        lastDate = dateStr;
      }
      entries.add(_HistoryEntry.meal(meal));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal History")),
      body: CustomScrollView(
        slivers: [
          SliverAnimatedList(
            key: _listKey,
            initialItemCount: _entries.length,
            itemBuilder: (context, index, animation) {
              final entry = _entries[index];
              if (entry.isHeader) {
                return _buildDateHeader(entry.date, animation);
              } else {
                return _buildMealTile(entry.meal!, animation, entry.date);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date, Animation<double> animation) {
    final expanded = _isExpanded[date] ?? false;
    return SizeTransition(
      sizeFactor: animation,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded[date] = !expanded;
                });
              },
              child: Container(
                color: AppColors.deepPurple.withAlpha((0.8 * 255).round()),
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.mintGreen,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              ..._entries
                  .where((e) => !e.isHeader && e.date == date)
                  .map((e) => _buildMealTile(e.meal!, kAlwaysCompleteAnimation, date)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTile(MealEntity meal, Animation<double> animation, String date) {
    final totals = totalsBox.query(TotalsEntity_.meal.equals(meal.id)).build().findFirst();
    final items = meal.items;
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ExpansionTile(
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            "${meal.mealType} • ${_formatDate(meal.date)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: totals != null ? Text("Total Calories: ${totals.calories}") : null,
          children: [
            if (totals != null) _buildTotalsRow(totals),
            ...items.map((it) => _buildItemRow(it)),
          ],
        ),
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
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }
}

class _HistoryEntry {
  final String date;
  final MealEntity? meal;
  final bool isHeader;
  _HistoryEntry.header(this.date)
      : meal = null,
        isHeader = true;
  _HistoryEntry.meal(MealEntity this.meal)
      : date = "${meal.date.year.toString().padLeft(4, '0')}-${meal.date.month.toString().padLeft(2, '0')}-${meal.date.day.toString().padLeft(2, '0')}",
        isHeader = false;
}

const kAlwaysCompleteAnimation = AlwaysStoppedAnimation<double>(1.0);
