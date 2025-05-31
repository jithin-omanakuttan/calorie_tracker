import 'package:objectbox/objectbox.dart';
import 'item_entity.dart';
import 'totals_entity.dart';

@Entity()
class MealEntity {
  @Id()
  int id = 0;

  String mealType; // e.g., “Breakfast”, “Lunch”
  DateTime date;   // e.g., 2025-05-31

  /// One meal → many items
  final items = ToMany<ItemEntity>();

  /// One meal → exactly one TotalsEntity
  final totals = ToOne<TotalsEntity>();

  MealEntity({
    required this.mealType,
    required this.date,
  });
}
