import 'package:objectbox/objectbox.dart';

import 'meal_entity.dart';

@Entity()
class ItemEntity {
  @Id()
  int id = 0;

  String name;
  int quantity;
  String details;

  /// This links back to the parent meal.
  final meal = ToOne<MealEntity>();

  ItemEntity({
    required this.name,
    required this.quantity,
    required this.details,
  });
}
