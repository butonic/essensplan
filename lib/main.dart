import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:essensplan/pages/view_dish.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'pages/plan.dart';
import 'pages/dishes.dart';
import 'pages/categories.dart';
import 'pages/edit_dish.dart';
import 'model/category.dart';
import 'model/day.dart';
import 'model/dish.dart';
import 'model/tag.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  await Hive.initFlutter();

  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(DayAdapter());
  Hive.registerAdapter(DishAdapter());
  Hive.registerAdapter(TagAdapter());

  // open hive boxes
  await Hive.openBox<Category>('categoryBox');
  await Hive.openBox<Day>('dayBox');
  await Hive.openBox<Dish>('dishBox');
  await Hive.openBox<Tag>('tagBox');

  Intl.defaultLocale = 'de_DE';

  timeago.setLocaleMessages('de', timeago.DeMessages());
  await initializeDateFormatting('de_DE', null)
      .then((_) => runApp(EssensplanApp()));

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.lightGreen,
  ));
}

//A page is considered a stateful widget that covers the entire navigation screen.

// the list needs to build a start and end date
// we can scroll to the current date using the index
// that means we need a data model:
// list of days
// each day can have multiple dishes and notes

class EssensplanApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essensplan',
      initialRoute: '/',
      routes: {
        '/': (context) => PlanPage(),
        '/dishes': (context) => DishesPage(),
        '/dishes/view': (context) => ViewDishPage(),
        '/dishes/edit': (context) => EditDishPage(),
        '/categories': (context) => CategoriesPage(),
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
        primarySwatch: Colors.lightGreen,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

// TODO ValueListenableBuilder verstehen um auf änderungen in hive zu reagieren
// und die ui dann neu zu bauen wenn sich was in hive ändert.
// siehe https://awaik.medium.com/hive-for-flutter-fast-local-storage-database-made-with-dart-167ad63e2d1
