import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../model/category.dart';

// The CategoriesPage is used to manege all categories
class CategoriesPage extends StatefulWidget {
  CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
// create some values
  Color pickerColor = Color(0xff443a49);

  Color currentColor = Colors.limeAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // show an AppBar without tools, so the StatusBar does not cover the list
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row()), // This is needed to not hide the last item in the list
      body: ValueListenableBuilder(
        builder: (context, Box<Category> box, child) {
          var raw = box.toMap();
          List<Category> list = raw.values.toList();
          list.sort((a, b) {
            return a.order.compareTo(b.order);
          });
          var children = List.generate(
              list.length,
              (i) => Dismissible(
                    key: ObjectKey(list[i]),
                    onDismissed: (direction) {
                      setState(() {
                        list[i].delete();
                      });
                    },
                    child: ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.circle),
                          onPressed: () {
                            final oldColor = list[i].color;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final textController = TextEditingController();
                                return AlertDialog(
                                  title: const Text('Farbe wählen'),
                                  content: SingleChildScrollView(
                                    child: Column(children: [
                                      ColorPicker(
                                        pickerAreaHeightPercent: 0.6,
                                        showLabel: false,
                                        enableAlpha: false,
                                        pickerColor: list[i].color != null
                                            ? Color(list[i].color!)
                                            : Colors.grey,
                                        hexInputController: textController,
                                        onColorChanged: (Color color) {
                                          setState(() {
                                            list[i].color = color.value;
                                          });
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: TextField(
                                          controller: textController,
                                          autofocus: true,
                                          maxLength: 9,
                                          inputFormatters: [
                                            UpperCaseTextFormatter(),
                                            FilteringTextInputFormatter.allow(
                                                RegExp(kValidHexPattern)),
                                          ],
                                        ),
                                      )
                                    ]),
                                  ),
                                );
                              },
                            ).then((exit) {
                              if (oldColor != list[i].color) {
                                list[i].save();
                              }
                            });
                          },
                          color: list[i].color != null
                              ? Color(list[i].color!)
                              : Colors.grey,
                        ),
                        title: Text(list[i].name),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Kategorie umbenennen'),
                                  content: SingleChildScrollView(
                                    child: Column(children: [
                                      TextFormField(
                                        autofocus: true,
                                        controller: TextEditingController(
                                            text: list[i].name),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Bitte einen namen eingeben';
                                          }
                                          return null;
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.always,
                                        onFieldSubmitted: (newValue) {
                                          if (newValue.isNotEmpty) {
                                            setState(() {
                                              list[i].name = newValue.trim();
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
                for (var i = 0; i < list.length; i++) {
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(_, TextEditingValue nv) =>
      TextEditingValue(text: nv.text.toUpperCase(), selection: nv.selection);
}
