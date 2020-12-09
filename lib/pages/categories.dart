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
          list.sort((a, b) {
            if (a.order == null || b.order == null) {
              return 0;
            } else {
              return a.order.compareTo(b.order);
            }
          });
          List<Widget> children = List.generate(
              list.length,
              (i) => Dismissible(
                    key: ObjectKey(list[i]),
                    onDismissed: (direction) {
                      setState(() {
                        list.removeAt(i);
                        list[i].delete();
                      });
                    },
                    child: ListTile(
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
                                      pickerColor: list[i].color != null
                                          ? Color(list[i].color)
                                          : Colors.grey,
                                      onColorChanged: (Color color) {
                                        setState(() {
                                          list[i].color = color.value;
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          color: list[i].color != null
                              ? Color(list[i].color)
                              : Colors.grey,
                        ),
                        title: Text(list[i].name),
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
                                            text: list[i].name),
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
                                              list[i].name = newValue;
                                              list[i].save();
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
                  ));
          return ReorderableListView(
            children: children,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                // first reorder our list
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final element = list.removeAt(oldIndex);
                list.insert(newIndex, element);

                // then update order of all categories that changed
                for (int i = 0; i < list.length; i++) {
                  if (list[i].order != i) {
                    list[i].order = i;
                    list[i].save();
                  }
                }
              });
            },
          );
        },
        valueListenable: Hive.box<Category>('categoryBox').listenable(),
      ),
    );
  }
}
