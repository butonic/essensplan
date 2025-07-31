import 'package:essensplan/widgets/category_chip.dart';
import 'package:flutter/material.dart';

import '../model/dish.dart';
import '../model/day.dart';
import '../model/category.dart';
import '../widgets/dish_list.dart';
import 'package:hive_ce/hive.dart';

import 'edit_dish.dart';

// The DishesPage loads all dishes, categories and tags on startup
// the categories and tags are usedy to build a filter for the db
class DishesPage extends StatefulWidget {
  const DishesPage({super.key});

  @override
  _DishesPageState createState() => _DishesPageState();
}

class _DishesPageState extends State<DishesPage> {
  static final GlobalKey<ScaffoldState> _dishesKey = GlobalKey<ScaffoldState>();
  String query = '';

  Dish? scrollTarget;

  final TextEditingController _searchQuery = TextEditingController();

  List<Category> selectedCategories = <Category>[];
  List<Category> excludedCategories = <Category>[];
  List<Dish> filteredDishes = <Dish>[];

  bool andFilterCategories = false;
  bool showDeleted = false;

  int currentSortFunction = 0;
  List<int Function(Dish, Dish)> sortFunctions = [
    // by name asc
    (d1, d2) {
      return (d1.name ?? '').toLowerCase().compareTo(
        (d2.name ?? '').toLowerCase(),
      );
    },
    // by name desc
    (d1, d2) {
      return (d2.name ?? '').toLowerCase().compareTo(
        (d1.name ?? '').toLowerCase(),
      );
    },
    // by days asc
    (d1, d2) {
      return d1.lastCookedDay.compareTo(d2.lastCookedDay);
    },
    // by days desc
    (d1, d2) {
      return d2.lastCookedDay.compareTo(d1.lastCookedDay);
    },
  ];

  //getting data from the db
  @override
  void initState() {
    super.initState();

    // load all dishes
    setState(() {
      filteredDishes.addAll(
        Hive.box<Dish>(
          'dishBox',
        ).values.where((dish) => dish.deleted != true && dish.name != null),
      );

      // iterate over all days & dishes, set the last cooked day for the dish list
      Hive.box<Day>('dayBox').toMap().values.forEach((day) {
        day.entries?.forEach((dish) {
          if (dish.lastCookedDay < day.key) {
            dish.lastCookedDay = day.key;
          }
        });
      });

      filteredDishes.sort(sortFunctions[currentSortFunction]);
    });
  }
  // TODO on destroy remove the initialized vars?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gericht auswählen'),
        actions: <Widget>[
          //IconButton(
          //  icon: Icon(Icons.developer_mode),
          //  onPressed: () {
          //     Hive.box<Category>('categoryBox').clear();
          //  },
          //),
        ],
      ),
      body: Form(
        key: _dishesKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onChanged: (String q) {
                        updateSearchQuery(
                          q,
                          selectedCategories,
                          excludedCategories,
                        );
                      },
                    ),
                  ),
                  _searchQuery.text.isEmpty
                      ? Container()
                      : IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: _clearSearchQuery,
                        ),
                ],
              ),
            ),
            _buildCategoryDropdown(),
            SizedBox(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text(
                      currentSortFunction == 0
                          ? 'Name ▲'
                          : (currentSortFunction == 1
                                ? 'Name ▼'
                                : (currentSortFunction == 2
                                      ? 'Tage ▲'
                                      : (currentSortFunction == 3
                                            ? 'Tage ▼'
                                            : 'Zufällig'))),
                    ),
                    onPressed: () {
                      setState(() {
                        currentSortFunction++;
                        if (currentSortFunction >= sortFunctions.length) {
                          currentSortFunction = -1;
                          filteredDishes.shuffle();
                        } else {
                          filteredDishes.sort(
                            sortFunctions[currentSortFunction],
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredDishes.isNotEmpty
                  ? DishList(
                      dishes: filteredDishes,
                      scrollTarget: scrollTarget,
                      onTap: _selectedDish,
                      onLongPress: _editDish,
                      onDismissed:
                          (
                            BuildContext context,
                            DismissDirection direction,
                            Dish dish,
                          ) {
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${dish.name ?? dish.note} ${dish.deleted == true ? 'Gelöscht' : 'Wiederhergestellt'}",
                                ),
                              ),
                            );
                          },
                    )
                  : Hive.box<Dish>('dishBox').values == null
                  ? Center(child: CircularProgressIndicator())
                  : Center(child: const Text('Kein Treffer')),
            ),
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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      andFilterCategories
                          ? Icons.border_outer
                          : Icons.border_vertical,
                    ),
                    SizedBox(width: 4),
                    Text(
                      andFilterCategories
                          ? 'Alle Kategorien'
                          : 'Eine der Kategorien',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  andFilterCategories = !andFilterCategories;
                  updateSearchQuery(
                    query,
                    selectedCategories,
                    excludedCategories,
                  );
                });
              },
            ),
            Spacer(),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      showDeleted ? 'gelöschte Gerichte' : 'Gerichte',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 4),
                    Icon(showDeleted ? Icons.visibility : Icons.visibility_off),
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  showDeleted = !showDeleted;
                  updateSearchQuery(
                    query,
                    selectedCategories,
                    excludedCategories,
                  );
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
        '',
        selectedCategories,
        excludedCategories,
      ); // TODO reset selected categories?
    });
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
      child: Wrap(
        direction: Axis.horizontal,
        runSpacing: 3.0, // spacing between lines
        children: categoryChips.toList(),
      ),
    );
  }

  Iterable<Widget> get categoryChips sync* {
    List categories = Hive.box<Category>('categoryBox').toMap().values.toList();
    categories.sort((a, b) {
      if (a.order == null || b.order == null) {
        return 0;
      } else {
        return a.order.compareTo(b.order);
      }
    });
    for (final Category category in categories) {
      yield Padding(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: CategoryChip(
          label: Text(category.name),
          backgroundColor: category.color != null
              ? Color(category.color!)
              : Colors.grey,
          textColor: category.color != null
              ? Color(category.color!)
              : Colors.black,
          onTap: (selection) {
            switch (selection) {
              case CategoryChipSelection.unselected:
                selectedCategories.remove(category);
                excludedCategories.remove(category);
                break;
              case CategoryChipSelection.selected:
                selectedCategories.add(category);
                excludedCategories.remove(category);
                break;
              case CategoryChipSelection.excluded:
                selectedCategories.remove(category);
                excludedCategories.add(category);
                break;
            }
            updateSearchQuery(query, selectedCategories, excludedCategories);
          },
        ),
      );
    }
  }

  void updateSearchQuery(
    String newQuery,
    List<Category> categories,
    List<Category> excluded,
  ) async {
    filteredDishes.clear();
    // 1. filter notes
    var dishes = Hive.box<Dish>('dishBox').values.where((d) => d.name != null);

    if (showDeleted == true) {
      dishes = dishes.where((d) => d.deleted == true);
    } else {
      dishes = dishes.where((d) => d.deleted != true);
    }

    newQuery = newQuery.toLowerCase();

    if (newQuery.isNotEmpty == true) {
      dishes = dishes.where((e) {
        return e.name?.toLowerCase().contains(newQuery) == true ||
            e.note?.toLowerCase().contains(newQuery) == true;
      });
    }

    // if categories have been selected
    if (categories.isNotEmpty) {
      if (andFilterCategories) {
        // only add dishes that have all of the selected categories
        dishes = dishes.where(
          (d) => (d.categories ?? []).toSet().containsAll(categories),
        );
      } else {
        // add all dishes with any of the selected categories
        dishes = dishes.where(
          (dish) =>
              (dish.categories ?? []).any((dc) => categories.contains(dc)),
        );
      }
    }

    if (excluded.isNotEmpty) {
      dishes = dishes.where(
        (d) =>
            (d.categories ?? []).toSet().intersection(excluded.toSet()).isEmpty,
      );
    }

    filteredDishes.addAll(dishes);
    filteredDishes.sort(sortFunctions[currentSortFunction]);

    // 3. filter categories
    // TODO why do we clear the selected categories?
    // TODO do we need to clear the excluded categories?
    if (selectedCategories != categories) {
      // we have new categories
      selectedCategories.clear();
      if (categories.isNotEmpty == true) {
        selectedCategories.addAll(categories);
      }
    }

    query = newQuery;
    setState(() {});
  }

  //Filtering the list item with found match string.
  void filterList(Dish dish, String searchQuery) {
    setState(() {
      if (dish.name?.toLowerCase().contains(searchQuery.toLowerCase()) ==
          true) {
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
    final editedArgs = await Navigator.pushNamed(
      context,
      '/dishes/edit',
      arguments: EditDishArguments(d, Hive.box<Category>('categoryBox')),
    );

    if (editedArgs is EditDishArguments) {
      await Hive.box<Dish>('dishBox').add(editedArgs.dish);
      _clearSearchQuery();
      scrollTarget = d;
    }
  }

  void _editDish(BuildContext context, Dish dish) async {
    final editedArgs = await Navigator.pushNamed(
      context,
      '/dishes/edit',
      arguments: EditDishArguments(dish, Hive.box<Category>('categoryBox')),
    );

    if (editedArgs is EditDishArguments) {
      await editedArgs.dish.save();
      _clearSearchQuery();
      // TODO scroll to dish? may not be necessary
    }
  }
}
