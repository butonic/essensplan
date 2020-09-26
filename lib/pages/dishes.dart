import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

import '../model/dish.dart';
import '../widgets/dish_list.dart';
import '../services/database.dart';

import 'edit_dish.dart';

class DishesPage extends StatefulWidget {
  DishesPage({Key key}) : super(key: key);

  @override
  _DishesPageState createState() => _DishesPageState();
}

class _DishesPageState extends State<DishesPage> {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      new GlobalKey<ScaffoldState>();
  String query = '';

  TextEditingController _searchQuery;
  bool _isSearching = false;

  List<Dish> allDishes;
  List<Dish> filteredDishes;

  //getting data from the db
  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
    DBProvider.db.getAllDishes().then((List<Dish> dishes) {
      setState(() {
        allDishes = dishes;
      });

      filteredDishes = new List<Dish>();
      filteredDishes.addAll(allDishes);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: _buildTitle(context),
      ),
      body: new Column(
          children: <Widget>[
            _buildSearchField(),
            _buildCategoryDropdown(),
            new Text('Kategorie'),
            new Text('Tags'),
            Expanded(
              child:
            filteredDishes != null && filteredDishes.length > 0
          ? new DishList(dishes: filteredDishes)
          : allDishes == null
              ? new Center(child: new CircularProgressIndicator())
              : new Center(
                  child: new Text("Kein Treffer"),
                ),

        ),
          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _newDish(context);
        },
        child: Icon(Icons.add),
        //backgroundColor: Colors.yellow,
      ),
    );
  }

  //clear search box data.
  void _clearSearchQuery() {
    setState(() {
      _searchQuery.clear();
      updateSearchQuery('');
    });
  }
  //Create a app bar title widget
  Widget _buildTitle(BuildContext context) {
    var horizontalTitleAlignment =
        Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
      onTap: () => scaffoldKey.currentState.openDrawer(),
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            new Text('Gerichte',
            style: new TextStyle(color: Colors.white),),
          ],
        ),
      ),
    );
  }
  //Creating search box widget
  Widget _buildSearchField() {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: new TextField(
            controller: _searchQuery,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Suchen...',
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.black26),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
            onChanged: updateSearchQuery,
          ),
          ),
          new IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearSearchQuery
          )
        ],
      )
    );
  }

  Widget _buildCategoryDropdown() {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: MultiSelect(
        autovalidate: false,
        titleText: 'Kategorien',
        selectIcon: null,
        validator: (value) {
          if (value == null) {
            return 'Berühren um ein oder mehrere Kategorien zu wählen ...';
          }
        },
        errorText: 'Berühren um ein oder mehrere Kategorien zu wählen ...',
        hintText: '',

        dataSource: [
          {
            "display": "Australia",
            "value": 1,
          },
          {
            "display": "Canada",
            "value": 2,
          },
          {
            "display": "India",
            "value": 3,
          },
          {
            "display": "United States",
            "value": 4,
          }
        ],
        textField: 'display',
        valueField: 'value',
        filterable: true,
        //required: true,
        value: null,
        onSaved: (value) {
          print('The value is $value');
        }
      ),
    );
  }

  void updateSearchQuery(String newQuery) {
    filteredDishes.clear();
    if (newQuery.length > 0) {
      Set<Dish> set = Set.from(allDishes);
      set.forEach((element) => filterList(element, newQuery));
    }
    if (newQuery.isEmpty) {
      filteredDishes.addAll(allDishes);
    }
    setState(() {});
  }
  //Filtering the list item with found match string.
  filterList(Dish dish, String searchQuery) {
    setState(() {
      if (dish.name.toLowerCase().contains(searchQuery) ||
          dish.name.contains(searchQuery)) {
        filteredDishes.add(dish);
      }
    });
  }

  void _newDish(BuildContext context) async {

    final newDish = await Navigator.push(
      context,
      MaterialPageRoute<Dish>(builder: (context) => EditDishPage()),
    );

    if (newDish != null) {
      newDish.id = await DBProvider.db.newDish(newDish);
      allDishes.add(newDish);
      _clearSearchQuery();
    }
  }
}
