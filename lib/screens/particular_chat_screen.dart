import 'dart:async';
import 'dart:io';

import 'package:ChatApp/services/functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Map anotheruser = {};
  File image;
  var currentuser = FirebaseAuth.instance.currentUser;

  String chatid = "";
  TextEditingController messagetext = TextEditingController();
  @override
  void initState() {
    super.initState();
    currentuser = FirebaseAuth.instance.currentUser;
    Future.delayed(Duration.zero, () {
      anotheruser = ModalRoute.of(context).settings.arguments
          as Map; //important:it let the init to build and wait for some time to get the context

      getchatid(anotheruser["email"]);
    });
  }

  getchatid(email) async {
    var chatiddata = await FunctionsOfApp().getchatid(email);
    setState(() {
      chatid = chatiddata;
    });
  }

  void pickimage() async {
    final picker = ImagePicker();
    var pickedfile;

    pickedfile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 40, maxWidth: 200);

    if (!(pickedfile == null)) {
      setState(() {
        image = File(pickedfile.path);
      });
      image = File(pickedfile.path);
      var ref = FirebaseStorage.instance
          .ref()
          .child("messageimages")
          .child(Timestamp.now().toString() + ".jpg");
      await ref.putFile(image).onComplete;
      var url = await ref.getDownloadURL();
      FunctionsOfApp().addmessage(url, anotheruser["email"], "image");
      messagetext.clear();
    } else {
      return;
    }
  }

  var scafoldkey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var anotheruserimage = ModalRoute.of(context).settings.arguments as Map;
    return Scaffold(
      key: scafoldkey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                anotheruserimage["email"] == null
                    ? CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 50,
                      )
                    : Hero(
                        tag: anotheruserimage["email"],
                        child: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              anotheruserimage["profileimageurl"]),
                          radius: 50,
                        ),
                      ),
                SizedBox(
                  height: 9,
                ),
                Text(anotheruserimage["username"]),
              ],
            ),
          ),
          Flexible(
            child: Container(
              child: chatid == ""
                  ? CircularProgressIndicator()
                  : StreamBuilder(
                      stream: FunctionsOfApp().getmessages(chatid),
                      builder: (ctx, snapshot) {
                        return snapshot.connectionState ==
                                ConnectionState.waiting
                            ? Container()
                            : ListView.builder(
                                reverse: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (ctx, i) {
                                  return Container(
                                    alignment: snapshot.data.docs[i]
                                                .data()["sendby"] ==
                                            currentuser.email
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    margin: EdgeInsets.all(7),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        scafoldkey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text("Delete ? "),
                                            action: SnackBarAction(
                                                textColor: Colors.pink,
                                                label: "Yes",
                                                onPressed: () {
                                                  var a = snapshot.data.docs[i]
                                                      .data()["docid"];
                                                  FirebaseFirestore.instance
                                                      .collection("chat")
                                                      .doc(chatid)
                                                      .collection("messages")
                                                      .doc(a)
                                                      .delete();
                                                }),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 6),
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7),
                                        decoration: BoxDecoration(
                                            boxShadow: snapshot.data.docs[i].data()["type"] ==
                                                    "image"
                                                ? [
                                                    BoxShadow(
                                                        color: Colors.grey[400],
                                                        spreadRadius: 2,
                                                        offset: Offset(0, 9),
                                                        blurRadius: 9)
                                                  ]
                                                : null,
                                            color: snapshot.data.docs[i].data()["sendby"] ==
                                                    currentuser.email
                                                ? snapshot.data.docs[i].data()["type"] == "image"
                                                    ? Colors.white
                                                    : Colors.pink
                                                : Colors.blue[300],
                                            borderRadius: snapshot.data.docs[i]
                                                        .data()["sendby"] ==
                                                    currentuser.email
                                                ? BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                    bottomLeft:
                                                        Radius.circular(20))
                                                : BorderRadius.only(
                                                    topLeft: Radius.circular(20),
                                                    topRight: Radius.circular(20),
                                                    bottomRight: Radius.circular(20))),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: snapshot.data.docs[i]
                                                        .data()["type"] ==
                                                    "image"
                                                ? 8
                                                : 14,
                                            vertical: 9),
                                        child: snapshot.data.docs[i]
                                                    .data()["type"] ==
                                                "image"
                                            ? FullScreenWidget(
                                                child: Hero(
                                                tag: "smallImage",
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: CachedNetworkImage(
                                                        fit: BoxFit.contain,
                                                        imageUrl: snapshot
                                                                .data.docs[i]
                                                                .data()[
                                                            "message"])),
                                              ))
                                            : Text(
                                                snapshot.data.docs[i]
                                                    .data()["message"],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                });
                      }),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 40,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]),
                borderRadius: BorderRadius.circular(50)),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    pickimage();
                  },
                  child: Icon(
                    Icons.photo_album,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    onSubmitted: (_) {
                      FunctionsOfApp().addmessage(
                          messagetext.text, anotheruser["email"], "message");
                      messagetext.clear();
                    },
                    controller: messagetext,
                    cursorColor: Colors.pink,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: " Type here...."),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    FunctionsOfApp().addmessage(
                        messagetext.text, anotheruser["email"], "text");
                    messagetext.clear();
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.pink,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
