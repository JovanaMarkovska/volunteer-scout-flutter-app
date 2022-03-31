import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/widgets/header.dart';
import 'package:volunteer_scout_mobile_app/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'home.dart';

class Comments extends StatefulWidget {
  final String adId;
  final String adOwnerId;
  final String adMediaUrl;

  Comments({required this.adId, required this.adOwnerId, required this.adMediaUrl});

  @override
  CommentsState createState() => CommentsState(
      adId: this.adId,
      adOwnerId: this.adOwnerId,
      adMediaUrl: this.adMediaUrl,
  );
}

class CommentsState extends State<Comments> {
  TextEditingController discussionController = TextEditingController();
  final String adId;
  final String adOwnerId;
  final String adMediaUrl;

  CommentsState({required this.adId, required this.adOwnerId, required this.adMediaUrl});
  buildDiscussion(){
    
    return StreamBuilder<QuerySnapshot>(
      stream: discussionRef
          .doc(adId)
          .collection("discussion")
          .orderBy("timestamp",descending: false)
          .snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<Comment> comments = [];
         snapshot.data!.docs.forEach((doc){
           comments.add(Comment.fromDocument(doc));
         });
        return ListView(children: comments,);

      },
    );
  }
  addComment(){
    discussionRef.doc(adId).collection("discussion").add({
      "username":currentUser!.username,
      "comment" : discussionController.text,
      "timestamp": timestamp,
      "avatarUrl":currentUser!.photoUrl,
      "userId":currentUser!.id,
    });
    discussionController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,titleText: "Discussion"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildDiscussion()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: discussionController,
              decoration: InputDecoration(labelText: "Get into discussion.. "),

            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text("Post"),

            ),
          ),
        ],
      ),
    ) ;
  }
}

class Comment extends StatelessWidget {
  late final String username;
  late final String userId;
  late final String avatarUrl;
  late final String comment;
  late final Timestamp timestamp;
  Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        username: doc['username'],
        userId: doc['userId'],
        avatarUrl: doc['avatarUrl'],
        comment: doc['comment'],
        timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: RichText(
              text: TextSpan(
              style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
            TextSpan(text: username+'\n', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: comment),
            ],
            ),
           ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate(),allowFromNow: true)),
        ),
        Divider(),
      ],
    );
  }
}
