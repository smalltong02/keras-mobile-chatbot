import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keras_mobile_chatbot/chat.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:keras_mobile_chatbot/google_sign.dart';
//import 'package:firebase_auth/firebase_auth.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleSignInAccount? googleLoginUser;
  String wallpaperPath = "";

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        googleLoginUser = account;
      });
    });
    googleSignIn.signInSilently();
  }

  Future<bool> handleSignIn() async {
    bool bSign = false;
    try {
      if (googleLoginUser != null) {
        bSign = true;
      }
      else {
        await googleSignIn.signIn();
          googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
          setState(() {
            googleLoginUser = account;
          });
        });
        if (googleLoginUser != null) {
          bSign = true;
        }
      }
      
    } catch (error) {
      print(error);
    }
    return bSign;
  }

  Future<void> handleSignOut() => googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    wallpaperPath = Provider.of<SettingProvider>(context, listen: false).homepageWallpaperPath;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: wallpaperPath.isNotEmpty
          ? BoxDecoration(
            image: DecorationImage(
              image: AssetImage(wallpaperPath),
              fit: BoxFit.cover,
            ),
          ) : null,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              const SizedBox(height: 80.0),
              Column(
                children: <Widget>[
                  Image.asset('assets/log-imgs/logo-phone.png'),
                  const SizedBox(height: 16.0),
                  const Text(
                    'AI Home Assistant',
                    style: TextStyle(fontSize: 36),
                    textAlign: TextAlign.center,),
                ],
              ),
              // spacer
              const SizedBox(height: 120.0),
              // [Name]
              OverflowBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black54,
                        backgroundColor: Colors.greenAccent.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      child: const Text('Start Chat'),
                      onPressed: () async {
                        bool bsign = await handleSignIn();
                        if (bsign) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatHome()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (googleLoginUser != null) ...{
                const SizedBox(height: 180.0),
                OverflowBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/log-imgs/google-plus.png',
                        width: 24,
                        height: 24,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: GFButton(
                        onPressed: handleSignOut,
                        text: 'Sign Out Google Account',
                        type: GFButtonType.outline2x,
                        fullWidthButton: false,
                        size: GFSize.LARGE,
                        color: GFColors.TRANSPARENT,
                        shape: GFButtonShape.pills,
                      ),
                    ),
                  ],
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}