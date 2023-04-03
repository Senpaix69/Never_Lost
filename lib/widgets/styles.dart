import 'package:flutter/material.dart';

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
