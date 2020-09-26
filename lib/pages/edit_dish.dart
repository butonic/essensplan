import 'package:flutter/material.dart';

import '../model/dish.dart';

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

class EditDishForm extends StatefulWidget {
  @override
  EditDishFormState createState() => EditDishFormState();
}

class EditDishFormState extends State<EditDishForm> {
  final _formKey = GlobalKey<FormState>();
  Dish dish = Dish();
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
              autofocus: true,
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (String value) {
                dish.name = value;
              }),
          TextFormField(
              decoration: InputDecoration(labelText: 'Notizen'),
              onSaved: (String value) {
                dish.note = value;
              }),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _formKey.currentState.save();
              Navigator.pop(context, dish);
            },
          ),
        ],
      ),
    );
  }
}
