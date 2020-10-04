import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

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
  final List<Category> categories;

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
              suggestions: args.categories.map<String>((e) => e.name).toList(),
              //width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 10),
              onSubmitted: (String str) {
                // Add item to the data source.
                setState(() {
                  // required
                  args.dish.categories.add(str);
                });
              },
            ),
            itemCount: args.dish.categories.length, // required
            itemBuilder: (int index) {
              final item = args.dish.categories[index];

              return ItemTags(
                // Each ItemTags must contain a Key. Keys allow Flutter to
                // uniquely identify widgets.
                //key: Key(index.toString()),
                key: Key(item),
                index: index, // required
                title: item,
                pressEnabled: false,
                removeButton: ItemTagsRemoveButton(
                  onRemoved: () {
                    // Remove the item from the data source.
                    setState(() {
                      // required
                      args.dish.categories.removeAt(index);
                    });
                    //required
                    return true;
                  },
                ),
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
