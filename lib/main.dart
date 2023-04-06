import 'package:flutter/material.dart';
import 'package:my_timetable/constants/routes.dart';
import 'package:my_timetable/pages/add_subject_page.dart';
import 'package:my_timetable/pages/main_home.dart';
import 'package:my_timetable/pages/timetables_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Never Lost",
      home: const MyHomePage(),
      routes: {
        timeTablePage: (context) => const TimeTablesPage(),
        addSubjectPage: (context) => const AddSubject(),
      },
    ),
  );
}
