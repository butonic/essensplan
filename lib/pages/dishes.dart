import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:ober_menu_planner/widgets/split.dart';

import '../model/dish.dart';
import '../model/category.dart';
import '../model/tag.dart';
import '../widgets/dish_list.dart';
import 'package:hive/hive.dart';

import 'edit_dish.dart';

// The DishesPage loads all dishes, categories and tags on startup
// the categories and tags are usedy to build a filter for the db
class DishesPage extends StatefulWidget {
  DishesPage({Key key}) : super(key: key);

  @override
  _DishesPageState createState() => _DishesPageState();
}

final GlobalKey<TagsState> _dishesTagStateKey = GlobalKey<TagsState>();

class _DishesPageState extends State<DishesPage> {
  static final GlobalKey<ScaffoldState> _dishesKey =
      new GlobalKey<ScaffoldState>();
  String query = '';

  TextEditingController _searchQuery;

  List<Category> selectedCategories;
  List<Dish> filteredDishes;

  bool andFilterCategories = false;

  //getting data from the db
  @override
  void initState() {
    super.initState();
    // load all dishes
    filteredDishes = new List<Dish>();
    setState(() {
      filteredDishes.addAll(Hive.box<Dish>('dishBox')
          .values
          .where((element) => element.name != null));
    });

    _searchQuery = new TextEditingController();
    selectedCategories = new List<Category>();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: _buildTitle(context), actions: <Widget>[
        //IconButton(
        //  icon: Icon(Icons.developer_mode),
        //  onPressed: () {
        //     Hive.box<Category>('categoryBox').clear();
        //  },
        //),
      ]),
      body: new Form(
        key: _dishesKey,
        child: Split(
          axis: Axis.vertical,
          initialFractions: [.2, .8],
          children: <Widget>[
            //_buildSearchField(),
            _buildCategoryDropdown(),
            //new Text('Tags'),
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
    return _buildSearchField();
    /*
    var horizontalTitleAlignment =
        Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return new InkWell(
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
    */
  }

  //Creating search box widget
  Widget _buildSearchField() {
    return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: TextField(
                cursorColor: Colors.white,
                controller: _searchQuery,
                //autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Suchen...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                onChanged: (String q) {
                  updateSearchQuery(q, selectedCategories);
                },
              ),
            ),
            IconButton(icon: Icon(Icons.clear), onPressed: _clearSearchQuery)
          ],
        ));
  }

  Widget _buildCategoryDropdown() {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Tags(
                key: _dishesTagStateKey,
                itemCount: Hive.box<Category>('categoryBox').length, // required
                itemBuilder: (int index) {
                  final c = Hive.box<Category>('categoryBox').getAt(index);

                  return ItemTags(
                    // Each ItemTags must contain a Key. Keys allow Flutter to
                    // uniquely identify widgets.
                    key: Key(index.toString()),
                    //key: Key(item.name),
                    index: index, // required
                    title: c.name,
                    // true if dish has this category
                    active: false, // TODO
                    customData: c,
                    onPressed: (Item item) {
                      if (item.active) {
                        selectedCategories.add(item.customData);
                      } else {
                        selectedCategories.remove(item.customData);
                      }
                      updateSearchQuery(query, selectedCategories);
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
              /* MultiSelect(
                titleText: 'Kategorien',
                selectIcon: null,
                saveButtonText: 'Filtern',
                validator: (value) {
                  if (value == null) {
                    return 'Berühren um ein oder mehrere Kategorien zu wählen ...';
                  }
                  return '';
                },
                errorText:
                    'Berühren um ein oder mehrere Kategorien zu wählen ...',
                hintText: '',
                dataSource: Hive.box<Category>('categoryBox')
                    .values
                    .map((category) => {
                          "category": category,
                          "displayname": category.name,
                        })
                    .toList(),
                textField: 'displayname',
                valueField: 'category',
                filterable: true,
                change: (value) {
                  // cast dynamic to List<Category>
                  var categories = (value as List)
                      ?.map((dynamic item) => item as Category)
                      ?.toList();
                  updateSearchQuery(query, categories);
                },
                onSaved: (value) {
                  // cast dynamic to List<Category>
                  var categories = (value as List)
                      .whereType<Category>()
                      ?.map((dynamic item) => item as Category)
                      ?.toList();
                  updateSearchQuery(query, categories);
                },
              ),
              */
            ),
            IconButton(
              //icon: Icon(andFilterCategories ? Icons.call_merge : Icons.call_split),
              //icon: Icon(andFilterCategories ? Icons.link : Icons.link_off),
              icon: Icon(andFilterCategories
                  ? Icons.border_outer
                  : Icons.border_vertical), // border vertical oder border inner
              onPressed: () {
                setState(() {
                  andFilterCategories = !andFilterCategories;
                  updateSearchQuery(query, selectedCategories);
                });
              },
            ),
          ],
        ));
  }

  void updateSearchQuery(String newQuery, List<Category> categories) async {
    filteredDishes.clear();
    // 1. filter notes
    var dishes = Hive.box<Dish>('dishBox').values.where((d) => d.name != null);

    if (newQuery?.isNotEmpty == true) {
      dishes = dishes
          .where((e) => e.name.toLowerCase().contains(newQuery.toLowerCase()));
    }

    // if categories have been selected
    if (categories?.isNotEmpty == true) {
      if (andFilterCategories) {
        // only add dishes that have all of the selected the categories
        dishes =
            dishes.where((d) => d.categories.toSet().containsAll(categories));
      } else {
        // add all dishes with any of the selected categories
        dishes = dishes.where(
            (dish) => dish.categories.any((dc) => categories.contains(dc)));
      }
    }

    filteredDishes.addAll(dishes);

    // 3. filter categories
    if (selectedCategories != categories) {
      // we have new categories
      selectedCategories.clear();
      if (categories?.isNotEmpty == true) {
        selectedCategories.addAll(categories);
      }
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
    d.categories = new HiveList(Hive.box<Category>('categoryBox'));
    d.tags = new HiveList(Hive.box<Tag>('tagBox'));
    final editedArgs = await Navigator.pushNamed(context, '/dishes/edit',
        arguments: EditDishArguments(d, Hive.box<Category>('categoryBox')));

    if (editedArgs is EditDishArguments) {
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
