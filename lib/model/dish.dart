import 'package:hive_ce/hive.dart';
import 'category.dart';

part 'dish.g.dart';

@HiveType(typeId: 0)
class Dish extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? note;

  @HiveField(2)
  HiveList<Category>? categories;

  //@HiveField(3)
  //HiveList<Tag>? tags; // was never used

  @HiveField(4)
  bool? deleted;

  int lastCookedDay;

  Dish({this.name, this.note, this.deleted = false, this.lastCookedDay = -1});
}
