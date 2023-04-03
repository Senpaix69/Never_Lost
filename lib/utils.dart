const List<String> weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
final RegExp timeRegex =
    RegExp(r'^[1-9](?:0|1|2)?:(?:[0-5][0-9])\s?(?:AM|PM)$');
final RegExp roomValid = RegExp(r'^[a-zA-Z]-\d{3}$');

String? textValidate(String? value) {
  if (value == null || value.isEmpty) {
    return "Please Enter Text";
  }
  return null;
}

String? dayValidate(String? value) {
  if (value == null || value.isEmpty) {
    return "Please Enter Day";
  }
  if (!weekdays.contains(value.split(" ").join(""))) {
    return "Format: Sunday";
  }
  return null;
}

String? roomValidate(String? value) {
  if (value == null || value.isEmpty) {
    return "Enter room no";
  }
  if (!roomValid.hasMatch(value)) {
    return "e.g Format: A-101";
  }
  return null;
}

String? validateTime(String? value) {
  if (value == null || value.isEmpty) {
    return "Enter Time";
  }
  if (!timeRegex.hasMatch(value)) {
    return "Invalid Format";
  }
  return null;
}
