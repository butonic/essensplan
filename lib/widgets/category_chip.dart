import 'package:flutter/material.dart';

typedef CategoryChipTapCallback =
    void Function(CategoryChipSelection selection);

enum CategoryChipSelection { unselected, selected, excluded }

class CategoryChip extends StatefulWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });
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
      switch (selection) {
        case CategoryChipSelection.unselected:
          selection = CategoryChipSelection.selected;
          break;
        case CategoryChipSelection.selected:
          selection = CategoryChipSelection.excluded;
          break;
        case CategoryChipSelection.excluded:
          selection = CategoryChipSelection.unselected;
          break;
      }
      widget.onTap(selection);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: nextSelection,
      child: Chip(
        shape: StadiumBorder(side: BorderSide(color: widget.backgroundColor)),
        label: widget.label,
        labelStyle: TextStyle(
          decoration: selection == CategoryChipSelection.excluded
              ? TextDecoration.lineThrough
              : null,
          color: selection == CategoryChipSelection.unselected
              ? widget.textColor
              : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        backgroundColor: selection != CategoryChipSelection.unselected
            ? widget.backgroundColor
            : Colors.white,
        // reduce size
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelPadding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
        visualDensity: const VisualDensity(vertical: -4),
        // shadow
        elevation: 3.0,
        shadowColor: Colors.black,
      ),
    );
  }
}
