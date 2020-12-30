import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:essensplan/widgets/split.dart';

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
  static final GlobalKey<ScaffoldState> _dishesKey = GlobalKey<ScaffoldState>();
  String query = '';

  Dish scrollTarget;

  TextEditingController _searchQuery;

  List<Category> selectedCategories;
  List<Dish> filteredDishes;

  bool andFilterCategories = false;
  bool showDeleted = false;

  //getting data from the db
  @override
  void initState() {
    super.initState();

    // load all dishes
    filteredDishes = <Dish>[];
    setState(() {
      filteredDishes.addAll(Hive.box<Dish>('dishBox')
          .values
          .where((dish) => dish.deleted != true && dish.name != null));
      filteredDishes.sort((d1, d2) {
        return d1.name.toLowerCase().compareTo(d2.name.toLowerCase());
      });
    });

    _searchQuery = TextEditingController();
    selectedCategories = <Category>[];
  }
  // TODO on destroy remove the initialized vars?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Gericht auswählen'),
          actions: <Widget>[
            //IconButton(
            //  icon: Icon(Icons.developer_mode),
            //  onPressed: () {
            //     Hive.box<Category>('categoryBox').clear();
            //  },
            //),
          ]),
      body: Form(
        key: _dishesKey,
        child: Split(
          axis: Axis.vertical,
          initialFractions: [.4, .6],
          children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              /*Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 4, 0),
                  child: Text(
                    "Suchen",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                    textAlign: TextAlign.left,
                  )),*/
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _searchQuery,
                          decoration: const InputDecoration(
                              hintText: 'Suche nach Name oder Notiz ...',
                              border: InputBorder.none,
                              hintStyle:
                                  TextStyle(fontStyle: FontStyle.italic)),
                          onChanged: (String q) {
                            updateSearchQuery(q, selectedCategories);
                          },
                        ),
                      ),
                      _searchQuery.text.isEmpty
                          ? Container()
                          : IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _clearSearchQuery)
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 4, 0),
                  child: Text(
                    'Filtern nach Kategorien', // TODO umschalter und oder hier hin, nach rechts und dann text in klammern (eine|alle)
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                    textAlign: TextAlign.left,
                  )),
              _buildCategoryDropdown()
            ]),
            //Expanded(
            //  child: filteredDishes != null && filteredDishes.length > 0
            filteredDishes != null && filteredDishes.isNotEmpty
                ? DishList(
                    dishes: filteredDishes,
                    scrollTarget: scrollTarget,
                    onTap: _selectedDish,
                    onLongPress: _editDish,
                    onDismissed: (BuildContext context,
                        DismissDirection direction, Dish dish) {
                      setState(() {
                        filteredDishes.remove(dish);
                        if (dish.deleted == true) {
                          dish.deleted = false;
                        } else {
                          // it might be null or false, in both cases set to true
                          dish.deleted = true;
                        }
                        dish.save();
                      });
                      // Show a snackbar. This snackbar could also contain "Undo" actions.
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "${dish.name ?? dish.note} ${dish.deleted ? 'Gelöscht' : 'Wiederhergestellt'}")));
                    },
                  )
                : Hive.box<Dish>('dishBox').values == null
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: Text('Kein Treffer'),
                      ),
            //),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _newDish(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            GestureDetector(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(andFilterCategories
                          ? Icons.border_outer
                          : Icons.border_vertical),
                      SizedBox(width: 4),
                      Text(
                        andFilterCategories
                            ? 'Alle Kategorien'
                            : 'Eine der Kategorien',
                        style: Theme.of(context).textTheme.caption,
                      )
                    ],
                  )),
              onTap: () {
                setState(() {
                  andFilterCategories = !andFilterCategories;
                  updateSearchQuery(query, selectedCategories);
                });
              },
            ),
            Spacer(),
            GestureDetector(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        showDeleted ? 'gelöschte Gerichte' : 'Gerichte',
                        style: Theme.of(context).textTheme.caption,
                      ),
                      SizedBox(width: 4),
                      Icon(showDeleted
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ],
                  )),
              onTap: () {
                setState(() {
                  showDeleted = !showDeleted;
                  updateSearchQuery(query, selectedCategories);
                });
              },
            ),
          ],
        ),
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

  Widget _buildCategoryDropdown() {
    List categories = Hive.box<Category>('categoryBox').toMap().values.toList();
    categories.sort((a, b) {
      if (a.order == null || b.order == null) {
        return 0;
      } else {
        return a.order.compareTo(b.order);
      }
    });
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Tags(
                key: _dishesTagStateKey,
                itemCount: categories.length, // required
                itemBuilder: (int index) {
                  final c = categories[index];

                  return ItemTags(
                    // Each ItemTags must contain a Key. Keys allow Flutter to
                    // uniquely identify widgets.
                    key: Key(index.toString()),
                    index: index, // required
                    title: c.name,
                    color: c.color != null ? Color(c.color) : Colors.grey,
                    // true if dish has this category
                    active: false,
                    customData: c,
                    border: Border.all(
                        color: c.color != null ? Color(c.color) : Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
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
            /*IconButton(
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
            ),*/
          ],
        ));
  }

  void updateSearchQuery(String newQuery, List<Category> categories) async {
    filteredDishes.clear();
    // 1. filter notes
    var dishes = Hive.box<Dish>('dishBox').values.where((d) => d.name != null);

    if (showDeleted == true) {
      dishes = dishes.where((d) => d.deleted == true);
    } else {
      dishes = dishes.where((d) => d.deleted != true);
    }

    newQuery = newQuery.toLowerCase();

    if (newQuery?.isNotEmpty == true) {
      dishes = dishes.where((e) {
        return e.name.toLowerCase().contains(newQuery) ||
            e.note?.toLowerCase()?.contains(newQuery) == true;
      });
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
    filteredDishes.sort((d1, d2) {
      return d1.name.compareTo(d2.name);
    });

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
  void filterList(Dish dish, String searchQuery) {
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
    var d = Dish();
    d.categories = HiveList(Hive.box<Category>('categoryBox'));
    d.tags = HiveList(Hive.box<Tag>('tagBox'));
    final editedArgs = await Navigator.pushNamed(context, '/dishes/edit',
        arguments: EditDishArguments(d, Hive.box<Category>('categoryBox')));

    if (editedArgs is EditDishArguments) {
      await Hive.box<Dish>('dishBox').add(editedArgs.dish);
      _clearSearchQuery();
      scrollTarget = d;
    }
  }

  void _editDish(BuildContext context, Dish dish) async {
    final editedArgs = await Navigator.pushNamed(context, '/dishes/edit',
        arguments: EditDishArguments(dish, Hive.box<Category>('categoryBox')));

    if (editedArgs is EditDishArguments) {
      await editedArgs.dish.save();
      _clearSearchQuery();
      // TODO scroll to dish? may not be necessary
    }
  }
}
