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
