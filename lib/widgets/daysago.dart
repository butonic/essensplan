import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class DaysAgo extends StatelessWidget {
  final int days;

  final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  DaysAgo({
    Key key,
    this.days,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO nur Tage + Morgen, Heute, Gestern
    return Text(timeago.format(epoch.add(Duration(days: days)),
        locale:
            'de', // TODO Localizations.localeOf(context); braucht localization,
        allowFromNow: true));
  }
}
