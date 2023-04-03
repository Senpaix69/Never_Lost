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
