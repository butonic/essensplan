import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hive/hive.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/dish.dart';
import '../model/category.dart';
import '../pages/edit_dish.dart';

class ViewDishPage extends StatefulWidget {
  ViewDishPage({Key key}) : super(key: key);

  @override
  _ViewDishPageState createState() => _ViewDishPageState();
}

class _ViewDishPageState extends State<ViewDishPage> {
  static final GlobalKey<ScaffoldState> _viewDishKey =
      new GlobalKey<ScaffoldState>();

  Dish dish;

  Widget build(BuildContext context) {
    if (dish == null) {
      final ViewDishArguments args = ModalRoute.of(context).settings.arguments;
      dish = args.dish;
    }
    return Scaffold(
      key: _viewDishKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Gericht"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 4, 0),
                child: Text(
                  "Name",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.left,
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(32, 20, 32, 4),
                child: Text(
                  dish.name,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.left,
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 4, 0),
                child: Text(
                  "Notizen",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.left,
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(32, 20, 32, 4),
                child: SelectableLinkify(
                  style: dish.note.isEmpty
                      ? TextStyle(
                          color: Colors.black45, fontStyle: FontStyle.italic)
                      : null,
                  text: dish.note.isEmpty ? "Keine Notiz" : dish.note,
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Konnte $link nicht öffnen';
                    }
                  },
                )),
            Divider(),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Tags(
                  itemCount: dish.categories.length,
                  itemBuilder: (int index) {
                    final c = dish.categories.elementAt(index);

                    return ItemTags(
                      key: Key(index.toString()),
                      index: index,
                      title: c.name,
                      active: true,
                      activeColor:
                          c.color != null ? Color(c.color) : Colors.grey,
                      border: Border.all(
                          color:
                              c.color != null ? Color(c.color) : Colors.grey),
                      customData: c,
                      pressEnabled: false,
                    );
                  },
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _editDish(context, dish).then((res) {
            setState(() {});
          });
        },
        child: Icon(Icons.edit),
        //backgroundColor: Colors.yellow,
      ),
    );
  }
}

class ViewDishArguments {
  final Dish dish;

  ViewDishArguments(this.dish);
}

Future _editDish(BuildContext context, Dish d) async {
  final editedArgs = await Navigator.pushNamed(context, '/dishes/edit',
      arguments: EditDishArguments(d, Hive.box<Category>('categoryBox')));

  if (editedArgs is EditDishArguments) {
    editedArgs.dish.save();
  }
}
