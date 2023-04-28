import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const List<String> weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

Map<String, int> getDate(String day) {
  final today = DateTime.now();
  final weekDay = weekdays.indexOf(day) + 1;
  final difference = (weekDay - today.weekday) % 7;
  int date = today.day + difference;
  var month = today.month;
  var year = today.year;
  if (date > 31) {
    date -= 31;
    month += 1;
    if (month > 12) {
      month = 1;
      year += 1;
    }
  }
  return {
    "year": year,
    "month": month,
    "day": date,
  };
}

String? textValidate(String? value) {
  if (value == null || value.isEmpty) {
    return "Please fill this field";
  }
  return null;
}

bool isNextSlot(String startTime) {
  final dateFormat = DateFormat.jm();
  final parsedStartTime = dateFormat.parse(startTime);
  final currentTime = DateTime.now();

  final formattedStartTime = DateFormat('HH:mm').format(parsedStartTime);
  final formattedCurrentTime = DateFormat('HH:mm').format(currentTime);

  final dateTimeStartTime = DateTime.parse('1970-01-01 $formattedStartTime');
  final dateTimeCurrentTime =
      DateTime.parse('1970-01-01 $formattedCurrentTime');

  return dateTimeStartTime.isAfter(dateTimeCurrentTime);
}

bool isCurrentSlot(String startTime, String endTime) {
  final dateFormat = DateFormat.jm();
  final parsedStartTime = dateFormat.parse(startTime);
  final parsedEndTime = dateFormat.parse(endTime);
  final currentTime = DateTime.now();

  final formattedStartTime = DateFormat('HH:mm').format(parsedStartTime);
  final formattedEndTime = DateFormat('HH:mm').format(parsedEndTime);
  final formattedCurrentTime = DateFormat('HH:mm').format(currentTime);

  final dateTimeStartTime = DateTime.parse('1970-01-01 $formattedStartTime');
  final dateTimeEndTime = DateTime.parse('1970-01-01 $formattedEndTime');
  final dateTimeCurrentTime =
      DateTime.parse('1970-01-01 $formattedCurrentTime');

  return dateTimeStartTime.isBefore(dateTimeCurrentTime) &&
      dateTimeEndTime.isAfter(dateTimeCurrentTime);
}

void sortTimeTables(List<dynamic> timeTables) {
  for (int i = 0; i < timeTables.length; i++) {
    final aTime =
        DateFormat("hh:mm a").parse(timeTables[i].dayTime[0].startTime);
    for (int j = 0; j < timeTables.length; j++) {
      final bTime =
          DateFormat("hh:mm a").parse(timeTables[j].dayTime[0].startTime);
      if (bTime.isAfter(aTime)) {
        final temp = timeTables[i];
        timeTables[i] = timeTables[j];
        timeTables[j] = temp;
      }
    }
  }
}

String _getDaysLater(int day) {
  if (day == 0) return "Today";
  if (day == 1) return "Tomorrow";
  return "$day days remain";
}

String? getFormattedTime(String? date) {
  if (date == null) return null;
  DateTime parsedate = DateTime.parse(date);
  String isToday = _getDaysLater(parsedate.day - DateTime.now().day);
  String time = DateFormat("hh:mm a").format(parsedate);
  return '$time $isToday';
}

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

Center emptyWidget({required IconData icon, required String message}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: 60.0,
          color: Colors.grey,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          message,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 20.0, left: 5.0, right: 5.0),
      backgroundColor: Colors.grey[900],
      showCloseIcon: true,
      content: Text(
        message,
        style: TextStyle(color: Colors.grey[300]),
      ),
    ),
  );
}

void sortDayTimes(dynamic list) {
  for (int i = 0; i < list.length; i++) {
    final aTime = DateFormat("hh:mm a").parse(list[i].startTime);
    for (int j = 0; j < list.length; j++) {
      final bTime = DateFormat("hh:mm a").parse(list[j].startTime);
      if (bTime.isAfter(aTime)) {
        final temp = list[i];
        list[i] = list[j];
        list[j] = temp;
      }
    }
  }
}
