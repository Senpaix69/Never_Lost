import 'package:flutter/material.dart';
import 'package:my_timetable/services/daytime.dart';

class DayTimeList extends StatefulWidget {
  final List<DayTime> days;
  final String? currentDay;
  final Function(int)? callBack;

  const DayTimeList({
    super.key,
    required this.days,
    this.currentDay,
    this.callBack,
  });

  @override
  State<StatefulWidget> createState() => _DayTimeListState();
}

class _DayTimeListState extends State<DayTimeList> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: widget.days.length * 70.5,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        reverse: widget.callBack != null,
        shrinkWrap: true,
        itemCount: widget.days.length,
        itemBuilder: (BuildContext context, int index) {
          final DayTime day = widget.days[index];
          return _buildItem(day, index);
        },
      ),
    );
  }

  Widget _buildItem(DayTime day, int index) {
    bool isAdding = widget.callBack != null;
    String alpha = String.fromCharCode('A'.codeUnitAt(0) + index);
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Text(
          isAdding ? day.roomNo : "Slot $alpha",
          style: TextStyle(
            color: day.currentSlot
                ? Colors.yellow
                : day.nextSlot
                    ? Colors.red
                    : Colors.cyan[800],
            fontWeight: FontWeight.bold,
            fontSize: isAdding ? 14.0 : 18.0,
          ),
        ),
      ),
      title: Text(
        isAdding ? day.day : day.roomNo,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${day.startTime} - ${day.endTime}',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      trailing: widget.callBack != null
          ? IconButton(
              onPressed: () => widget.callBack!(index),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            )
          : day.nextSlot || day.currentSlot
              ? TextButton.icon(
                  label: Text(
                    day.currentSlot ? "Now" : "Next",
                    style: TextStyle(
                      color: day.currentSlot ? Colors.yellow : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
                  icon: Icon(
                    Icons.scatter_plot,
                    color: day.currentSlot ? Colors.yellow : Colors.red,
                  ),
                )
              : null,
    );
  }
}
