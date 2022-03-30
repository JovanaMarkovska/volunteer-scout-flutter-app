import 'dart:io';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:volunteer_scout_mobile_app/models/user.dart';
import 'package:volunteer_scout_mobile_app/pages/edit_profile.dart';
import 'package:volunteer_scout_mobile_app/pages/home.dart';
import 'package:volunteer_scout_mobile_app/widgets/progress.dart';

class Upload extends StatefulWidget {
  final User? currentUser;

  Upload({required this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? file;

  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isUploading=false;
  String adId = Uuid().v4();
  DateTime selectedDate = DateTime.now();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  late String startDate=' ';
  late String endDate=' ';

  // Initial Selected Category Value
  String category = ' ';
  // List of items in our dropdown menu
  var categories = [
    'SOCIAL EVENTS',
    'FUNDRAISING',
    'CAMPAIGNING',
    'CHILDREN / FAMILIES',
    'FAITH AND ETHICS' ,
    'HEALTH AND WELL BEING',
    'RESEARCH',
    'CAREHOUSING AND HOMELESSNESS',
    'HUMAN RIGHTS',
    'INTERNATIONAL DEVELOPMENT',
    'MENTAL HEALTH',
    'OLDER PEOPLE / LATER LIFE',
    'POVERTY RELIEF',
    'REFUGEES / MIGRANTS',
  ];
  handleChooseFromGallery() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = File(file!.path);
    });
  }
  continueWithoutPhoto() async {
    Navigator.pop(context);
    setState(() {
      this.file = null;
    });

  }
  handleTakePhoto() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );

    setState(() {
      this.file = File(file!.path);
    });
  }

  selectImageForBackground(pcontext) {
    return showDialog(
        context: pcontext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: () => handleTakePhoto(),
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: () => handleChooseFromGallery(),
              ),
              SimpleDialogOption(
                  child: Text("Continue without photo"),
                onPressed: () => buildUploadForm(),
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: Text(
                "Create volunteering ad",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImageForBackground(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }
  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedDate = selected;
      });
  }
  _selectStartDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedStartDate = selected;
        startDate = DateFormat("dd-MM-yyyy").format(selectedStartDate);
      });
  }
  _selectEndDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedEndDate = selected;
        endDate=DateFormat("dd-MM-yyyy").format(selectedEndDate);
      });
  }
  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    final compressedImageFile = File('$path/img_$adId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile!,quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask = storageRef.child("post_$adId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap =  await uploadTask;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;

  }
  createAdInFirestore({required String title,required String description,
    required String startDate,required String endDate, required String category,
    required String location,required String mediaUrl}){
    adsRef.doc(widget.currentUser!.id)
        .collection("userAds")
        .doc(adId)
        .set({
          "adId": adId,
          "ownerId": widget.currentUser!.id,
          "username":widget.currentUser!.username,
          "mediaUrl":mediaUrl,
          "title":title,
          "description": description,
          "category": category,
          "location": location,
          "startDate":startDate,
          "endDate":endDate,
          "timestamp": timestamp,

        });

  }
  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createAdInFirestore(
      title: titleController.text,
      description: descriptionController.text,
      startDate: startDate,
      endDate: endDate,
      location: locationController.text,
      category: category,
      mediaUrl: mediaUrl,
    );
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      adId = Uuid().v4();
    });

  }
  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = formattedAddress;
  }
  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "Creating an ad",
          style: TextStyle(color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        actions: [
          FlatButton(
            child: Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
            onPressed: isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress(): Text(''),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width*0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: file == null ? AssetImage('assets/images/upload.svg') as ImageProvider : FileImage(file!),
                      )
                    ),
                  ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser!.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Title of event",
                  border:InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.drive_file_rename_outline_sharp, color:Colors.grey, size: 30.0,),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Write a description...",
                  border:InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          Row(

            children:  <Widget>[
              IconButton(
                  icon: const Icon(Icons.calendar_today_sharp, color:Colors.grey, size: 30.0,),
                  alignment: FractionalOffset.centerRight,
                  tooltip: 'Choose start date',
                  onPressed: () {
                    setState(() {
                      _selectStartDate(context);
                    });
                  },
                ),

              Text('Start date : $startDate',
                style: TextStyle(
                fontSize: 17,
              ),),



            ],
          ),
          Divider(),
          Row(
            children:  <Widget>[
              IconButton(
                icon: const Icon(Icons.calendar_today_sharp, color:Colors.grey, size: 30.0,),
                alignment: FractionalOffset.centerRight,
                tooltip: 'Choose end date',
                onPressed: () {
                  setState(() {
                    _selectEndDate(context);
                  });
                },
              ),

              Text('End date : $endDate' ,
                style: TextStyle(
                  fontSize: 17,
                ),),



            ],
          ),
          Divider(),
          DropdownButton<String>(
            hint: Text('Choose a category'),
            alignment: FractionalOffset.bottomLeft,
            value: null,
            items: categories.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                category = newValue!;
              });
            },

          ),
          Text('Category: '+category.toString()),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color:Colors.grey, size: 35.0,),
            title: Container(
              alignment: FractionalOffset.centerRight,
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "City, State",
                  border:InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white70,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.blue,
                label: Text("Use my location",
                    style: TextStyle(color:Colors.white))),
          ),




          
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }

}
