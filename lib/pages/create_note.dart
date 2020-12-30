import 'package:flutter/material.dart';

import '../model/dish.dart';

class EditNotePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notiz bearbeiten'),
      ),
      body: EditNoteForm(),
    );
  }
}

class EditNoteForm extends StatefulWidget {
  @override
  EditNoteFormState createState() => EditNoteFormState();
}

class EditNoteFormState extends State<EditNoteForm> {
  final _formKey = GlobalKey<FormState>();
  Dish note = Dish();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
              decoration: InputDecoration(labelText: 'Notizen'),
              onSaved: (String value) {
                note.note = value;
              }),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _formKey.currentState.save();
              Navigator.pop(context, note);
            },
          ),
        ],
      ),
    );
  }
}
