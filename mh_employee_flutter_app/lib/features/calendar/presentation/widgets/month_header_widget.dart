// widgets/month_header_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthHeaderWidget extends StatelessWidget {
  final DateTime focusedDay;
  final Function() onPreviousMonth;
  final Function() onNextMonth;
  final bool isLoading;

  const MonthHeaderWidget({
    Key? key,
    required this.focusedDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
          ),
          Row(
            children: [
              Text(
                DateFormat('MMMM').format(focusedDay),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}
