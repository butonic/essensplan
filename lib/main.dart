
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(MyApp());
}

// the list needs to build a start and end date
// we can scroll to the current date using the index
// that means we need a data model:
// list of days
// each day can have multiple dishes and notes
//
const String MIN_DATETIME = '2019-05-15 20:10:55';
const String MAX_DATETIME = '2019-07-01 12:30:40';
const String INIT_DATETIME = '2019-05-16 09:00:58';
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
  final _days = <WordPair>[];
  final Set<WordPair> _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    //List<Item> lst = _tagStateKey.currentState?.getAllItem; lst.forEach((f) => print(f.title));
    return Scaffold(
      appBar: AppBar(
        title: Text('Planung'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildPlan(),
    );
  }

  Widget _buildPlan() {
    return ListView.builder(
        padding: const EdgeInsets.all(4.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= _days.length) {
            _days.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_days[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      leading: Text("4. Jul"),
      title:
        Column(
          children: [
            OutlineButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(4.0),
              ),
              onPressed: () {
                /*...*/
              },
              child: Text(pair.asPascalCase + " might be an interesting company name, who knows?"),
            ),
            OutlineButton(
              onPressed: () {
                /*...*/
              },
              child: Text("add"),
            ),
          ],
        ),
        /*
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      */
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
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