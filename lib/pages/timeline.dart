import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/models/user.dart';
import 'package:volunteer_scout_mobile_app/widgets/ad.dart';
import 'package:volunteer_scout_mobile_app/widgets/header.dart';
import 'package:volunteer_scout_mobile_app/widgets/progress.dart';

import 'home.dart';

class Timeline extends StatefulWidget {
  final User? currentUser;

  Timeline({required this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  late List<Ad> ads =[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTimeline();
  }

  getTimeline()async{
    QuerySnapshot snapshot = await timelineRef.doc(widget.currentUser!.id)
        .collection('timelineAds')
        .orderBy('timestamp', descending: false)
        .get();

    List<Ad> ads =  snapshot.docs.map((doc)=> Ad.fromDocument(doc)).toList();
    setState(() {
      this.ads=ads;
    });


  }
  buildTimeline(){
    if(ads == null){
      return circularProgress();
    }
    else if(ads.isEmpty){
      return Text("No posts");
    }
    return ListView(children: ads);
  }
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ) ,
    );
  }
}
