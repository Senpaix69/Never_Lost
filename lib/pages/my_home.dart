import 'package:flutter/material.dart';
import 'package:my_timetable/pages/add_subject.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/utils.dart' show weekdays;
import 'package:my_timetable/widgets/animate_route.dart' show SlideRightRoute;
import 'package:my_timetable/widgets/timetable_box.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late final DatabaseService _database;
  final int _today = DateTime.now().weekday - 1;
  int _currentPage = DateTime.now().weekday - 1;
  final PageController _pageController =
      PageController(initialPage: DateTime.now().weekday - 1);

  void handlePage(int increment) {
    setState(() {
      _currentPage = (_currentPage + increment) % weekdays.length;
    });
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  void initState() {
    _database = DatabaseService();
    _database.open();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.cyan[900],
        title: const Text("Time Table"),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(SlideRightRoute(page: const AddSubject()));
              },
              icon: const Icon(
                Icons.add,
              ))
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 40.0,
                    onPressed: () => handlePage(-1),
                    icon: Icon(
                      Icons.arrow_left,
                      color: Colors.cyan[800],
                    ),
                  ),
                  Text(
                    weekdays[_currentPage],
                    style: TextStyle(
                      letterSpacing: 1.0,
                      color: _today == _currentPage
                          ? Colors.cyan[600]
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => handlePage(1),
                    padding: EdgeInsets.zero,
                    iconSize: 40.0,
                    icon: Icon(
                      Icons.arrow_right,
                      color: Colors.cyan[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: StreamBuilder(
            stream: _database.allTimeTable,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.cyan,
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return noTimeTableAdded();
              }
              final timeTables = snapshot.data!;
              return PageView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: weekdays.length,
                controller: _pageController,
                onPageChanged: (value) => setState(() {
                  _currentPage = value;
                }),
                itemBuilder: (context, ind) {
                  final currentDay = weekdays[ind];
                  final filteredTimeTables = timeTables
                      .where((timeTable) => timeTable.dayTime
                          .any((dayTime) => dayTime.day == currentDay))
                      .toList();

                  if (filteredTimeTables.isEmpty) {
                    return noTimeTableAdded();
                  }
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    padding: const EdgeInsets.all(6.0),
                    decoration: null,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      itemCount: filteredTimeTables.length,
                      itemBuilder: (context, index) {
                        final timeTable = filteredTimeTables[index];
                        return TimeTableBox(
                          timeTable: timeTable,
                          currentDay: weekdays[_currentPage],
                        );
                      },
                    ),
                  );
                },
              );
            },
          )),
        ],
      ),
    );
  }
}

Center noTimeTableAdded() {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.calendar_today,
          size: 80.0,
          color: Colors.grey[300],
        ),
        const SizedBox(
          height: 15.0,
        ),
        Text(
          "No TimeTable Added Yet",
          style: TextStyle(
            color: Colors.grey[300],
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
