import 'package:hive/hive.dart';
import 'dish.dart';

part 'day.g.dart';

@HiveType(typeId: 3)
class Day extends HiveObject {
  @HiveField(0)
  HiveList<Dish>? entries;

  Day();
}
