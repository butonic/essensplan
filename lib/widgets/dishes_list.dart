import 'package:flutter/material.dart';

import '../model/dish.dart';
import '../services/database.dart';

class DishesList extends StatelessWidget {
  Widget build(BuildContext context) {
    return new FutureBuilder<List<Dish>>(
        future: DBProvider.db.getAllDishes(),
        builder: (BuildContext context, AsyncSnapshot<List<Dish>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Dish item = snapshot.data[index];
                if (item.name == null) {
                  return ListTile(
                    title: Text('unknown'),
                    leading: Text(item.id.toString()),
                    // TODO delete item
                  );
                }
                return ListTile(
                  title: Text(item.name),
                  leading: Text(item.id.toString()),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
