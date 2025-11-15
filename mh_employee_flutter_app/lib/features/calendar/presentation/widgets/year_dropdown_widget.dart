import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearDropdownWidget extends StatelessWidget {
  final int selectedYear;
  final List<int> years;
  final Function(int?) onYearChanged;

  const YearDropdownWidget({
    Key? key,
    required this.selectedYear,
    required this.years,
    required this.onYearChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<int>(
        value: selectedYear,
        items: years.map((year) {
          return DropdownMenuItem(
            value: year,
            child: Text(
              year.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: onYearChanged,
        underline: Container(),
      ),
    );
  }
}
