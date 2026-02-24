import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTheme {

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "Poppins",
    cardTheme: const CardThemeData(
      color: Colors.tealAccent,
      shadowColor: Colors.black,
      elevation: 12,
      margin: EdgeInsets.all(8.0),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.amber
      )
    )
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blueGrey
  );

}