import 'package:ChatApp/services/functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image/full_screen_image.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController search = TextEditingController();
  var scafoldkey = GlobalKey<ScaffoldState>();
  List searchlist = [];
  bool isloading = false;
  bool isloadingbutton = false;
  @override
  void initState() {
    super.initState();
    isloading = false;
  }

  void searchfunction() async {
    setState(() {
      isloading = true;
    });

    List searchdata = await FunctionsOfApp().search(search.text);
    setState(() {
      isloading = false;
      searchlist = searchdata;
    });
    print("-----" + searchlist.toString());
  }

  addtochat(String email2, String username2, String image2, token2) async {
    print("token2-----++++" + token2.toString());
    setState(() {
      isloadingbutton = true;
    });
    var currentuser = await FunctionsOfApp().getuserinfo();
    Fluttertoast.showToast(
        msg: " ✅ Friend Added",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.pink,
        textColor: Colors.white,
        fontSize: 16.0);
    await FunctionsOfApp().addtochat(
        currentuser.email,
        email2,
        currentuser.username,
        username2,
        currentuser.profileimage,
        image2,
        token2);

    setState(() {
      isloadingbutton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafoldkey,
      body: SafeArea(
        child: Container(
          color: Colors.pink,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey)),
                padding: EdgeInsets.symmetric(horizontal: 5),
                margin: EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          onSubmitted: (value) => searchfunction(),
                          controller: search,
                          decoration: InputDecoration(
                              hintText: "   Search...",
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none),
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          searchfunction();
                          isloading = true;
                          FocusScope.of(context).unfocus();
                        },
                        child: isloading
                            ? Container(
                                width: 26,
                                height: 26,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.pink,
                                  ),
                                ),
                              )
                            : Icon(Icons.search)),
                    // GestureDetector(
                    //     onTap: () {
                    //       FirebaseAuth.instance.signOut();
                    //       isloading = true;
                    //       FocusScope.of(context).unfocus();
                    //     },
                    //     child: Icon(Icons.backup)),
                  ],
                ),
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
                    child: searchlist.isEmpty
                        ? Column(children: [
                            Flexible(
                              child: Container(),
                              flex: 1,
                            ),
                            Flexible(
                              flex: 2,
                              child: Center(
                                child: Image.asset(
                                  "assets/hi.gif",
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.fitWidth,
                                  repeat: ImageRepeat.noRepeat,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Flexible(
                                child: Text(
                              "Hi, please Search Above...👆",
                              style: TextStyle(color: Colors.grey),
                            ))
                          ])
                        : StreamBuilder(
                            stream: FunctionsOfApp().getchats(),
                            builder: (ctx, snapchot) => snapchot
                                        .connectionState ==
                                    ConnectionState.waiting
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView.builder(
                                    itemCount: searchlist.length,
                                    itemBuilder: (ctx, index) {
                                      return snapchot.data.docs
                                              .where((item) =>
                                                  item.data()["email"] ==
                                                  searchlist[index]["email"])
                                              .isNotEmpty
                                          ? Container()
                                          : ListTile(
                                              leading: CircleAvatar(
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: FullScreenWidget(
                                                      child: Hero(
                                                        tag: "customTag",
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.contain,
                                                            imageUrl: searchlist[
                                                                    index][
                                                                "profileimageurl"],
                                                            placeholder: (context,
                                                                    _) =>
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              title: Text(searchlist[index]
                                                  ["username"]),
                                              subtitle: Text(
                                                  searchlist[index]["email"]),
                                              trailing: InkWell(
                                                onTap: () {
                                                  addtochat(
                                                      searchlist[index]
                                                          ["email"],
                                                      searchlist[index]
                                                          ["username"],
                                                      searchlist[index]
                                                          ["profileimageurl"],
                                                      searchlist[index]
                                                          ["token"]);
                                                },
                                                splashColor: Colors.white,
                                                child: isloadingbutton
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 20),
                                                        width: 30,
                                                        height: 30,
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.green,
                                                        ))
                                                    : Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 15,
                                                                vertical: 7),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          color: Colors.pink,
                                                        ),
                                                        child: Text(
                                                          "ADD",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            );
                                    }),
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
