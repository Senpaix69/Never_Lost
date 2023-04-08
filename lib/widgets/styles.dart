import 'package:flutter/material.dart';

InputDecoration decorationFormField(prefixIcon, hintText) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(15.0),
    prefixIcon: Icon(prefixIcon, color: Colors.grey),
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.grey[400],
    ),
    filled: true,
    fillColor: Colors.cyan.withAlpha(40),
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
  Color? color,
  double size = 16.0,
}) {
  return Text(
    text,
    style: TextStyle(
      color: color ?? Colors.grey[300],
      fontSize: size,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    ),
  );
}

Container headerContainer({
  required String title,
  required IconData icon,
  required VoidCallback? onClick,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    width: double.infinity,
    height: 45,
    decoration: BoxDecoration(
      color: Colors.cyan[900],
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          myText(text: title),
          const SizedBox(
            width: 10.0,
          ),
          IconButton(
            padding: EdgeInsets.zero,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            alignment: Alignment.centerRight,
            onPressed: onClick,
            icon: Icon(icon),
            iconSize: 25,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}
