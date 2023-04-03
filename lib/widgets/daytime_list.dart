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
  late ScrollController _listController;
  List<DayTime> _filteredDays = [];

  @override
  void initState() {
    super.initState();
    _filteredDays = widget.currentDay == null
        ? widget.days
        : widget.days.where((day) => day.day == widget.currentDay).toList();
    _listController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _listController,
      shrinkWrap: true,
      itemCount: _filteredDays.length,
      itemBuilder: (BuildContext context, int index) {
        final DayTime day = _filteredDays[index];
        return _buildItem(day, index);
      },
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
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: isAdding ? 14.0 : 18.0,
          ),
        ),
      ),
      title: Text(
        isAdding ? day.day : day.roomNo,
        style: const TextStyle(
          color: Colors.amber,
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
              icon: Icon(
                Icons.delete,
                color: Colors.grey[200],
              ),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            )
          : null,
    );
  }
}
