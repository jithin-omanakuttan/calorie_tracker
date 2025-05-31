import 'package:objectbox/objectbox.dart';

import 'meal_entity.dart';

@Entity()
class TotalsEntity {
  @Id()
  int id = 0;

  int calories;
  double proteinG;
  double fatG;
  double carbohydratesG;
  double fiberG;
  double sugarG;

  /// Link back to the parent meal:
  final meal = ToOne<MealEntity>();

  TotalsEntity({
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbohydratesG,
    required this.fiberG,
    required this.sugarG,
  });
}
