import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String id;

  Category({
    this.name,
    this.id,
  });
  String operator [](String id) {
    return name;
  }
}
