import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef CallbackAction<T> = void Function(T, T);

class MyFilterSheet extends StatefulWidget {
  final CallbackAction callback;
  const MyFilterSheet({
    super.key,
    required this.callback,
  });

  @override
  State<MyFilterSheet> createState() => _MyFilterSheetState();
}

class _MyFilterSheetState extends State<MyFilterSheet> {
  late final SharedPreferences _sp;
  Map<String, bool> _filter = {'attachment': false, 'imp': false};
  Map<String, bool> _sort = {'asc': true, 'desc': false};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setData();
    });
  }

  Future<void> setData() async {
    _sp = await SharedPreferences.getInstance();
    final filter = _sp.getString("note_filter");
    if (filter != null) {
      final data = jsonDecode(filter);
      _filter = {'attachment': data['attachment'], 'imp': data['imp']};
    }
    final sort = _sp.getString("note_sort");
    if (sort != null) {
      final data = jsonDecode(sort);
      _sort = {'asc': data['asc'], 'desc': data['desc']};
    }
    setState(() {});
  }

  void setFilterToSP() {
    _sp.setString('note_filter', jsonEncode(_filter));
    widget.callback(_filter, _sort);
    Navigator.of(context).pop();
  }

  void setSortToSP() {
    _sp.setString('note_sort', jsonEncode(_sort));
    widget.callback(_filter, _sort);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 500.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Filters",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              myFilterButton(
                action: () {
                  setState(
                    () => _filter = {
                      'attachment': false,
                      'imp': !_filter['imp']!
                    },
                  );
                  setFilterToSP();
                },
                isActive: _filter['imp']!,
                context: context,
                title: "Important",
              ),
              const SizedBox(
                width: 10.0,
              ),
              myFilterButton(
                action: () {
                  setState(
                    () => _filter = {
                      'attachment': !_filter['attachment']!,
                      'imp': false
                    },
                  );
                  setFilterToSP();
                },
                isActive: _filter['attachment']!,
                context: context,
                title: "Attachments",
              ),
            ],
          ),
          Divider(
            height: 60.0,
            color: Theme.of(context).primaryColorDark,
          ),
          const Text(
            "Sort by date",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              myFilterButton(
                action: () {
                  if (!_sort['asc']!) {
                    setState(
                      () => _sort = {'asc': true, 'desc': false},
                    );
                    setSortToSP();
                  }
                },
                isActive: _sort['asc']!,
                context: context,
                title: "Ascending Order",
              ),
              const SizedBox(
                width: 10.0,
              ),
              myFilterButton(
                action: () {
                  if (!_sort['desc']!) {
                    setState(
                      () => _sort = {'asc': false, 'desc': true},
                    );
                    setSortToSP();
                  }
                },
                isActive: _sort['desc']!,
                context: context,
                title: "Descending Order",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

ElevatedButton myFilterButton({
  required bool isActive,
  required BuildContext context,
  required String title,
  required VoidCallback action,
}) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: isActive
          ? MaterialStateColor.resolveWith(
              (states) => Theme.of(context).primaryColorLight,
            )
          : MaterialStateColor.resolveWith(
              (states) => Theme.of(context).scaffoldBackgroundColor,
            ),
    ),
    onPressed: action,
    child: Text(
      title,
      style: const TextStyle(color: Colors.white),
    ),
  );
}
