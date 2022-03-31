import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/models/user.dart';
import 'package:volunteer_scout_mobile_app/pages/comments.dart';
import 'package:volunteer_scout_mobile_app/pages/home.dart';
import 'package:volunteer_scout_mobile_app/pages/view_ad.dart';
import 'package:volunteer_scout_mobile_app/widgets/progress.dart';

class Ad extends StatefulWidget {
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
  late final dynamic volunteers;

  Ad({
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

     factory Ad.fromDocument(DocumentSnapshot doc){
    return Ad(
      adId: doc['adId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      category:doc['category'] ,
      startDate: doc['startDate'],
      endDate:doc['endDate'] ,
      mediaUrl: doc['mediaUrl'],
      title:doc['title'] ,
      volunteers: doc['volunteers'],
    );
  }


  @override
  _AdState createState() => _AdState(
      adId: this.adId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      description: this.description,
      category:this.category,
      startDate:this.startDate,
      endDate:this.endDate,
      mediaUrl:this.mediaUrl,
      title:this.title,
      volunteers: this.volunteers,

  );
}

class _AdState extends State<Ad> {
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
  late final dynamic volunteers;
  _AdState({
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
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: ()=>print('deleting post'),
            icon: Icon(Icons.more_vert),
          ),

        );
      },
    );
  }

  buildAdBody(){
    return Container(
      //padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 5.0),
      margin: EdgeInsets.only(left: 10.0, right:10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.black,
              image: new DecorationImage(
                fit: BoxFit.fitWidth,
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
                image: new NetworkImage(
                  mediaUrl,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                            //alignment: Alignment.topLeft,
                            child: Text(
                              title,
                              style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 30.0),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                            alignment: Alignment.topLeft,

                            child: Text(
                              "From ${startDate} to ${endDate}," ,
                              style: TextStyle(fontSize: 14.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Happening in ${location}" ,
                              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 2.0),
                            child: FlatButton(
                                onPressed: viewAd,
                                child: Container(
                                  width: 100.0,
                                  height: 27.0,
                                  child: Text(
                                    "View Ad",
                                    style: TextStyle(
                                        color: Colors.white70,
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

                        ]


                    ),
                  ],
                ),

              ],
            ),
          ),

        ],
      ),
    );

  }

  viewAd(){
    Navigator.push(context,MaterialPageRoute(builder: (context)=>
        ViewAd(adId:adId,title:title,
          description:description,
          category:category,
          startDate:startDate,
          endDate:endDate,
          volunteers:volunteers,
          mediaUrl:mediaUrl,
          ownerId:ownerId,
          username: username,
          location: location,

        )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        //buildAdHeader(),
        Divider(
          height: 15.0,
        ),
        buildAdBody(),
      ],
    );
  }
}
