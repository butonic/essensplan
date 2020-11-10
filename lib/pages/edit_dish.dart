import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../model/dish.dart';
import '../model/category.dart';

class EditDishPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gericht bearbeiten'),
      ),
      body: EditDishForm(),
    );
  }
}

class EditDishArguments {
  final Dish dish;
  final Box<Category> categories;

  EditDishArguments(this.dish, this.categories);
}

class EditDishForm extends StatefulWidget {
  @override
  EditDishFormState createState() => EditDishFormState();
}

final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();

class EditDishFormState extends State<EditDishForm> {
  final _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    final EditDishArguments args = ModalRoute.of(context).settings.arguments;
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
              initialValue: args.dish.name,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (String value) {
                args.dish.name = value;
              }),
          TextFormField(
              initialValue: args.dish.note,
              decoration: InputDecoration(labelText: 'Notizen'),
              onSaved: (String value) {
                args.dish.note = value;
              }),
          Tags(
            key: _tagStateKey,
            textField: TagsTextField(
              hintText: 'Kategorie hinzufügen',
              //lowerCase: true, // lowercases the resulting tag
              //textStyle: TextStyle(fontSize: _fontSize),
              constraintSuggestion: false,
              suggestions:
                  args.categories.values.map<String>((e) => e.name).toList(),
              //width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 10),
              onSubmitted: (String str) {
                var cat = args.categories.values.firstWhere(
                    ((e) => e.name == str),
                    orElse: () => new Category(name: str, id: Uuid().v4()));
                // Add item to the data source.
                setState(() {
                  // required
                  // we need to add the category to the category box before we can reference it
                  // TODO automatically remove category when canceling editing?
                  args.categories.put(cat.id, cat).then((value) {
                    args.dish.categories.add(cat);
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
                //key: Key(item.name),
                index: index, // required
                title: c.name,
                // true if dish has this category
                active: args.dish.categories.contains(c),
                customData: c,
                onPressed: (Item item) {
                  args.dish.categories.add(item.customData);
                },

                //removeButton: ItemTagsRemoveButton(
                //  onRemoved: () {
                //    // Remove the item from the data source.
                //    setState(() {
                //      // required
                //      args.categories.removeAt(index);
                //    });
                //    //required
                //    return true;
                //  },
                //),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _formKey.currentState.save();
              Navigator.pop(context, args);
            },
          ),
        ],
      ),
    );
  }
}
