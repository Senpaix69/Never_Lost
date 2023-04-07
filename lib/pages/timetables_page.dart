import 'package:flutter/material.dart';
import 'package:my_timetable/pages/add_subject_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/utils.dart'
    show isCurrentSlot, isNextSlot, sortTimeTables, weekdays;
import 'package:my_timetable/widgets/animate_route.dart' show SlideRightRoute;
import 'package:my_timetable/widgets/timetable_box.dart';

class TimeTablesPage extends StatefulWidget {
  const TimeTablesPage({super.key});

  @override
  State<TimeTablesPage> createState() => _TimeTablesPageState();
}

class _TimeTablesPageState extends State<TimeTablesPage> {
  late final DatabaseService _database;
  late final PageController _pageController;
  final int _today = DateTime.now().weekday - 1;
  int _currentPage = DateTime.now().weekday - 1;
  int _previousPage = 0;
  bool _isPageChanging = false;

  void handlePage(int increment) {
    int newPage = _currentPage + increment;
    if (_isPageChanging || newPage < 0 || newPage >= weekdays.length) {
      return;
    }
    setState(() {
      _isPageChanging = true;
      _previousPage = _currentPage;
      _currentPage = (newPage >= weekdays.length) || (newPage < 0)
          ? _currentPage
          : newPage;
    });
    if (_previousPage != _currentPage) {
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      _isPageChanging = false;
    });
  }

  void setNextSlot(final List<dynamic> timeTables) {
    sortTimeTables(timeTables);
    String currentDay = weekdays[_today];
    for (final timeTable in timeTables) {
      final dayTimes = timeTable.dayTime;
      for (int i = 0; i < dayTimes.length; i++) {
        if (currentDay != dayTimes[i].day) {
          continue;
        }
        bool isSlot = isCurrentSlot(dayTimes[i].startTime, dayTimes[i].endTime);
        bool isSlotNext = isNextSlot(dayTimes[i].startTime);
        dayTimes[i] = dayTimes[i].copyWith(
          nextSlot: isSlotNext,
          currentSlot: isSlot,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: DateTime.now().weekday - 1);
    _database = DatabaseService();
    _database.open();
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
        backgroundColor: Colors.black,
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
              }
              final timeTables =
                  snapshot.data != null ? [...snapshot.data!] : [];
              return PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weekdays.length,
                controller: _pageController,
                onPageChanged: (value) {
                  _currentPage = value;
                },
                itemBuilder: (context, ind) {
                  final currentDay = weekdays[ind];
                  final filteredTimeTables = List.from(timeTables);
                  filteredTimeTables.retainWhere((timeTable) => timeTable
                      .dayTime
                      .any((dayTime) => dayTime.day == currentDay));

                  setNextSlot(filteredTimeTables);
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
