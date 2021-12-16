import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/pages/home.dart';
import 'package:volunteer_scout_mobile_app/pages/timeline.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
