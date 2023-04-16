import 'package:flutter/material.dart';

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({super.key});

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  late final TextEditingController _textController;
  bool emptyText = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 15,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) => setState(
              () => emptyText = value.isEmpty,
            ),
            autofocus: true,
            controller: _textController,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.trip_origin_outlined,
                color: emptyText ? Colors.grey : Colors.amber,
              ),
              contentPadding: EdgeInsets.zero,
              hintText: "Add Todo",
              hintStyle: TextStyle(
                color: Colors.grey[600],
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.alarm,
                    color: Colors.grey[300],
                  ),
                  label: Text(
                    "Set reminder",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                    ),
                  ),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                ),
                InkWell(
                  onTap: emptyText
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: emptyText ? Colors.grey : Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
