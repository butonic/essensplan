import 'package:essensplan/widgets/dish_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:essensplan/pages/view_dish.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

import '../model/dish.dart';
import '../model/day.dart';
import '../model/category.dart';
import '../widgets/dish_or_note.dart';

const dayUnselected = -1;

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  _PlanPageState createState() => _PlanPageState();
}

class DragData {
  Day source;
  int index;
  DragData(this.source, this.index);
}

enum ImportMode {
  addOnly, // Nur neue Einträge hinzufügen
  smartMerge, // Intelligentes Merging mit Duplikat-Erkennung
  replaceAll, // Bestehende Daten komplett ersetzen
}

class ImportResult {
  int importedCategories = 0;
  int importedDishes = 0;
  int importedDays = 0;
  int mergedCategories = 0;
  int mergedDishes = 0;
  int mergedDays = 0;
  int skippedItems = 0;
  List<String> conflicts = [];
}

class _PlanPageState extends State<PlanPage> {
  static final GlobalKey<ScaffoldState> _planKey = GlobalKey<ScaffoldState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  PersistentBottomSheetController? bottomSheetController;

  int selectedDay = dayUnselected;

  bool showActionButton = true;

  @override
  Widget build(BuildContext context) {
    var currentDay = DateTime.now()
        .toUtc()
        .difference(epoch)
        .inDays; // ~18k -> 20k*2 = 40k for now

    if (selectedDay == dayUnselected) {
      selectedDay = currentDay;
    }

    return Scaffold(
      key: _planKey,
      // show an AppBar without tools, so the StatusBar does not cover the list
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        title: Text('Essensplan'),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'Essensplan',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text('Daten importieren'),
              onTap: () {
                Navigator.pop(context);
                _importData(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.file_upload),
              title: Text('Daten exportieren'),
              onTap: () {
                Navigator.pop(context);
                _exportData(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Kategorien'),
              onTap: () {
                Navigator.pop(context);
                _viewCategories(context);
              },
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // TODO scroll tapped text area into view?
      body: ScrollablePositionedList.builder(
        initialScrollIndex: currentDay,
        itemCount: 40000,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, i) => item(context, i),
      ),
      floatingActionButton: showActionButton
          ? FloatingActionButton(
              onPressed: selectedDay == dayUnselected
                  ? null
                  : () {
                      _selectDish(context, selectedDay);
                    },
              child: Icon(Icons.restaurant_menu),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DishBottomBar(
        onTapToday: (bContext) {
          itemScrollController.scrollTo(
            index: currentDay,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
          setState(() {
            selectedDay = currentDay;
          });
        },
        onTapNewNote: (bContext) {
          if (selectedDay != dayUnselected) {
            setState(() {
              var dayBox = Hive.box<Day>('dayBox');
              var dm = dayBox.get(selectedDay);
              if (dm == null) {
                dm = Day();
                dayBox.put(selectedDay, dm);
              }
              dm.entries ??= HiveList(Hive.box<Dish>('dishBox'));
              var note = Dish(
                note: '',
              ); // a hint is rendered for an empty string
              Hive.box<Dish>('dishBox').add(note);
              dm.entries!.add(note);
              dm.save();
              // TODO hide add dish action when editing  note
              _showBottomSheet(bContext, note);
            });
          }
        },
        onTapCategories: (bContext) {
          _viewCategories(bContext);
        },
      ),
    );
  }

  //  will return a widget used as an indicator for the drop position
  Widget _buildDropPreview(BuildContext context, Dish? dish) {
    if (dish == null) {
      return Container(
        width: double.infinity,
        height: 4, // to make up for the EdgeInset of 4.0
      );
    }
    return Card(
      color: Colors.lightBlue[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              dish.name ?? dish.note ?? 'Fehlender Name und Notiz',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Dish dish) {
    showActionButton = false;
    bottomSheetController = showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 70,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black)),
            color: Colors.grey[900],
          ),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              maxLines: null,
              textAlign: TextAlign.center,
              autofocus: true,
              controller: TextEditingController(text: dish.note),
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.all(4.0),
                border: InputBorder.none,
                hintText: 'Neue Notiz',
              ),
              onChanged: (value) {
                setState(() {
                  if (dish.note != value) {
                    dish.note = value;
                    dish.save();
                  }
                  if (dish.note == '') dish.delete();
                });
              },
            ),
          ),
        );
      },
    );
  }

  // generate item for day
  Widget item(BuildContext context, int day) {
    final date = epoch.add(Duration(days: day));
    var dm = Hive.box<Day>('dayBox').get(day);
    var dishes = <Widget>[];

    if (dm != null && dm.entries != null) {
      // for loop with item index
      for (var i = 0; i < dm.entries!.length; i++) {
        // the Draggables are in a Column
        // they need to be interwoven with DragTargets
        // https://stackoverflow.com/a/64011994
        dishes.add(
          DragTarget<DragData>(
            builder: (context, candidates, rejects) {
              DragData? candidate = candidates.isNotEmpty
                  ? candidates[0]
                  : null;
              return _buildDropPreview(
                context,
                candidate?.source.entries?[candidate.index],
              );
            },
            onWillAccept: (data) => true, // TODO ignore direct neighbors
            onAccept: (data) {
              setState(() {
                if (data.source.entries != null) {
                  dm!.entries!.insert(i, data.source.entries![data.index]);
                  if (dm == data.source && i < data.index) {
                    data.source.entries!.removeAt(data.index + 1);
                  } else {
                    data.source.entries!.removeAt(data.index);
                  }
                }
                dm!.save();
                data.source.save();
              });
            },
          ),
        );
        final dish = dm.entries![i];
        dishes.add(
          LongPressDraggable<DragData>(
            data: DragData(dm, i),
            feedback: Card(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  dm.entries![i].name ??
                      dm.entries![i].note ??
                      'Fehlender Name und Notiz',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            childWhenDragging: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: const Text(
                  '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            child: Dismissible(
              key: UniqueKey(),
              onDismissed: (direction) {
                setState(() {
                  dm!.entries!.removeAt(i);
                  dm!.save();
                  dishes.removeAt(i);
                });
                // Show a snackbar. This snackbar could also contain "Undo" actions.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${dish.name ?? dish.note} gelöscht')),
                );
                // FIXME Make sure to implement the onDismissed handler and to immediately remove the Dismissible widget from the application once that handler has fired.
              },
              child: DishOrNoteWidget(
                dish: dish,
                onTap: (context, dish) {
                  var bsc = bottomSheetController;
                  if (bsc != null) {
                    showActionButton = false;
                    bsc.close();
                    bottomSheetController = null;
                  }
                  if (dish.name != null) {
                    _viewDish(context, dish);
                  } else {
                    _showBottomSheet(context, dish);
                  }
                  setState(() {
                    if (selectedDay != day) {
                      selectedDay = day;
                    }
                  });
                },
              ),
            ),
          ),
        );
      }
    }
    dishes.add(
      DragTarget<DragData>(
        builder: (context, candidates, rejects) {
          DragData? candidate = candidates.isNotEmpty ? candidates[0] : null;
          return _buildDropPreview(
            context,
            candidate?.source.entries?[candidate.index],
          );
        },
        onWillAccept: (data) => true, // TODO ignore direct neighbors
        onAccept: (data) {
          setState(() {
            if (dm == null) {
              dm = Day();
              Hive.box<Day>('dayBox').put(day, dm!);
            }
            dm!.entries ??= HiveList(Hive.box<Dish>('dishBox'));
            dm!.entries!.insert(
              dm!.entries!.length,
              data.source.entries![data.index],
            ); // TODO whacky
            if (dm == data.source && dm!.entries!.length < data.index) {
              data.source.entries!.removeAt(data.index + 1);
            } else {
              data.source.entries!.removeAt(data.index);
            }
            dm!.save();
            data.source.save();
          });
        },
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.lightGreenAccent)),
      ),
      child: ListTile(
        key: ValueKey('day-$day'),
        selected: day == selectedDay,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              DateFormat('E').format(date),
              style: TextStyle(
                color: day == selectedDay
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              DateFormat('dd.MM').format(date),
              style: TextStyle(
                color: day == selectedDay
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        title: Column(children: dishes),
        onTap: () {
          var bsc = bottomSheetController;
          if (bsc != null) {
            showActionButton = true;
            bsc.close();
            bottomSheetController = null;
          }
          setState(() {
            if (selectedDay != day) {
              selectedDay = day;
            }
          });
        },
      ),
    );
  }

  void _selectDish(BuildContext context, int day) async {
    final result = await Navigator.pushNamed(context, '/dishes');

    if (result is Dish) {
      setState(() {
        var dayBox = Hive.box<Day>('dayBox');
        var dm = dayBox.get(day);
        if (dm == null) {
          dm = Day();
          dayBox.put(day, dm);
        }
        dm.entries ??= HiveList(Hive.box<Dish>('dishBox'));
        dm.entries!.add(result);
        dm.save();
      });
    }
  }

  void _viewDish(BuildContext context, Dish dish) async {
    await Navigator.pushNamed(
      context,
      '/dishes/view',
      arguments: ViewDishArguments(dish),
    );
  }

  void _viewCategories(BuildContext context) async {
    await Navigator.pushNamed(context, '/categories');
  }

  void _exportData(BuildContext context) async {
    try {
      // Hive Boxes laden
      var dayBox = Hive.box<Day>('dayBox');
      var dishBox = Hive.box<Dish>('dishBox');
      var categoryBox = Hive.box<Category>('categoryBox');

      // Export-Datenstruktur erstellen
      Map<String, dynamic> exportData = {
        'appName': 'Essensplan',
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'days': {},
        'dishes': [],
        'categories': [],
      };

      // Kategorien exportieren
      for (var key in categoryBox.keys) {
        var category = categoryBox.get(key);
        if (category != null) {
          exportData['categories'].add({
            'key': key,
            'name': category.name,
            'color': category.color,
          });
        }
      }

      // Gerichte exportieren
      for (var key in dishBox.keys) {
        var dish = dishBox.get(key);
        if (dish != null) {
          exportData['dishes'].add({
            'key': key,
            'name': dish.name,
            'note': dish.note,
            //'ingredients': dish.ingredients,
            //'recipe': dish.recipe,
            'categories': dish.categories
                ?.map((cat) => {'name': cat.name, 'color': cat.color})
                .toList(),
          });
        }
      }

      // Tage exportieren
      for (var key in dayBox.keys) {
        var day = dayBox.get(key);
        if (day != null && day.entries != null && day.entries!.isNotEmpty) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            0,
            isUtc: true,
          ).add(Duration(days: key));

          exportData['days'][key.toString()] = {
            'date': date.toIso8601String(),
            'dateFormatted': DateFormat('dd.MM.yyyy').format(date),
            'entries': day.entries!
                .map(
                  (dish) => {
                    'name': dish.name,
                    'note': dish.note,
                    //'ingredients': dish.ingredients,
                    //'recipe': dish.recipe,
                    'categories': dish.categories
                        ?.map((cat) => {'name': cat.name, 'color': cat.color})
                        .toList(),
                  },
                )
                .toList(),
          };
        }
      }

      // JSON erstellen
      String jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final fileName = 'essensplan_export_$timestamp.json';

      // Temp-Datei erstellen
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Statistiken
      int totalDishes = exportData['dishes'].length;
      int totalDays = exportData['days'].length;
      int totalCategories = exportData['categories'].length;

      // Export-Dialog mit Statistiken anzeigen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Export erstellt'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exportiert:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('$totalCategories Kategorien'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.restaurant, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('$totalDishes Gerichte'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('$totalDays Tage mit Einträgen'),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Die Datei kann in jeder beliebigen App gespeichert werden.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Abbrechen'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareExportFile(
                    file,
                    totalCategories,
                    totalDishes,
                    totalDays,
                  );
                },
                icon: Icon(Icons.share),
                label: Text('Teilen'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Export: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Hilfsmethode zum Teilen der Export-Datei
  void _shareExportFile(File file, int categories, int dishes, int days) async {
    try {
      final dateStr = DateFormat('dd.MM.yyyy').format(DateTime.now());

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Essensplan Export vom $dateStr\n\n'
            'Inhalt:\n'
            '• $categories Kategorien\n'
            '• $dishes Gerichte\n'
            '• $days Tage mit Einträgen',
        subject: 'Essensplan Export - $dateStr',
      );
    } catch (e) {
      print('Fehler beim Teilen: $e');
    }
  }

  void _importData(BuildContext context) async {
    try {
      // Datei auswählen
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // Benutzer hat abgebrochen
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();

      // JSON parsen
      Map<String, dynamic> importData;
      try {
        importData = jsonDecode(jsonString);
      } catch (e) {
        throw Exception('Ungültiges JSON-Format');
      }

      // Validierung der Import-Datei
      if (!importData.containsKey('appName') ||
          importData['appName'] != 'Essensplan') {
        throw Exception(
          'Ungültige Export-Datei. Nur Essensplan-Exports werden unterstützt.',
        );
      }

      // Hive Boxes laden
      var dayBox = Hive.box<Day>('dayBox');
      var dishBox = Hive.box<Dish>('dishBox');
      var categoryBox = Hive.box<Category>('categoryBox');

      // Statistiken für Bestätigung
      int categoriesToImport = (importData['categories'] as List?)?.length ?? 0;
      int dishesToImport = (importData['dishes'] as List?)?.length ?? 0;
      int daysToImport = (importData['days'] as Map?)?.length ?? 0;

      // Import-Modus wählen
      ImportMode? importMode = await _showImportModeDialog(
        context,
        categoriesToImport,
        dishesToImport,
        daysToImport,
      );

      if (importMode == null) return;

      // Import durchführen
      ImportResult importResult = await _performImport(
        importData,
        dayBox,
        dishBox,
        categoryBox,
        importMode,
      );

      // Ergebnis anzeigen
      _showImportResultDialog(context, importResult);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Import: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<ImportMode?> _showImportModeDialog(
    BuildContext context,
    int categories,
    int dishes,
    int days,
  ) async {
    return showDialog<ImportMode>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.settings, color: Colors.blue),
              SizedBox(width: 8),
              Text('Import-Modus wählen'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Import-Inhalt:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStatRow(Icons.category, '$categories Kategorien'),
              _buildStatRow(Icons.restaurant, '$dishes Gerichte'),
              _buildStatRow(Icons.calendar_today, '$days Tage'),
              const SizedBox(height: 16),
              const Text(
                'Wie sollen die Daten importiert werden?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          actions: [
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildImportActionButton(
                    label: 'Nur neue\nhinzufügen',
                    icon: Icons.add,
                    onPressed: () =>
                        Navigator.of(context).pop(ImportMode.addOnly),
                  ),
                  _buildImportActionButton(
                    label: 'Smart Merge\n(empfohlen)',
                    icon: Icons.merge,
                    isPrimary: true,
                    onPressed: () =>
                        Navigator.of(context).pop(ImportMode.smartMerge),
                  ),
                  _buildImportActionButton(
                    label: 'Alles\nersetzen',
                    icon: Icons.refresh,
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onPressed: () =>
                        Navigator.of(context).pop(ImportMode.replaceAll),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImportActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
    Color? iconColor,
    Color? textColor,
  }) {
    final buttonContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor ?? textColor),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: textColor),
        ),
      ],
    );

    final style = isPrimary
        ? ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            minimumSize: Size.zero,
          )
        : TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            minimumSize: Size.zero,
          );

    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: buttonContent,
          )
        : TextButton(onPressed: onPressed, style: style, child: buttonContent);
  }

  Widget _buildStatRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Future<ImportResult> _performImport(
    Map<String, dynamic> importData,
    Box<Day> dayBox,
    Box<Dish> dishBox,
    Box<Category> categoryBox,
    ImportMode mode,
  ) async {
    ImportResult result = ImportResult();

    // Bei replaceAll zuerst alles löschen
    if (mode == ImportMode.replaceAll) {
      await categoryBox.clear();
      await dishBox.clear();
      await dayBox.clear();
    }

    // Kategorien importieren
    Map<String, Category> importedCategories = {};
    if (importData.containsKey('categories')) {
      List categories = importData['categories'];
      for (var categoryData in categories) {
        String categoryName = categoryData['name'] ?? '';
        if (categoryName.isEmpty) continue;

        Category? existingCategory = _findCategoryByName(
          categoryBox,
          categoryName,
        );

        if (existingCategory == null) {
          // Neue Kategorie erstellen
          String newId = _generateNewCategoryId(categoryBox);
          int newOrder = _getNextCategoryOrder(categoryBox);

          Category category = Category(
            name: categoryName,
            id: newId,
            color: categoryData['color'],
            order: newOrder,
          );

          await categoryBox.add(category);
          importedCategories[categoryName] = category;
          result.importedCategories++;
        } else {
          // Bestehende Kategorie mergen
          if (mode == ImportMode.smartMerge) {
            bool updated = await _mergeCategoryData(
              existingCategory,
              categoryData,
            );
            if (updated) {
              await existingCategory.save();
              result.mergedCategories++;
            }
          }
          importedCategories[categoryName] = existingCategory;
        }
      }
    }

    // Gerichte importieren
    Map<String, Dish> importedDishes = {};
    if (importData.containsKey('dishes')) {
      List dishes = importData['dishes'];
      for (var dishData in dishes) {
        String dishName = dishData['name'] ?? '';
        if (dishName.isEmpty) continue;

        Dish? existingDish = _findDishByName(dishBox, dishName);

        if (existingDish == null) {
          // Neues Gericht erstellen
          Dish dish = await _createDishFromData(
            dishData,
            importedCategories,
            categoryBox,
          );
          await dishBox.add(dish);
          importedDishes[dishName] = dish;
          result.importedDishes++;
        } else {
          // Bestehendes Gericht mergen
          if (mode == ImportMode.smartMerge) {
            bool updated = await _mergeDishData(
              existingDish,
              dishData,
              importedCategories,
              categoryBox,
            );
            if (updated) {
              await existingDish.save();
              result.mergedDishes++;
            }
          }
          importedDishes[dishName] = existingDish;
        }
      }
    }

    // Tage importieren
    if (importData.containsKey('days')) {
      Map<String, dynamic> days = importData['days'];
      for (var dayKey in days.keys) {
        int dayIndex = int.tryParse(dayKey) ?? -1;
        if (dayIndex == -1) continue;

        var dayData = days[dayKey];
        Day? existingDay = dayBox.get(dayIndex);

        if (existingDay == null ||
            existingDay.entries == null ||
            existingDay.entries!.isEmpty) {
          // Neuen Tag erstellen
          Day day = await _createDayFromData(dayData, importedDishes, dishBox);
          await dayBox.put(dayIndex, day);
          result.importedDays++;
        } else if (mode == ImportMode.smartMerge) {
          // Bestehenden Tag mergen
          bool updated = await _mergeDayData(
            existingDay,
            dayData,
            importedDishes,
            dishBox,
          );
          if (updated) {
            await dayBox.put(dayIndex, existingDay);
            result.mergedDays++;
          }
        }
      }
    }

    return result;
  }

  // Hilfsmethoden für Smart Merging
  Category? _findCategoryByName(Box<Category> categoryBox, String name) {
    return categoryBox.values.cast<Category?>().firstWhere(
      (cat) => cat?.name.toLowerCase() == name.toLowerCase(),
      orElse: () => null,
    );
  }

  Dish? _findDishByName(Box<Dish> dishBox, String name) {
    return dishBox.values.cast<Dish?>().firstWhere(
      (dish) => dish?.name?.toLowerCase() == name.toLowerCase(),
      orElse: () => null,
    );
  }

  Future<bool> _mergeCategoryData(
    Category existing,
    Map<String, dynamic> newData,
  ) async {
    bool updated = false;

    // Farbe aktualisieren falls nicht gesetzt
    if (existing.color == null && newData['color'] != null) {
      existing.color = newData['color'];
      updated = true;
    }

    return updated;
  }

  Future<bool> _mergeDishData(
    Dish existing,
    Map<String, dynamic> newData,
    Map<String, Category> importedCategories,
    Box<Category> categoryBox,
  ) async {
    bool updated = false;

    // Notiz hinzufügen/erweitern
    if (newData['note'] != null && newData['note'].toString().isNotEmpty) {
      String newNote = newData['note'].toString();
      if (existing.note == null || existing.note!.isEmpty) {
        existing.note = newNote;
        updated = true;
      } else if (!existing.note!.contains(newNote)) {
        existing.note = '${existing.note}\n\n--- Importiert ---\n$newNote';
        updated = true;
      }
    }

    // Kategorien mergen
    if (newData.containsKey('categories') && newData['categories'] != null) {
      List<Category> newCategories = [];
      Set<String> existingCatNames =
          existing.categories?.map((c) => c.name.toLowerCase()).toSet() ?? {};

      // Bestehende Kategorien beibehalten
      if (existing.categories != null) {
        newCategories.addAll(existing.categories!);
      }

      // Neue Kategorien hinzufügen
      for (var catData in newData['categories']) {
        String catName = catData['name'] ?? '';
        if (catName.isNotEmpty &&
            !existingCatNames.contains(catName.toLowerCase())) {
          Category? category =
              importedCategories[catName] ??
              _findCategoryByName(categoryBox, catName);
          if (category != null) {
            newCategories.add(category);
            updated = true;
          }
        }
      }

      if (updated) {
        existing.categories = HiveList(categoryBox, objects: newCategories);
      }
    }

    return updated;
  }

  Future<Dish> _createDishFromData(
    Map<String, dynamic> dishData,
    Map<String, Category> importedCategories,
    Box<Category> categoryBox,
  ) async {
    // Kategorien für das Gericht finden
    HiveList<Category>? dishCategories;
    if (dishData.containsKey('categories') && dishData['categories'] != null) {
      List<Category> foundCategories = [];
      for (var catData in dishData['categories']) {
        String catName = catData['name'] ?? '';
        Category? category =
            importedCategories[catName] ??
            _findCategoryByName(categoryBox, catName);
        if (category != null) {
          foundCategories.add(category);
        }
      }
      if (foundCategories.isNotEmpty) {
        dishCategories = HiveList(categoryBox, objects: foundCategories);
      }
    }

    Dish dish = Dish(
      name: dishData['name'],
      note: dishData['note'],
      deleted: false,
      lastCookedDay: -1,
    );

    dish.categories = dishCategories;
    return dish;
  }

  Future<Day> _createDayFromData(
    Map<String, dynamic> dayData,
    Map<String, Dish> importedDishes,
    Box<Dish> dishBox,
  ) async {
    List<Dish> dayDishes = [];

    if (dayData.containsKey('entries')) {
      for (var dishData in dayData['entries']) {
        String dishName = dishData['name'] ?? '';
        Dish? dish =
            importedDishes[dishName] ?? _findDishByName(dishBox, dishName);

        if (dish != null) {
          dayDishes.add(dish);
        }
      }
    }

    Day day = Day();
    if (dayDishes.isNotEmpty) {
      day.entries = HiveList(dishBox, objects: dayDishes);
    }
    return day;
  }

  Future<bool> _mergeDayData(
    Day existing,
    Map<String, dynamic> dayData,
    Map<String, Dish> importedDishes,
    Box<Dish> dishBox,
  ) async {
    if (!dayData.containsKey('entries')) return false;

    Set<String> existingDishNames =
        existing.entries?.map((d) => d.name?.toLowerCase() ?? '').toSet() ?? {};
    List<Dish> allDishes = List.from(existing.entries ?? []);
    bool updated = false;

    for (var dishData in dayData['entries']) {
      String dishName = dishData['name'] ?? '';
      if (dishName.isNotEmpty &&
          !existingDishNames.contains(dishName.toLowerCase())) {
        Dish? dish =
            importedDishes[dishName] ?? _findDishByName(dishBox, dishName);
        if (dish != null) {
          allDishes.add(dish);
          updated = true;
        }
      }
    }

    if (updated) {
      existing.entries = HiveList(dishBox, objects: allDishes);
    }

    return updated;
  }

  void _showImportResultDialog(BuildContext context, ImportResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Import abgeschlossen'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.importedCategories > 0 ||
                    result.importedDishes > 0 ||
                    result.importedDays > 0) ...[
                  Text(
                    'Neu hinzugefügt:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (result.importedCategories > 0)
                    _buildStatRow(
                      Icons.category,
                      '${result.importedCategories} Kategorien',
                    ),
                  if (result.importedDishes > 0)
                    _buildStatRow(
                      Icons.restaurant,
                      '${result.importedDishes} Gerichte',
                    ),
                  if (result.importedDays > 0)
                    _buildStatRow(
                      Icons.calendar_today,
                      '${result.importedDays} Tage',
                    ),
                  SizedBox(height: 8),
                ],
                if (result.mergedCategories > 0 ||
                    result.mergedDishes > 0 ||
                    result.mergedDays > 0) ...[
                  Text(
                    'Zusammengeführt:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (result.mergedCategories > 0)
                    _buildStatRow(
                      Icons.merge,
                      '${result.mergedCategories} Kategorien',
                    ),
                  if (result.mergedDishes > 0)
                    _buildStatRow(
                      Icons.merge,
                      '${result.mergedDishes} Gerichte',
                    ),
                  if (result.mergedDays > 0)
                    _buildStatRow(Icons.merge, '${result.mergedDays} Tage'),
                  SizedBox(height: 8),
                ],
                if (result.skippedItems > 0) ...[
                  Row(
                    children: [
                      Icon(Icons.skip_next, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('${result.skippedItems} übersprungen'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Bestehende Hilfsmethoden
  String _generateNewCategoryId(Box<Category> categoryBox) {
    int maxId = 0;
    for (var category in categoryBox.values) {
      int? id = int.tryParse(category.id);
      if (id != null && id > maxId) {
        maxId = id;
      }
    }
    return (maxId + 1).toString();
  }

  int _getNextCategoryOrder(Box<Category> categoryBox) {
    int maxOrder = 0;
    for (var category in categoryBox.values) {
      if (category.order > maxOrder) {
        maxOrder = category.order;
      }
    }
    return maxOrder + 1;
  }
}
