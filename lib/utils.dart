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
  timeTables.sort((a, b) {
    final timeA = DateFormat('hh:mm a').parse(a.dayTime[0].startTime);
    final timeB = DateFormat('hh:mm a').parse(b.dayTime[0].startTime);
    return timeA.compareTo(timeB);
  });

  for (final timeTable in timeTables) {
    final dayTimes = timeTable.dayTime;
    dayTimes.sort((a, b) {
      final timeA = DateFormat('hh:mm a').parse(a.startTime);
      final timeB = DateFormat('hh:mm a').parse(b.startTime);
      return timeA.compareTo(timeB);
    });
  }
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
