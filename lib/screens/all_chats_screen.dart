import 'package:ChatApp/services/functions.dart';
import 'package:ChatApp/services/notification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'package:flutter/material.dart';

class AllChats extends StatefulWidget {
  @override
  _AllChatsState createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  var v = 0;
  var currentuser;
  Stream chatstream;
  @override
  void initState() {
    super.initState();
    Notify().firebaseMessaging.configure(onMessage: (message) {
      print("on running message--" + message.toString());
      return;
    }, onLaunch: (message) {
      print("on launch message--" + message.toString());
      return;
    }, onResume: (message) {
      print("on resume message--" + message.toString());
      return;
    });
    Notify().firebaseMessaging.getToken().then((value) => print(value));

    Future.delayed(Duration.zero, () {});
    chatstream = FunctionsOfApp().getchats();
    FunctionsOfApp().getuserinfo().then((value) {
      setState(() {
        currentuser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.pink,
          child: Column(
            children: [
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(),
                  Container(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: currentuser == null
                              ? AssetImage("assets/smily.jpg")
                              : CachedNetworkImageProvider(
                                  currentuser.profileimage),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            currentuser == null ? "" : currentuser.username,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          child: AlertDialog(
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                },
                                child: Chip(
                                  backgroundColor: Colors.pink,
                                  label: Text(
                                    "LOGOUT",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("CANCEL"))
                            ],
                            title: Text("Are you Sure?"),
                          ));
                    },
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.settings_backup_restore,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(80),
                        topRight: Radius.circular(80)),
                    color: Colors.white,
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: 25),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FunctionsOfApp().getchats(),
                        builder: (context, snapshot) {
                          var v;

                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? Container()
                              : (snapshot.data.docs.length == 0
                                  ? Container(
                                      child: Column(
                                        children: [
                                          Flexible(flex: 1, child: Container()),
                                          Flexible(
                                            flex: 3,
                                            child: FlareActor(
                                              "assets/anime1.flr",
                                              alignment: Alignment.center,
                                              animation: "music_walk",
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              "NO one to Chat to? ADD some friend... 👈",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: snapshot.data.docs.length,
                                      itemBuilder: (ctx, index) {
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          elevation: 5,
                                          child: InkWell(
                                            splashColor: Colors.pink[100],
                                            borderRadius:
                                                BorderRadius.circular(55),
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, "chatscreen",
                                                  arguments: snapshot
                                                      .data.docs[index]
                                                      .data());
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                leading: snapshot.data
                                                                .docs[index]
                                                                .data()[
                                                            "profileimageurl"] ==
                                                        null
                                                    ? CircularProgressIndicator()
                                                    : Hero(
                                                        tag: snapshot
                                                            .data.docs[index]
                                                            .data()["email"],
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          child: CircleAvatar(
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: snapshot
                                                                      .data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "profileimageurl"],
                                                              placeholder: (context,
                                                                      _) =>
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                title: Text(snapshot
                                                    .data.docs[index]
                                                    .data()["username"]
                                                    .toString()),
                                                subtitle: Text(snapshot
                                                    .data.docs[index]
                                                    .data()["email"]),
                                                trailing:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton(
                                                    value: v,
                                                    icon: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.pink,
                                                    ),
                                                    items: [
                                                      DropdownMenuItem(
                                                        value: 1,
                                                        child: Text(
                                                          "remove",
                                                        ),
                                                        onTap: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .doc(currentuser
                                                                  .email)
                                                              .collection(
                                                                  "friends")
                                                              .doc(snapshot.data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "email"])
                                                              .delete();
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .doc(snapshot.data
                                                                      .docs[index]
                                                                      .data()[
                                                                  "email"])
                                                              .collection(
                                                                  "friends")
                                                              .doc(currentuser
                                                                  .email)
                                                              .delete();
                                                        },
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      v = value;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ));
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
