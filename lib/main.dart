import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/pages/home.dart';
import 'package:volunteer_scout_mobile_app/pages/timeline.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer Scout',
      //debugShowCheckedModeBanner: false,
      theme:ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.amber,
      ),
      home: Home(),
    );
  }
}
