
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:english_words/english_words.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'DishModel.dart';

import 'Database.dart';

void main() {
  initializeDateFormatting('de_DE', null).then((_) =>  runApp(MyApp()));
  Intl.defaultLocale = "de_DE";
}

// the list needs to build a start and end date
// we can scroll to the current date using the index
// that means we need a data model:
// list of days
// each day can have multiple dishes and notes
//
double _fontSize = 14;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ober Menu Planner',
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
      home: PlanPage(title: 'Planung'),
    );
  }
}

class PlanPage extends StatefulWidget {
  PlanPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final Set<WordPair> _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now().toUtc();
    var currentDay = now.difference(epoch).inDays; // ~18k -> 20k*2 = 40k for now
    return Scaffold(
      appBar: AppBar(
        title: Text('Planung'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.calendar_today), onPressed: (){
            itemScrollController.scrollTo(
              index: currentDay,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic);
            }
          ),
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: ScrollablePositionedList.builder(
        initialScrollIndex: currentDay,
        padding: const EdgeInsets.all(4.0),
        itemCount: 40000,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, i) {
          return _buildRow(i);
        }
      )
    );
  }

Future<ListTile> _buildDayTile(int day) async {
  List<Dish> dishes = await DBProvider.db.getDay(day);
    var d = epoch.add(Duration(days: day));
  return ListTile(
      leading: Text(DateFormat('E\ndd.MM.yy').format(d)),
      title:
        Column(
          children: List.generate(dishes.length, (i) {
            if (dishes[i].name != null) {
              return Text(dishes[i].name);
            } else {
              return Text("Note: " + dishes[i].note);
            }
          })
        ),
        onTap: () {
          // add a note
          // TODO show the list of dishes and allow selecting?
          setState(() {
            DBProvider.db.addDishToDay(day, 0, null, "something on this day");
          });
        }
    );

}

  Widget _buildRow(int day) {
    return new FutureBuilder<ListTile>(
      future: _buildDayTile(day),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return snapshot.data;
          } else {
            return new Text("No Data found");
          }
        }
        return new Container(alignment: AlignmentDirectional.center,child: new CircularProgressIndicator(),);
      }
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}