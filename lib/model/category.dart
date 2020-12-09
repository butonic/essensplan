import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String id;

  @HiveField(2)
  int color;

  @HiveField(3)
  int order;

  Category({
    this.name,
    this.id,
    this.color,
    this.order,
  });
  String operator [](String id) {
    return name;
  }
}
