3 Screens

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
  - [x] name
  - [x] keine zutaten
  - [x] freitext zum anzeigen wenn man auf das gericht klickt
  - [x] (zutaten) tags
    - aus liste auswählen?
    - kann zb auch `vegetarisch` sein
  - kategorien (hauptspeise, dessert ... suppe, backwaren)
  - medien feld für bilder / pdf / anhänge
  - beim speichern warnen wenn keine kategorie angegeben wurde (otional)
- Liste mit
  - Name
  - zutaten Tags
  - wann das letzte / nächste mal

Alle Gerichte nach Kategorie
- zb um zu gucken in welcher kategorie man noch gerichte suchen müsste
- oder oum die frage nach "hast du mal ein gutes brot" zu beantworten

Hinzufügen Dialog
- Liste wie bei den gerichten
- suche/filter nach
  - name (suche)
  - kategorien (filtert die zutaten tags)
  - zutaten tags (1x tippen = und)

datenmodell:
tage = tage seit unix epoch
dish (int id PK, text name, ... )
day_dishes (int day, int dish_id FK dish.id, order int)
