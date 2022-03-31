import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/pages/comments.dart';
import 'package:volunteer_scout_mobile_app/pages/home.dart';
import 'package:volunteer_scout_mobile_app/widgets/ad.dart';
import 'package:volunteer_scout_mobile_app/widgets/header.dart';
import 'package:volunteer_scout_mobile_app/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async{
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser!.id)
        .collection('feedItems')
        .orderBy('timestamp',descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems=[];
    snapshot.docs.forEach((doc){
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItems;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Notifications"),
      body: Container(
        child: FutureBuilder (
          future: getActivityFeed(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return circularProgress();
            }
            return ListView(
                children: snapshot.data as List<Widget>);
          },

        ),
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;//'applied' 'comment'
  final String mediaUrl;
  final String adId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;
  late String activityItemText;

  ActivityFeedItem({
      required this.username,
      required this.userId,
      required this.type,
      required this.mediaUrl,
      required this.adId,
      required this.userProfileImg,
      required this.commentData,
      required this.timestamp});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc){

    return ActivityFeedItem(
        username: doc['username'],
        userId: doc['userId'],
        type: doc['type'],
        mediaUrl: doc['mediaUrl'],
        adId: doc['adId'],
        userProfileImg: doc['userProfileImg'],
        commentData: doc['commentData'],
        timestamp: doc['timestamp'],
    );
  }
  configureNotificationPreview() async {

    if(type == 'applied'){
      activityItemText = "sent an application for ad with id $adId";
    }
    else if(type == 'comment'){
      activityItemText = "replied in the discussion about ${adId} \n $commentData";
    }
  }
  showAd(context){
    //TODO IMPLEMENT ON TAP
  }
  @override
  Widget build(BuildContext context) {
    configureNotificationPreview();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
            onTap: ()=>showAd(context),
            child: RichText(
              //overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $activityItemText',

                  ),
                ]
              ),
            ),
          ),
          leading: GestureDetector(
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
              onTap: ()=>print("show profile"),

          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
