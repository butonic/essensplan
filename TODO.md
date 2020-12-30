2 Screens

burger menü:
- Woche bzw nächste tage / planung
- Gerichte

Startseite:
- [x] Die nächsten Tage, oben ist heute, infinite scroll
- [x] leerer tag: 2 icons, 1. "+",  2. notizblock im notizen hinzuzufügen
  - leeres feld bleibt leer
  - durch antippen erscheinen die aktionen
    - dish hinzufügen
    - note hinzufügen
    - bearbeiten
    - am ende der kachel oder oder als popup
  - je gericht eine zeile
- wenn der tag nicht leer ist: tippen auf ein element (gericht oder notiz) erscheint ein menü mit bearbeiten, notiz hinzufügen, gericht hinzufügen oder löschen
- Lange namen möglich -> mehrzeilig
- [x] statt woche infinite scroll
- gericht hinzufügen -> Gerichte seite
- [x] keine tageszeiten
- Notiz, zb um zu notieren: grillen bei oma und opa, alicante, mit kartoffeln
- dnd um gerichte oder notizen zu verschieben

notizen werden nicht langfristig gespeichert / müssen nicht gemanaged werden

Gerichte Liste
- Gericht hinzufügen
  - db
    - [x] name
    - [x] keine zutaten
    - [x] freitext zum anzeigen wenn man auf das gericht klickt
    - [x] (zutaten) tags
  - ui
    - filter/sortieren nach
      - name (suche), see https://medium.com/@thedome6/how-to-create-a-searchable-filterable-listview-in-flutter-4faf3e300477
      - kategorien (filtert die zutaten tags)
      - zutaten tags (1x tippen = und)
    - Liste mit
      - sortieren nach eigenschaft mit custom compare() https://stackoverflow.com/a/55856231
      - [ ] name
      - [ ] (zutaten) tags
      - [ ] freitext zum anzeigen wenn man auf das gericht klickt
        - aus liste auswählen?
        - kann zb auch `vegetarisch` sein
      - [ ] wann das letzte / nächste mal
    - nach hinzufügen zum angelegten gericht scrollen
  - kategorien (hauptspeise, dessert ... suppe, backwaren)
  - medien feld für bilder / pdf / anhänge
  - beim speichern warnen wenn keine kategorie angegeben wurde (otional)

Alle Gerichte nach Kategorie
- zb um zu gucken in welcher kategorie man noch gerichte suchen müsste
- oder um die frage nach "hast du mal ein gutes brot" zu beantworten
- evtl mit https://flutterawesome.com/a-flutter-listview-in-which-items-can-be-grouped-into-sections/

datenmodell:
tage = tage seit unix epoch
dish (int id PK, text name, ... )
day_dishes (int day, int dish_id FK dish.id, order int)

# HIVE
- [x] modell umstellen
- [x] dish / notiz von tag entfernen by swipe
- [x] kategorien bearbeiten
- [x] notiz hinzufügen
- [ ] tags bearbeiten

# v0.0.1
- [x] suche fixen
- [x] mehrere kategorien = oder suche
  - [x] umschalter oder/und
- [x] gericht im plan auswählen = bearbeiten oder zumindest ansehen
    - da stehen ja die notizen
- [ ] notiz = url feld zum anklicken https://pub.dev/packages/flutter_linkify
    - view dish mit edit button
    - notiz kann emojis und urls enthalten
    - anhänge, zb bilder ... mit preview
- [x] platz verbrauch tag und gericht nebeneinander
  - tag selektieren -> + button zum hinzufügen, 2. notiz button zum notiz hinzufügen
- [x] alle kategorien sehen

# backlog
- [ ] bild aus der url laden
- [ ] export bei gerätewechsel oder sync
  - webdav per https://github.com/timestee/dart-webdav/issues/15

  Unhandled exception:
Bad state: No element
#0      Iterable.last (dart:core/iterable.dart:542:7)
#1      _ImmutableMapValueIterable.Eval (:0:1)
#2      Object.noSuchMethod (dart:core-patch/object_patch.dart:51:5)
#3      int./ (dart:core-patch/integers.dart:28:36)
#4      _PositionedListState._schedulePositionNotificationUpdate.<anonymous closure> (package:scrollable_positioned_list/src/positioned_list.dart:321:53)
#5      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1117:15)
#6      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1063:9)
#7      SchedulerBinding.scheduleWarmUpFrame.<anonymous closure> (package:flutter/src/scheduler/binding.dart:864:7)
#8      _rootRun (dart:async/zone.dart:1182:47)
#9      _CustomZone.run (dart:async/zone.dart:1093:19)
#10     _CustomZone.runGuarded (dart:async/zone.dart:997:7)
#11     _CustomZone.bindCallbackGuarded.<anonymous closure> (dart:async/zone.dart:1037:23)
#12     _rootRun (dart:async/zone.dart:1190:13)
#13     _CustomZone.run (dart:async/zone.dart:1093:19)
#14     _CustomZone.bindCallback.<anonymous closure> (dart:async/zone.dart:1021:23)
#15     Timer._createTimer.<anonymous closure> (dart:async-patch/timer_patch.dart:18:15)
#16     _Timer._runTimers (dart:isolate-patch/timer_impl.dart:397:19)
#17     _Timer._handleMessage (dart:isolate-patch/timer_impl.dart:428:5)
#18     _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:168:12)
