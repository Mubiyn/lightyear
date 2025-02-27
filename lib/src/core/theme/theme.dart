import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme:
      AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme:
      AppBarTheme(backgroundColor: Colors.green, foregroundColor: Colors.white),
);
