import 'package:flutter/material.dart';
import 'package:frontend/core/utils.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onTap;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int weekOffset = 0;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final weekDates = generatesWeekDates(weekOffset);
    String monthName = DateFormat("MMMM").format(weekDates.first);

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      weekOffset--;
                    });
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      weekOffset++;
                    });
                  },
                  icon: Icon(Icons.arrow_forward_ios)),
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 25,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                itemBuilder: (context, index) {
                  final date = weekDates[index];
                  bool isSelected =
                      DateFormat('d').format(widget.selectedDate) ==
                              DateFormat('d').format(date) &&
                          widget.selectedDate.month == date.month &&
                          widget.selectedDate.year == date.year;

                  return GestureDetector(
                    onTap: ()=> widget.onTap(date),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      width: 70,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepOrange : null,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : Colors.grey.shade300,
                            width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat("d").format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : null,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              )),
                          const SizedBox(height: 5),
                          Text(DateFormat("E").format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : null,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        )
      ],
    );
  }
}
