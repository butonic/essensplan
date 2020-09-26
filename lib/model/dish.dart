import 'dart:convert';

Dish dishFromJson(String str) {
  final jsonData = json.decode(str);
  return Dish.fromMap(jsonData);
}

String dishToJson(Dish data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Dish {
  int id;
  String name;
  String note;

  Dish({
    this.id,
    this.name,
    this.note,
  });

  factory Dish.fromMap(Map<String, dynamic> json) => new Dish(
        id: json["id"],
        name: json["name"],
        note: json["note"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "note": note,
      };
}