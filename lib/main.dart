import 'package:ChatApp/screens/auth_screen.dart';
import 'package:ChatApp/screens/navigation_scren.dart';
import 'package:ChatApp/screens/particular_chat_screen.dart';
import 'package:ChatApp/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthFunctions(),
      child: MaterialApp(
        theme: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(
                0), //transparent background of showmodalbottomsheet
          ),
        ),
        routes: {"chatscreen": (ctx) => ChatScreen()},
        title: "Your's ",
        home: StreamBuilder(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (ctx, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? CircularProgressIndicator()
                : snapshot.hasData ? NavigationScreen() : Auth();
          },
        ),
      ),
    );
  }
}
