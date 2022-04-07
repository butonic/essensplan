import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../model/dish.dart';
import '../model/category.dart';

class EditDishArguments {
  final Dish dish;
  final Box<Category> categories;

  EditDishArguments(this.dish, this.categories);
}

class EditDishPage extends StatefulWidget {
  @override
  EditDishPageState createState() => EditDishPageState();
}

final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();

class EditDishPageState extends State<EditDishPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final EditDishArguments args =
        ModalRoute.of(context)?.settings.arguments as EditDishArguments;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gericht bearbeiten'), // TODO bearbeiten vs anlegen
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 4),
                  child: TextFormField(
                      initialValue: args.dish.name,
                      autofocus: true,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                        hintText: 'Name des Gerichts eingeben',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Bitte einen namen eingeben';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String? value) {
                        args.dish.name = value ?? 'Unbekannt';
                      })),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 4, 0),
                  child: const Text(
                    'Notizen',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                    textAlign: TextAlign.left,
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 4),
                  child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      initialValue: args.dish.note,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                        hintText: 'Notizen, Link, etc. zum Gericht eingeben',
                      ),
                      onSaved: (String? value) {
                        args.dish.note = value ?? 'Unbekannt';
                      })),
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Tags(
                  key: _tagStateKey,
                  textField: TagsTextField(
                    hintText: 'Kategorie hinzufügen',
                    constraintSuggestion: false,
                    suggestions: args.categories.values
                        .map<String>((e) => e.name)
                        .toList(),
                    onSubmitted: (String str) {
                      var cat = args.categories.values.firstWhere(
                        ((e) => e.name == str),
                        orElse: () => Category(
                            name: str,
                            id: Uuid().v4(),
                            order: args.categories.length), // add as last item
                      );
                      // Add item to the data source.
                      setState(() {
                        // required
                        // we need to add the category to the category box before we can reference it
                        // TODO automatically remove category when canceling editing?
                        args.categories.put(cat.id, cat).then((value) {
                          args.dish.categories?.add(cat);
                        });
                      });
                    },
                  ),
                  itemCount: args.categories.length, // required
                  itemBuilder: (int index) {
                    final c = args.categories.getAt(index);

                    return ItemTags(
                      // Each ItemTags must contain a Key. Keys allow Flutter to
                      // uniquely identify widgets.
                      key: Key(index.toString()),
                      index: index, // required
                      title: c?.name ?? 'Unbekannt',
                      color: Colors.white,
                      textColor:
                          c?.color != null ? Color(c!.color!) : Colors.black,
                      border: Border.all(
                          color: c?.color != null
                              ? Color(c!.color!)
                              : Colors.grey),
                      // true if dish has this category
                      active: args.dish.categories?.contains(c) ?? false,
                      textActiveColor: Colors.white,
                      activeColor:
                          c?.color != null ? Color(c!.color!) : Colors.grey,

                      customData: c,
                      onPressed: (Item item) {
                        if (item.active == true) {
                          args.dish.categories?.add(item.customData);
                        } else {
                          args.dish.categories?.remove(item.customData);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _formKey.currentState?.save();
          Navigator.pop(context, args);
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
