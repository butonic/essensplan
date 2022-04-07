import 'package:flutter/material.dart';

class DaysAgo extends StatelessWidget {
  final int days;

  final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  DaysAgo({
    Key? key,
    required this.days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int daysBetween(DateTime from, DateTime to) {
      from = DateTime(from.year, from.month, from.day);
      to = DateTime(to.year, to.month, to.day);
      return (to.difference(from).inHours / 24).floor();
    }

    final d = epoch.add(Duration(days: days));
    final n = DateTime.now();
    final diff = daysBetween(n, d);

    switch (diff) {
      case -1:
        return const Text('Gestern');
      case 0:
        return const Text('Heute');
      case 1:
        return const Text('Morgen');
      default:
        if (diff < 0) {
          return Text('vor ' + (diff * -1).toString() + ' Tagen');
        }
        return Text('in ' + diff.toString() + ' Tagen');
    }
  }
}
