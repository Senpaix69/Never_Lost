import 'package:flutter/material.dart';
import 'package:my_timetable/pages/timetable/add_subject_page.dart';
import 'package:my_timetable/services/database.dart';
import 'package:my_timetable/utils.dart'
    show
        isCurrentSlot,
        isNextSlot,
        sortTimeTables,
        weekdays,
        emptyWidget,
        MyCustomScrollBehavior;
import 'package:my_timetable/widgets/animate_route.dart' show SlideRightRoute;
import 'package:my_timetable/widgets/dialog_boxs.dart' show confirmDialogue;
import 'package:my_timetable/widgets/timetable_box.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw "can not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Time Table",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[actions(context)],
        bottom: navigatorDays(),
      ),
      drawer: SafeArea(
        child: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        'assets/prof.png',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Projected By Senpai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      tileColor: Colors.blue.withAlpha(200),
                      title: const Text(
                        'Check My Github',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      onTap: () => _launchURL("https://github.com/Senpaix69"),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      tileColor: Colors.blue.withAlpha(200),
                      title: const Text(
                        'Check My Insta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                      onTap: () => _launchURL(
                          "https://instagram.com/senpaii_x69?igshid=YmMyMTA2M2Y="),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      tileColor: Colors.blue.withAlpha(200),
                      title: const Text(
                        'Rest Coming Soon 😃',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                scrollBehavior: MyCustomScrollBehavior(),
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
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(SlideRightRoute(page: const AddSubject()));
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
      preferredSize: const Size.fromHeight(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            Text(
              weekdays[_currentPage],
              style: TextStyle(
                letterSpacing: 1.0,
                color: _today == _currentPage ? Colors.blue[100] : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
