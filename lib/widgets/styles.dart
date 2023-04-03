import 'package:flutter/material.dart';
import 'package:my_timetable/services/daytime.dart';

InputDecoration decorationFormField(prefixIcon, hintText) {
  return InputDecoration(
    prefixIcon: Icon(prefixIcon, color: Colors.grey),
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.grey[400],
    ),
    filled: true,
    fillColor: Colors.grey[800],
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
      borderSide: BorderSide.none,
    ),
  );
}

Text myText({
  required String text,
  Color color = Colors.amber,
  double size = 18.0,
}) {
  return Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    ),
  );
}

Container headerContainer({required String title, required IconData icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          myText(text: title),
          const SizedBox(
            width: 10.0,
          ),
          Icon(
            icon,
            color: Colors.amber,
          ),
        ],
      ),
    ),
  );
}
