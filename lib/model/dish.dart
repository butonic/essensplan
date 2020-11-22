import 'package:hive/hive.dart';
import 'category.dart';
import 'tag.dart';

part 'dish.g.dart';

@HiveType(typeId: 0)
class Dish extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String note;

  @HiveField(2)
  HiveList<Category> categories;

  @HiveField(3)
  HiveList<Tag> tags;

  @HiveField(4)
  bool deleted;

  Dish({
    this.name,
    this.note,
  });
}
