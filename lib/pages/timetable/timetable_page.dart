import 'package:flutter/material.dart';
import 'package:neverlost/pages/timetable/add_subject_page.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/utils.dart'
    show isCurrentSlot, isNextSlot, sortTimeTables, weekdays, emptyWidget;
import 'package:neverlost/widgets/animate_route.dart' show SlideRightRoute;
import 'package:neverlost/widgets/dialog_boxs.dart' show confirmDialogue;
import 'package:neverlost/widgets/timetable_box.dart';
import 'package:permission_handler/permission_handler.dart';

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
        curve: Curves.easeInOut,
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

  Future<bool> showConfirmDialog() async => await confirmDialogue(
        context: context,
        message:
            "You will not be able to get reminders notifications, do you want to enable notifications?",
        title: "Notifcations",
      );

  Future<void> requestPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      if (await showConfirmDialog()) {
        await Permission.notification.request();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: DateTime.now().weekday - 1);
    _database = DatabaseService();
    _database.open();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestPermission();
    });
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
        elevation: 0.0,
        title: const Text(
          "Time Table",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[actions(context)],
        bottom: navigatorDays(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder(
            stream: _database.allTimeTable,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
              }
              return PageView.builder(
                itemCount: weekdays.length,
                controller: _pageController,
                onPageChanged: (value) => setState(() {
                  _currentPage = value;
                }),
                itemBuilder: (context, ind) {
                  final timeTables = [...snapshot.data!];
                  final currentDay = weekdays[ind];
                  timeTables.retainWhere((timeTable) => timeTable.dayTime
                      .any((dayTime) => dayTime.day == currentDay));

                  if (timeTables.isEmpty) {
                    return emptyWidget(
                      icon: Icons.calendar_today,
                      message: "No TimeTable Added Yet",
                    );
                  }
                  setNextSlot(timeTables);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    decoration: null,
                    child: ListView.builder(
                      shrinkWrap: true,
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

  Container actions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).focusColor,
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            SlideRightRoute(
              page: const AddSubject(),
            ),
          );
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSize navigatorDays() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 40.0,
              onPressed: () => handlePage(-1),
              icon: const Icon(
                Icons.arrow_left,
                color: Colors.white,
              ),
            ),
            Text.rich(
              TextSpan(
                text: weekdays[_currentPage],
                style: TextStyle(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).primaryColorLight,
                ),
                children: <InlineSpan>[
                  if (_today == _currentPage)
                    const TextSpan(
                        text: " (Today)",
                        style: TextStyle(
                          fontSize: 10,
                        )),
                ],
              ),
            ),
            IconButton(
              onPressed: () => handlePage(1),
              padding: EdgeInsets.zero,
              iconSize: 40.0,
              icon: const Icon(
                Icons.arrow_right,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
