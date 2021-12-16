import 'dart:developer';
import 'package:volunteer_scout_mobile_app/models/user.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:volunteer_scout_mobile_app/pages/create_account.dart';
import 'package:volunteer_scout_mobile_app/pages/profile.dart';
import 'package:volunteer_scout_mobile_app/pages/timeline.dart';
import 'package:volunteer_scout_mobile_app/pages/search.dart';
import 'package:volunteer_scout_mobile_app/pages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_feed.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timestamp = DateTime.now();
User? currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth=false;
  late PageController pageController;
  int pageIndex=0;
  @override
  void initState(){
    super.initState();
    pageController = PageController();
    //detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err){
      print('Error signing in: $err');
    });
    //reauthenticate user when opened
    googleSignIn.signInSilently(suppressErrors: false)
        .then((account){
            handleSignIn(account);
          }).catchError((err){
      print('Error signing in: $err');
              });

    }

  handleSignIn(GoogleSignInAccount? account){
    if (account != null){
      createUserInFirestore();
      setState(() {
        isAuth=true;
      });
    }
    else{
      setState(() {
        isAuth=false;
      });
    }
  }
  createUserInFirestore() async{
    // check if user exists in users collection in database by id
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user!.id).get();
    // if user doesn't exist, take them to create acc page
    if(!doc.exists) {
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));

      //get username from created acc, use it to make new acc document in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp":timestamp
      });
      doc = await usersRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser!.username);
  }

  @override
  dispose(){
    pageController.dispose();
    super.dispose();
  }
  login(){
    googleSignIn.signIn();
  }
  logout() async{
    await googleSignIn.signOut();
  }
  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }
  onTap(int pageIndex){
    pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
    );
  }
  Scaffold buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //Timeline(),
          ElevatedButton(
              child: Text('Log out'),
              onPressed: logout,
          ),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot),),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active),),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size:35.0,),),
          BottomNavigationBarItem(icon: Icon(Icons.search),),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle),),
        ],
      ),
    );
    // return ElevatedButton(
    //     child: Text('Log out'),
    //     onPressed: logout
    // );
  }
  buildUnauthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Volunteer Scout',
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white
              ),
            ),
            GestureDetector(
              onTap: login,
                child : Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/google_signin_button.png'),
                      fit: BoxFit.cover
                    ),
                  ),
                 ),
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnauthScreen();
  }
}
