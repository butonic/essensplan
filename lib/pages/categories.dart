import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../model/category.dart';

// The CategoriesPage is used to manege all categories
class CategoriesPage extends StatefulWidget {
  CategoriesPage({Key key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
// create some values
  Color pickerColor = Color(0xff443a49);

  Color currentColor = Colors.limeAccent;

  Widget build(BuildContext context) {
    return Scaffold(
      // show an AppBar without tools, so the StatusBar does not cover the list
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: ValueListenableBuilder(
        builder: (context, Box<Category> box, child) {
          Map<dynamic, Category> raw = box.toMap();
          List list = raw.values.toList();

          return ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              Category category = list[index];
              return new Dismissible(
                  key: ObjectKey(category),
                  onDismissed: (direction) {
                    setState(() {
                      list.removeAt(index);
                      category.delete();
                    });
                  },
                  child: ListTile(
                    title: InkWell(
                        child: Text(category.name),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Kategorie umbenennen'),
                                  content: SingleChildScrollView(
                                    child: Column(children: [
                                      TextFormField(
                                        autofocus: true,
                                        controller: TextEditingController(
                                            text: category.name),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Bitte einen namen eingeben';
                                          }
                                          return null;
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.always,
                                        onFieldSubmitted: (newValue) {
                                          if (newValue.isNotEmpty) {
                                            setState(() {
                                              category.name = newValue;
                                              category.save();
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        },
                                      )
                                    ]),
                                  ),
                                );
                              });
                        }),
                    leading: IconButton(
                      icon: Icon(Icons.circle),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select a color'),
                              content: SingleChildScrollView(
                                child: BlockPicker(
                                  pickerColor: category.color != null
                                      ? Color(category.color)
                                      : Colors.grey,
                                  onColorChanged: (Color color) {
                                    setState(() {
                                      category.color = color.value;
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      color: category.color != null
                          ? Color(category.color)
                          : Colors.grey,
                    ),
                    trailing: Icon(Icons.drag_handle),
                  ));
            },
          );
        },
        valueListenable: Hive.box<Category>('categoryBox').listenable(),
      ),
    );
  }
}
