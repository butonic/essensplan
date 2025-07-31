import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import '../model/dish.dart';
import '../model/category.dart';
import '../pages/edit_dish.dart';

class ViewDishPage extends StatefulWidget {
  const ViewDishPage({super.key});

  @override
  _ViewDishPageState createState() => _ViewDishPageState();
}

class _ViewDishPageState extends State<ViewDishPage> {
  static final GlobalKey<ScaffoldState> _viewDishKey =
      GlobalKey<ScaffoldState>();

  Future<void> _editDish(BuildContext context, Dish d) async {
    final editedArgs = await Navigator.pushNamed(
      context,
      '/dishes/edit',
      arguments: EditDishArguments(d, Hive.box<Category>('categoryBox')),
    );

    if (editedArgs is EditDishArguments) {
      await editedArgs.dish.save();
    }
  }

  List<InlineSpan> _buildInteractiveSpans(BuildContext context, String text) {
    final RegExp urlRegExp = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );
    final List<InlineSpan> spans = [];
    int start = 0;

    for (final match in urlRegExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final String url = match.group(0)!;

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Link kopiert: $url')));
            },
            child: Text(
              url,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final ViewDishArguments args =
        ModalRoute.of(context)!.settings.arguments as ViewDishArguments;
    Dish dish = args.dish;

    return Scaffold(
      key: _viewDishKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gericht'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 4, 0),
              child: const Text(
                'Name',
                style: TextStyle(color: Colors.black54, fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 4),
              child: Text(
                dish.name ?? 'Fehlender Name',
                style: const TextStyle(color: Colors.black, fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 4, 0),
              child: const Text(
                'Notizen',
                style: TextStyle(color: Colors.black54, fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black45,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                  children: _buildInteractiveSpans(
                    context,
                    dish.note ?? 'Keine Notiz',
                  ),
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Tags(
                itemCount: dish.categories?.length ?? 0,
                itemBuilder: (int index) {
                  final c = dish.categories?.elementAt(index);

                  return ItemTags(
                    key: Key(index.toString()),
                    index: index,
                    title: c?.name ?? 'Fehlender Name',
                    active: true,
                    activeColor: c?.color != null
                        ? Color(c!.color!)
                        : Colors.grey,
                    border: Border.all(
                      color: c?.color != null ? Color(c!.color!) : Colors.grey,
                    ),
                    customData: c,
                    pressEnabled: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _editDish(context, dish).then((res) {
            setState(() {});
          });
        },
        child: Icon(Icons.edit),
        //backgroundColor: Colors.yellow,
      ),
    );
  }
}

class ViewDishArguments {
  final Dish dish;

  ViewDishArguments(this.dish);
}
