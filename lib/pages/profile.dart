import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_scout_mobile_app/models/user.dart';
import 'package:volunteer_scout_mobile_app/pages/edit_profile.dart';
import 'package:volunteer_scout_mobile_app/pages/home.dart';
import 'package:volunteer_scout_mobile_app/widgets/header.dart';
import 'package:volunteer_scout_mobile_app/widgets/progress.dart';

class Profile extends StatefulWidget {
  //late final String profileId;
  //Profile({required this.profileId});
  final User? user;
  Profile({required this.user});


  @override
  _ProfileState createState() => _ProfileState();

}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser!.id;

  Column buildCountColumn(String label, int count){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }
  editProfile(){
    Navigator.push(context,MaterialPageRoute(builder: (context)=>
        EditProfile(user:currentUser)));
  }
  Container buildButton({required String text,  required VoidCallback function}){
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
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

    );
  }
  buildProfileButton(){
    //viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.user!.id;
    if(isProfileOwner){
      return buildButton(
        text: "Edit Profile",
        function: editProfile

      );
    }

    return Text("ProfileButton");
  }
  buildProfileHeader(){
    return FutureBuilder<DocumentSnapshot>(
      future: usersRef.doc(widget.user!.id).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
       User user = User.fromDocument(snapshot.data!);
        return Padding(
          padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 40.0,
                backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            SizedBox(height: 10.0,),
            Container(
              child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildCountColumn("ads", 0),
                  ],
                ),
                SizedBox(height: 10.0,),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildProfileButton(),
                  ],
                ),
                SizedBox(height: 10.0,),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    user.bio,

                  ),
                ),
              ],
            ),
           ),
        ///////////////
              ],

        ),

        );
      },
        );

   // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),

        ],
      ),
    );
  }
}
