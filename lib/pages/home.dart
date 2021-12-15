import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:volunteer_scout_mobile_app/pages/profile.dart';
import 'package:volunteer_scout_mobile_app/pages/timeline.dart';
import 'package:volunteer_scout_mobile_app/pages/search.dart';
import 'package:volunteer_scout_mobile_app/pages/upload.dart';

import 'activity_feed.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

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
      print('User signed in!: $account');
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
          Timeline(),
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
