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
