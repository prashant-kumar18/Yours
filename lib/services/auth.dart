import 'package:ChatApp/modal/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class AuthFunctions with ChangeNotifier {
  FirebaseAuth firebaseauth = FirebaseAuth.instance;
  CurrentUser currentuser;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  Future signin(email, password) async {
    try {
      await firebaseauth.signInWithEmailAndPassword(
          email: email, password: password);
      var token = await firebaseMessaging.getToken();
      await firebaseFirestore.collection("users").doc(email).update(
        {"token": token},
      );
      notifyListeners();
    } catch (e) {
      print("auth error---" + e.toString());
    }
  }

  Future signup(email, password, username, image) async {
    try {
      var token = await firebaseMessaging.getToken();
      final user = await firebaseauth.createUserWithEmailAndPassword(
          email: email, password: password);
      var ref = FirebaseStorage.instance
          .ref()
          .child("userprofileimage")
          .child(email + ".jpg");
      await ref.putFile(image).onComplete;
      var url = await ref.getDownloadURL();
      await firebaseFirestore.collection("users").doc(email).set(
        {
          "email": email,
          "username": username,
          "profileimageurl": url,
          "token": token
        },
      );

      print(user.user);
    } catch (e) {
      print("auth error---" + e.toString());
    }
  }
}
