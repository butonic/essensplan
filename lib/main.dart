import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ober_menu_planner/pages/view_dish.dart';
import 'pages/plan.dart';
import 'pages/dishes.dart';
import 'pages/edit_dish.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'model/category.dart';
import 'model/day.dart';
import 'model/dish.dart';
import 'model/tag.dart';

Box<Category> _categoryBox;
Box<Day> _dayBox;
Box<Dish> _dishBox;
Box<Tag> _tagBox;

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  await Hive.initFlutter();

  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(DayAdapter());
  Hive.registerAdapter(DishAdapter());
  Hive.registerAdapter(TagAdapter());

  _categoryBox = await Hive.openBox<Category>('categoryBox');
  _dayBox = await Hive.openBox<Day>('dayBox');
  _dishBox = await Hive.openBox<Dish>('dishBox');
  _tagBox = await Hive.openBox<Tag>('tagBox');
  initializeDateFormatting('de_DE', null).then((_) => runApp(MyApp()));
  Intl.defaultLocale = "de_DE";
}

// TODO use named routing https://medium.com/flutter-community/flutter-navigation-cheatsheet-a-guide-to-named-routing-dc642702b98c

//A page is considered a stateful widget that covers the entire navigation screen.

// the list needs to build a start and end date
// we can scroll to the current date using the index
// that means we need a data model:
// list of days
// each day can have multiple dishes and notes

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ober Menu Planner',
      initialRoute: '/',
      routes: {
        '/': (context) => PlanPage(),
        '/dishes': (context) => DishesPage(),
        '/dishes/view': (context) => ViewDishPage(),
        '/dishes/edit': (context) => EditDishPage(),
      },
      //home: PlanPage(),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
