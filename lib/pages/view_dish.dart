import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/dish.dart';
import '../model/category.dart';
import '../pages/edit_dish.dart';

class ViewDishPage extends StatefulWidget {
  ViewDishPage({Key? key}) : super(key: key);

  @override
  _ViewDishPageState createState() => _ViewDishPageState();
}

class _ViewDishPageState extends State<ViewDishPage> {
  static final GlobalKey<ScaffoldState> _viewDishKey =
      GlobalKey<ScaffoldState>();

  Future<void> _editDish(BuildContext context, Dish d) async {
    final editedArgs = await Navigator.pushNamed(context, '/dishes/edit',
        arguments: EditDishArguments(d, Hive.box<Category>('categoryBox')));

    if (editedArgs is EditDishArguments) {
      await editedArgs.dish.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ViewDishArguments args =
        ModalRoute.of(context)!.settings.arguments as ViewDishArguments;
    Dish dish = args.dish;

    return Scaffold(
      key: _viewDishKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gericht'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 4, 0),
                child: const Text(
                  'Name',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.left,
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 4),
                child: Text(
                  dish.name ?? 'Fehlender Name',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.left,
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 4, 0),
                child: const Text(
                  'Notizen',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.left,
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 4),
                child: SelectableLinkify(
                  style: const TextStyle(
                      color: Colors.black45, fontStyle: FontStyle.italic),
                  text: (dish.note ?? 'Keine Notiz'),
                  onOpen: (link) async {

                    try {
                      final uri = Uri.parse(link.url);
                      
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Fallback für spezielle URLs
                        await launchUrl(uri, mode: LaunchMode.platformDefault);
                      }

                    } catch (e) {
                      // Fehler-Feedback für Benutzer
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Link konnte nicht geöffnet werden: ${link.url}'),
                          backgroundColor: Colors.red,
                          action: SnackBarAction(
                            label: 'Kopieren',
                            textColor: Colors.white,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: link.url.toString()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Link in Zwischenablage kopiert')),
                              );
                            },
                          ),
                        ),
                      );
                    }               },
                )),
            Divider(),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Tags(
                  itemCount: dish.categories?.length ?? 0,
                  itemBuilder: (int index) {
                    final c = dish.categories?.elementAt(index);

                    return ItemTags(
                      key: Key(index.toString()),
                      index: index,
                      title: c?.name ?? 'Fehlender Name',
                      active: true,
                      activeColor:
                          c?.color != null ? Color(c!.color!) : Colors.grey,
                      border: Border.all(
                          color: c?.color != null
                              ? Color(c!.color!)
                              : Colors.grey),
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
