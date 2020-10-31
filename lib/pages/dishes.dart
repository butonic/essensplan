import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

import '../model/dish.dart';
import '../model/category.dart';
import '../model/tag.dart';
import '../widgets/dish_list.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'edit_dish.dart';

// The DishesPage loads all dishes, categories and tags on startup
// the categories and tags are usedy to build a filter for the db
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

  List<Category> selectedCategories;
  List<Dish> filteredDishes;

  //getting data from the db
  @override
  void initState() {
    super.initState();
    // load all dishes
    filteredDishes = new List<Dish>();
    setState(() {
      filteredDishes.addAll(Hive.box<Dish>('dishBox').values);
    });

    _searchQuery = new TextEditingController();
    selectedCategories = new List<Category>();
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
          new Text('Tags'),
          Expanded(
            child: filteredDishes != null && filteredDishes.length > 0
                ? new DishList(
                    dishes: filteredDishes,
                    onTap: _selectedDish,
                    onLongPress: _editDish,
                  )
                : Hive.box<Dish>('dishBox').values == null
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
      updateSearchQuery(
          '', selectedCategories); // TODO reset selected categories?
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
            new Text(
              'Gerichte',
              style: new TextStyle(color: Colors.white),
            ),
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
                onChanged: (String q) {
                  updateSearchQuery(q, selectedCategories);
                },
              ),
            ),
            new IconButton(
                icon: Icon(Icons.clear), onPressed: _clearSearchQuery)
          ],
        ));
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
          dataSource: Hive.box<Category>('categoryBox').values.toList(),
          textField: 'name',
          valueField: 'id',
          filterable: true,
          onSaved: (value) {
            print('The value is $value');
            updateSearchQuery(query, value);
          }),
    );
  }

  void updateSearchQuery(String newQuery, List<Category> categories) async {
    filteredDishes.clear();
    if (newQuery.length > 0) {
      filteredDishes.addAll(Hive.box<Dish>('dishBox')
          .values
          .where((element) => element.categories.contains(categories))
          .where((element) => element.name.contains(newQuery)));
    }
    if (newQuery.isEmpty) {
      filteredDishes.addAll(Hive.box<Dish>('dishBox').values);
    }
    query = newQuery;
    setState(() {});
  }

  //Filtering the list item with found match string.
  filterList(Dish dish, String searchQuery) {
    setState(() {
      if (dish.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        filteredDishes.add(dish);
      }
    });
  }

  void _selectedDish(BuildContext context, Dish dish) {
    Navigator.pop<Dish>(context, dish);
  }

  void _newDish(BuildContext context) async {
    var d = new Dish();
    d.categories = HiveList(Hive.box<Category>('categoryBox'));
    d.tags = HiveList(Hive.box<Tag>('tagBox'));
    final editedArgs = await Navigator.pushNamed(context, '/dishes/edit',
        arguments: EditDishArguments(d, Hive.box<Category>('categoryBox')));

    if (editedArgs is EditDishArguments) {
      // TODO needs a day box with an ordered list of dishes/notes
      Hive.box<Dish>('dishBox').add(editedArgs.dish);
      //TODO update categories?
      //await DBProvider.db.getAllCategories().then((List<Category> categories) {
      //  allCategories = categories;
      //});
      _clearSearchQuery();
    }
  }

  void _editDish(BuildContext context, Dish dish) async {
    final editedArgs = await Navigator.pushNamed(context, '/dishes/edit',
        arguments: EditDishArguments(dish, Hive.box<Category>('categoryBox')));
    //final editedDish = await Navigator.push(
    //  context,
    //  MaterialPageRoute<Dish>(builder: (context) => EditDishPage()),
    //);

    if (editedArgs is EditDishArguments) {
      editedArgs.dish.save();
      //TODO update categories?
      //await DBProvider.db.getAllCategories().then((List<Category> categories) {
      //  allCategories = categories;
      // });
      _clearSearchQuery();
    }
  }
}
