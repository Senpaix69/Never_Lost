import 'dart:io' show File, HttpClient, HttpStatus;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neverlost/widgets/dialog_boxs.dart' show confirmDialogue;
import 'package:url_launcher/url_launcher.dart';

const List<String> weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

List<String> removeEmptyFilesAndImages(List<String> files) {
  return files.where((file) => file.trim().isNotEmpty).toList();
}

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

Future<bool> deleteFolder(final folder, BuildContext context) async {
  return await confirmDialogue(
    context: context,
    title: "Delete Folder",
    message: "Delete ${folder.name} folder?",
  );
}

String? textValidate(String? value) {
  if (value == null || value.isEmpty) {
    return "Please fill this field";
  }
  return null;
}

String? passwordValidate(String? value) {
  if (value == null || value.isEmpty) {
    return "Please fill this field";
  }
  if (value.length < 6) {
    return 'Please enter at least 6 characters';
  }
  return null;
}

String? rePasswordValidate(String? value, String pass) {
  if (value == null || value.isEmpty) {
    return "Please fill this field";
  }
  if (value != pass) {
    return 'Password does not match';
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
  if (day < 0) return "";
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

void launchURL(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw "can not launch $url";
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
          color: Colors.grey[400],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          message,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 20.0, left: 10.0, right: 10.0),
      backgroundColor: Theme.of(context).primaryColorDark,
      showCloseIcon: true,
      closeIconColor: Colors.white,
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
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

Future<bool> checkConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    try {
      final client = HttpClient();
      final request = await client
          .getUrl(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 4));
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  return false;
}

Future<void> deleteAllFiles({
  required List<String> files,
  required List<String> images,
}) async {
  for (final item in files) {
    final file = File(item);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  for (final item in images) {
    final file = File(item);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}

Future<List<int>?> compressImage({
  required String filePath,
  int quality = 60,
}) async {
  try {
    final result = await FlutterImageCompress.compressWithFile(
      filePath,
      quality: quality,
    );
    return result;
  } catch (e) {
    return null;
  }
}
