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

typedef CallbackAction<T> = void Function(T);
Container headerContainer({
  required String title,
  required IconData icon,
  required CallbackAction<String>? onClick,
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
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: myText(text: title),
        ),
        const SizedBox(
          width: 10.0,
        ),
        onClick != null
            ? PopupMenuButton(
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                    const PopupMenuItem(
                      value: 'reminder',
                      child: Text('Set Reminder'),
                    ),
                  ];
                },
                onSelected: (value) => onClick(value),
                color: Colors.cyan[900],
                shadowColor: Colors.black,
                icon: Icon(
                  Icons.menu_open_rounded,
                  color: Colors.grey[200],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.grey[300],
                ),
              ),
      ],
    ),
  );
}
