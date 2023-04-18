import 'package:flutter/material.dart';
import 'package:my_timetable/pages/timetable/add_subject_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/utils.dart'
    show isCurrentSlot, isNextSlot, sortTimeTables, weekdays, emptyWidget;
import 'package:my_timetable/widgets/animate_route.dart' show SlideRightRoute;
import 'package:my_timetable/widgets/dialog_boxs.dart' show confirmDialogue;
import 'package:my_timetable/widgets/timetable_box.dart';

class TimeTablePage extends StatefulWidget {
  const TimeTablePage({super.key});
  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
    Future.delayed(
      const Duration(milliseconds: 400),
      () => _isPageChanging = false,
    );
  }

  void setNextSlot(final List<dynamic> timeTables) {
    bool nextSlot = false;
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
          nextSlot: nextSlot ? false : isSlotNext,
          currentSlot: isSlot,
        );
        if (!nextSlot && isSlotNext) {
          nextSlot = true;
        }
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

  void deleteTimeTable(int id) async {
    bool confirmDel = await confirmDialogue(
        context: context, message: "Do you really want to delete timetable?");
    if (confirmDel) {
      await _database.deleteTimeTable(id: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    weekdays[_currentPage],
                    style: TextStyle(
                      letterSpacing: 1.0,
                      color: _today == _currentPage
                          ? Colors.red[400]
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
                      color: Colors.grey[400],
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
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                );
              }
              return PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weekdays.length,
                controller: _pageController,
                onPageChanged: (value) {
                  _currentPage = value;
                },
                itemBuilder: (context, ind) {
                  final timeTables = [...snapshot.data!];
                  final currentDay = weekdays[ind];
                  timeTables.retainWhere((timeTable) => timeTable.dayTime
                      .any((dayTime) => dayTime.day == currentDay));

                  setNextSlot(timeTables);
                  if (timeTables.isEmpty) {
                    return emptyWidget(
                      icon: Icons.calendar_today,
                      message: "No TimeTable Added Yet",
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    padding: const EdgeInsets.all(6.0),
                    decoration: null,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      itemCount: timeTables.length,
                      itemBuilder: (context, index) {
                        final timeTable = timeTables[index];
                        return TimeTableBox(
                          timeTable: timeTable,
                          currentDay: weekdays[_currentPage],
                          callback: deleteTimeTable,
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
