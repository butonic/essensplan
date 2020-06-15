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
  String firstName;
  String lastName;
  bool blocked;

  Dish({
    this.id,
    this.firstName,
    this.lastName,
    this.blocked,
  });

  factory Dish.fromMap(Map<String, dynamic> json) => new Dish(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        blocked: json["blocked"] == 1,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "blocked": blocked,
      };
}