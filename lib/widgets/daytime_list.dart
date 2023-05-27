import 'package:flutter/material.dart';
import 'package:neverlost/services/timetable_services/daytime.dart';

class DayTimeList extends StatefulWidget {
  final List<DayTime> days;
  final String? currentDay;
  final bool reminder;
  final Function(int)? callBack;

  const DayTimeList({
    super.key,
    this.reminder = false,
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
    bool isReminder = widget.reminder;
    return ListTile(
      key: ValueKey(index),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        child: isAdding
            ? Text(
                day.roomNo,
                style: TextStyle(
                  color: Colors.grey[200],
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                isReminder ? Icons.access_time_filled_sharp : Icons.access_time,
                size: 35.0,
                color: day.currentSlot
                    ? Colors.lightBlue
                    : day.nextSlot
                        ? Colors.red
                        : Colors.grey[600],
              ),
      ),
      title: Text(
        isAdding ? day.day : day.roomNo,
        style: TextStyle(
          color: Colors.grey[200],
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${day.startTime} - ${day.endTime}',
        style: TextStyle(
          color: Colors.grey[200],
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
                      color: day.currentSlot ? Colors.lightBlue : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
                  icon: Icon(
                    Icons.label_important_sharp,
                    color: day.currentSlot ? Colors.lightBlue : Colors.red,
                  ),
                )
              : null,
    );
  }
}
