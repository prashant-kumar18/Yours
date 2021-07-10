import 'package:ChatApp/screens/all_chats_screen.dart';
import 'package:ChatApp/screens/search_screen.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  PageController pageController = PageController(initialPage: 1);
  int index = 1;
  List<Widget> pages = [SearchScreen(), AllChats()];
  @override
  void initState() {
    super.initState();
    pages = [SearchScreen(), AllChats()];

    index = 1;
  }

  void onchanged(int i) {
    setState(() {
      index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          onchanged(v);
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            index = value;
          });
          pageController.jumpToPage(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text("Chats"),
          ),
          //   BottomNavigationBarItem(
          //     icon: Icon(Icons.search),
          //     title: Text("Settings"),
          //   ),
        ],
      ),
    );
  }
}
