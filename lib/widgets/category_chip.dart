import 'package:flutter/material.dart';

typedef CategoryChipTapCallback = void Function(
    CategoryChipSelection selection);

enum CategoryChipSelection { unselected, selected, excluded }

class CategoryChip extends StatefulWidget {
  CategoryChip(
      {Key? key,
      required this.label,
      required this.backgroundColor,
      required this.textColor,
      required this.onTap})
      : super(key: key);
  final Text label;
  final Color backgroundColor;
  final Color textColor;
  final CategoryChipTapCallback onTap;

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  CategoryChipSelection selection = CategoryChipSelection.unselected;
  void nextSelection() {
    setState(() {
      switch (this.selection) {
        case CategoryChipSelection.unselected:
          this.selection = CategoryChipSelection.selected;
          break;
        case CategoryChipSelection.selected:
          this.selection = CategoryChipSelection.excluded;
          break;
        case CategoryChipSelection.excluded:
          this.selection = CategoryChipSelection.unselected;
          break;
      }
      this.widget.onTap(this.selection);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Chip(
          shape: StadiumBorder(side: BorderSide(color: widget.backgroundColor)),
          label: widget.label,
          labelStyle: TextStyle(
              decoration: this.selection == CategoryChipSelection.excluded
                  ? TextDecoration.lineThrough
                  : null,
              color: this.selection == CategoryChipSelection.unselected
                  ? widget.textColor
                  : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400),
          backgroundColor: this.selection != CategoryChipSelection.unselected
              ? widget.backgroundColor
              : Colors.white,
          // reduce size
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelPadding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
          visualDensity: VisualDensity(vertical: -4),
          // shadow
          elevation: 3.0,
          shadowColor: Colors.black),
      onTap: nextSelection,
    );
  }
}
