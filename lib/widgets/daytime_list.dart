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
      reverse: true,
      shrinkWrap: true,
      itemCount: _filteredDays.length,
      itemBuilder: (BuildContext context, int index) {
        final DayTime day = _filteredDays[index];
        return _buildItem(day, index);
      },
    );
  }

  Widget _buildItem(DayTime day, int index) {
    return ListTile(
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Text(
          "Slot",
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
      title: Text(
        day.roomNo,
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
              onPressed: () {
                widget.callBack!(index);
                setState(() {
                  _filteredDays.removeAt(index);
                });
              },
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
