import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/models/user.dart';
import 'package:volunteer_scout_mobile_app/pages/home.dart';
import 'package:volunteer_scout_mobile_app/widgets/ad.dart';
import 'package:volunteer_scout_mobile_app/widgets/progress.dart';

class ViewAd extends StatefulWidget {
  late final String adId;
  late final String ownerId;
  late final String username;
  late final String location;
  late final String description;
  late final String category;
  late final String startDate;
  late final String endDate;
  late final String mediaUrl;
  late final String title;
  late final List<User> volunteers;

  ViewAd({
    required this.adId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.mediaUrl,
    required this.title,
    required this.volunteers});

  factory ViewAd.fromDocument(DocumentSnapshot doc){
    return ViewAd(
      adId: doc['adId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      category: doc['category'],
      startDate: doc['startDate'],
      endDate: doc['endDate'],
      mediaUrl: doc['mediaUrl'],
      title: doc['title'],
      volunteers: doc['volunteers'].cast<User>(),
    );
  }
  @override
  _ViewAdState createState() =>
      _ViewAdState(
        adId: this.adId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        category: this.category,
        startDate: this.startDate,
        endDate: this.endDate,
        mediaUrl: this.mediaUrl,
        title: this.title,
        volunteers: this.volunteers,

      );
}
class _ViewAdState extends State<ViewAd> {
  late final String adId;
  late final String ownerId;
  late final String username;
  late final String location;
  late final String description;
  late final String category;
  late final String startDate;
  late final String endDate;
  late final String mediaUrl;
  late final String title;
  late final List<User> volunteers;

  _ViewAdState({
  required this.adId,
  required this.ownerId,
  required this.username,
  required this.location,
  required this.description,
  required this.category,
  required this.startDate,
  required this.endDate,
  required this.mediaUrl,
  required this.title,
  required this.volunteers});

  buildAdHeader(){
    return FutureBuilder<DocumentSnapshot>(
      future: usersRef.doc(ownerId).get(),
      builder:(context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data!);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print("Showing profile"),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
  applyToVolunteer(){
    //TODO implement the button to apply

  }
  buildAdBody(){
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      margin: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              constraints: BoxConstraints.tightFor(height: 250.0),
              child: Image.network(
                mediaUrl,
                fit: BoxFit.fitWidth,
              )),
          Container(
            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20.0,),
          Container(
            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
            alignment: Alignment.center,

            child: Text(
              "From ${startDate} to ${endDate}" ,
              style: TextStyle(fontSize: 14.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
            child: Text(
              location,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20.0,),
          Container(
            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
            child: Text(
              description,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          SizedBox(height: 30.0,),
          Container(
            padding: EdgeInsets.only(top: 2.0),
            child: FlatButton(
                onPressed: applyToVolunteer,
                child: Container(
                  width: 200.0,
                  height: 60.0,
                  child: Text(
                    "Apply",
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                )
            ),

          ),


        ],
      ),
    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white
        ),
        title: Text(title),
        centerTitle: true,
      ),      body: ListView(
        children: <Widget>[
          buildAdHeader(),
          Divider(
            height: 0.0,
          ),
          buildAdBody(),

        ],
      ),
    );

  }
}
