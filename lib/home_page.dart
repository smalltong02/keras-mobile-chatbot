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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<SettingProvider>(
      builder: (context, settingProvider, _) {
        String wallpaperPath = settingProvider.homepageWallpaperPath;
        return Scaffold(
          body: SafeArea(
            child: Container(
              width: screenWidth,
              height: screenHeight,
              decoration: wallpaperPath.isNotEmpty
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(wallpaperPath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : null,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          'assets/log-imgs/logo-phone.png',
                          width: screenWidth * 0.5,
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'AI Home Assistant',
                          style: TextStyle(fontSize: 36),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
                  const Spacer(),
                  if (googleLoginUser != null) ...{
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: OverflowBar(
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
                              type: GFButtonType.transparent,
                              fullWidthButton: false,
                              size: GFSize.LARGE,
                              color: GFColors.TRANSPARENT,
                              textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              shape: GFButtonShape.pills,
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}