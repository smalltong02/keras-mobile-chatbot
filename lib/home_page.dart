import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keras_mobile_chatbot/chat.dart';
import 'package:keras_mobile_chatbot/google_sign.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleSignInAccount? googleLoginUser;

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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/log-imgs/logo-phone.png'),
                const SizedBox(height: 16.0),
                const Text(
                  'AI Home Smart Assistant',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,),
              ],
            ),
            // spacer
            const SizedBox(height: 120.0),
            // [Name]
            const SizedBox(height: 10.0),
            OverflowBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 18,
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
                          MaterialPageRoute(builder: (context) => ChatHome()),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            if (googleLoginUser != null) ...{
              const SizedBox(height: 100.0),
              TextButton(
                onPressed: handleSignOut,
                child: const Text('Sign Out Google Account'),
              ),
            }
          ],
        ),
      ),
    );
  }
}