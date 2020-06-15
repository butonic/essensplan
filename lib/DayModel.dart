import 'dart:convert';
import 'DishModel.dart';

Day dayFromJson(String str) {
  final jsonData = json.decode(str);
  return Day.fromMap(jsonData);
}

String dayToJson(Day data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Day {
  DateTime day;
  List dishes;

  Day({
    this.day,
    this.dishes,
  });

  factory Day.fromMap(Map<String, dynamic> json) => new Day(
        day: json["day"],
        dishes: json["dishes"],
      );

  Map<String, dynamic> toMap() => {
        "day": day,
        "dishes": dishes,
      };
}