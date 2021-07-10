import 'package:ChatApp/modal/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FunctionsOfApp {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  List searchlist = [];
  List chatlist = [];
  var b = "";
  Future<List> search(username) async {
    try {
      var users = await firebaseFirestore
          .collection("users")
          .where(
            "username",
            isEqualTo: username,
          )
          .get();
      if (users.docs.isNotEmpty) {
        users.docs.forEach((element) {
          if (!(element.data()["email"] == firebaseAuth.currentUser.email)) {
            searchlist.add(element.data());
          }
        });

        print("tooooooo" + users.docs[0].data()["tokens"].toString());
      }
    } catch (e) {
      print("searching---" + e);
    }
    return searchlist;
  }

  Future<CurrentUser> getuserinfo() async {
    CurrentUser currentuser;
    try {
      final userinfo = await firebaseFirestore
          .collection("users")
          .doc(firebaseAuth.currentUser.email)
          .get();
      // print("yaha---" + user.user.email);

      userinfo.data().isNotEmpty
          ? currentuser = CurrentUser(
              email: firebaseAuth.currentUser.email,
              uid: firebaseAuth.currentUser.uid,
              username: userinfo.data()["username"],
              profileimage: userinfo.data()["profileimageurl"])
          : print("userinfo is empty");
      print("here----" + currentuser.email);
    } catch (e) {}

    return currentuser;
  }

  Future addtochat(
      email1, email2, username1, username2, image1, image2, token2) async {
    try {
      var token1 = await firebaseMessaging.getToken();
      print("currentusertoken---" + token1);
      print("currentusertoken---" + token2);
      await firebaseFirestore
          .collection("users")
          .doc(email1)
          .collection("friends")
          .doc(email2)
          .set({
        "username": username2,
        "email": email2,
        "createdAt": Timestamp.now(),
        "chatid": email1 + email2,
        "profileimageurl": image2,
        "token": token2
      });
      await firebaseFirestore
          .collection("users")
          .doc(email2)
          .collection("friends")
          .doc(email1)
          .set({
        "username": username1,
        "email": email1,
        "createdAt": Timestamp.now(),
        "chatid": email1 + email2,
        "profileimageurl": image1,
        "token": token1
      });
    } catch (e) {}
  }

  getchats() {
    try {
      return firebaseFirestore
          .collection("users")
          .doc(firebaseAuth.currentUser.email)
          .collection("friends")
          .snapshots();
    } catch (e) {
      print(e);
    }
  }

  addmessage(message, email2, type) async {
    try {
      var currentuser = firebaseAuth.currentUser;
      var chatiddata = await firebaseFirestore
          .collection("users")
          .doc(firebaseAuth.currentUser.email)
          .collection("friends")
          .doc(email2)
          .get();

      var atdoc = firebaseFirestore
          .collection("chat")
          .doc(chatiddata.data()["chatid"])
          .collection("messages")
          .doc();
      var user = await getuserinfo();

      await atdoc.set({
        "aotherdevicetoken": chatiddata.data()["token"],
        "senderusername": user.username,
        "message": message,
        "sendby": currentuser.email,
        "createdAt": Timestamp.now(),
        "docid": atdoc.id,
        "type": type
      });
    } catch (e) {}
  }

  getchatid(String email2) async {
    var currentuser = firebaseAuth.currentUser;
    var chatiddata = await firebaseFirestore
        .collection("users")
        .doc(currentuser.email)
        .collection("friends")
        .doc(email2)
        .get();

    return chatiddata.data()["chatid"];
  }

  getmessages(chatid) {
    try {
      return firebaseFirestore
          .collection("chat")
          .doc(chatid)
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .snapshots();
    } catch (e) {
      print("getmessages error---" + e);
    }
  }
}
