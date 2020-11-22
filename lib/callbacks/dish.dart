import 'package:flutter/material.dart';
import '../model/dish.dart';

typedef DishTapCallback = void Function(BuildContext context, Dish dish);
typedef NoteDragCallback = void Function(BuildContext context, Dish dish);
typedef DishLongPressCallback = void Function(BuildContext context, Dish dish);
typedef DishDismissCallback = void Function(
    BuildContext context, DismissDirection direction, Dish dish);
