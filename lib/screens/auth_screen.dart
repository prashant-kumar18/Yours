import 'dart:io';

import 'package:ChatApp/services/auth.dart';
import 'package:ChatApp/widgets/widgets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Auth extends StatefulWidget {
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  bool islogin = true;
  bool isloading = false;
  File image;
  var scafoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    islogin = true;
    isloading = false;
  }

  void localvalidate(ctx) async {
    try {
      if (image == null && islogin == false) {
        scafoldkey.currentState.showSnackBar(SnackBar(
          content: Text(" Add an Image"),
          backgroundColor: Colors.pink,
        ));
        return;
      }
      if (formkey.currentState.validate()) {
        if (islogin) {
          setState(() {
            isloading = true;
          });

          await AuthFunctions().signin(email.text.trim(), password.text.trim());
          setState(() {
            isloading = false;
          });
        } else {
          setState(() {
            isloading = true;
          });
          await AuthFunctions().signup(email.text.trim(), password.text.trim(),
              username.text.trim(), image);
          setState(() {
            isloading = false;
          });
        }
        // FirebaseAuth.instance.authStateChanges();

      }
    } catch (e) {}
  }

  void pickimage(option) async {
    final picker = ImagePicker();
    var pickedfile;
    if (option == "camera") {
      pickedfile = await picker.getImage(
          source: ImageSource.camera, imageQuality: 50, maxWidth: 300);
    }
    if (option == "gallery") {
      pickedfile = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 50, maxWidth: 300);
    }

    if (!(pickedfile == null)) {
      setState(() {
        image = File(pickedfile.path);
      });
      image = File(pickedfile.path);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafoldkey,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.deepPurple,
          child: Column(
            children: [
              Container(
                color: Colors.deepPurple,
                height: MediaQuery.of(context).size.height * 0.3,
                child: SizedBox(
                  width: 250.0,
                  child: Center(
                    child: TyperAnimatedTextKit(
                      text: [
                        "Your's",
                      ],
                      textStyle: TextStyle(
                          shadows: [
                            Shadow(color: Colors.grey, blurRadius: 0.5)
                          ],
                          fontSize: 80.0,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Italianno",
                          color: Colors.white70),
                      textAlign: TextAlign.start,
                      speed: Duration(seconds: 1),
                      isRepeatingAnimation: false,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(120),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Form(
                          key: formkey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40,
                              ),
                              if (!islogin)
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (ctx) => Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  40),
                                                          topRight:
                                                              Radius.circular(
                                                                  40))),
                                              height: 120,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      icon: Icon(Icons.camera,
                                                          color: Colors.pink,
                                                          size: 40),
                                                      onPressed: () {
                                                        pickimage("camera");
                                                      }),
                                                  SizedBox(
                                                    width: 100,
                                                  ),
                                                  IconButton(
                                                      color: Colors.pink,
                                                      icon: Icon(
                                                        Icons.photo_album,
                                                        color: Colors.pink,
                                                        size: 40,
                                                      ),
                                                      onPressed: () {
                                                        pickimage("gallery");
                                                      })
                                                ],
                                              ),
                                            ));
                                  },
                                  child: CircleAvatar(
                                    backgroundImage:
                                        image == null ? null : FileImage(image),
                                    child: image == null
                                        ? Icon(Icons.person)
                                        : null,
                                    radius: 50,
                                  ),
                                ),
                              islogin
                                  ? Container()
                                  : TextFormField(
                                      controller: username,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return "Please enter UserName";
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                          labelText: "UserName",
                                          labelStyle: TextStyle(
                                              color: Colors.purple[200]),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey))),
                                    ),
                              TextFormField(
                                controller: email,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please enter Email";
                                  }
                                  if (!value.contains("@gmail.com")) {
                                    return "Please enter password";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    labelText: "Email",
                                    labelStyle:
                                        TextStyle(color: Colors.purple[200]),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please enter password";
                                  }
                                  if (value.length <= 6) {
                                    return "Please enter password";
                                  }
                                  return null;
                                },
                                controller: password,
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle:
                                        TextStyle(color: Colors.purple[200]),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    isloading
                                        ? print("")
                                        : localvalidate(context);
                                  },
                                  child: isloading
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : getbutton(
                                          (islogin ? "Sign In" : "sign Up"))),
                              SizedBox(
                                height: 9,
                              ),
                              islogin ? Text("OR") : Container(),
                              SizedBox(
                                height: 9,
                              ),
                              islogin
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.pinkAccent,
                                      ),
                                      height: 30,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          "Sign In with Google",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: islogin
                                    ? MediaQuery.of(context).size.height * 0.24
                                    : MediaQuery.of(context).size.height * 0.04,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              islogin
                                  ? "Don't have an account?"
                                  : "Already Have an account?",
                              style: TextStyle(color: Colors.pink),
                            ),
                            GestureDetector(
                              onTap: () {
                                username.clear();
                                email.clear();
                                password.clear();
                                setState(() {
                                  islogin = !islogin;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  islogin ? " Create One" : " Go back",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                      color: Colors.deepPurple),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            )
                          ],
                        )
                      ],
                    ),
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
