import 'package:flutter/material.dart';
import 'l10n/localization_intl.dart';
import 'package:provider/provider.dart';
import 'package:getwidget/getwidget.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isEye = true;
  final _formKey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  final usernameController =  TextEditingController();
  final passwordController = TextEditingController();
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final pwdRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d@#$%&*!_\-]{6,12}$');

  @override
  void initState() {

  }
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<SettingProvider>(
      builder: (context, settingProvider, _) {
        String wallpaperPath = settingProvider.homepageWallpaperPath;
        return Scaffold(
          appBar: AppBar(
            title: Text(DemoLocalizations.of(context).titleRegisterPage),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
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
                          Text(
                            DemoLocalizations.of(context).homeTitle,
                            style: const TextStyle(fontSize: 36),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 45.0),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.9,
                              child: TextFormField( //user name
                                controller: usernameController,
                                //focusNode: focusNode1,
                                keyboardType: TextInputType.text,
                                maxLength: 60,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    hintText: DemoLocalizations.of(context).hintTextAccount,
                                    labelText: DemoLocalizations.of(context).labelTextAccount,
                                    contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                    prefixIcon: const Icon(Icons.perm_identity),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40.0)
                                    ),
                                    suffixIcon: usernameController.text.isNotEmpty?IconButton(
                                        icon: const Icon(
                                            Icons.clear,
                                            size: 21,
                                            color: Color(0xff666666),
                                        ),
                                        onPressed: (){
                                            setState(() {
                                                usernameController.text = '';
                                            }
                                          );
                                        },
                                    ):null
                                ),
                                validator: (v) {
                                    return !emailRegex.hasMatch(v!)?DemoLocalizations.of(context).errTextAccount:null;
                                },
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              width: screenWidth * 0.9,
                              child: TextFormField( //password
                                controller: passwordController,
                                //focusNode: focusNode2,
                                obscureText: isEye,
                                maxLength: 12,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: DemoLocalizations.of(context).hintTextPassword,
                                  labelText: DemoLocalizations.of(context).labelTextPassword,
                                  contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                  prefixIcon:const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40.0)
                                  ),
                                  suffixIcon: IconButton(
                                      icon: const Icon(
                                          Icons.remove_red_eye,
                                          size: 21,
                                          color: Color(0xff666666),
                                      ),
                                      onPressed: (){
                                        setState(() {
                                            isEye = !isEye;
                                        });
                                      },
                                  )
                                ),
                                validator:(v){
                                    return !pwdRegex.hasMatch(v!)?DemoLocalizations.of(context).errTextPassword:null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          child: Text(DemoLocalizations.of(context).textCreateAccount),
                          onPressed: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if(_formKey.currentState!.validate() == false) {
                              GFToast.showToast(
                                DemoLocalizations.of(context).errSignBtn,
                                context,
                                toastPosition: GFToastPosition.BOTTOM,
                                textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                backgroundColor: GFColors.LIGHT,
                                trailing: const Icon(
                                  Icons.error,
                                  color: GFColors.DANGER,
                                )
                              );
                            }
                            else {
                              try {
                                await firebaseAuth.createUserWithEmailAndPassword(
                                  email: usernameController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                                GFToast.showToast(
                                  DemoLocalizations.of(context).sucCreateAccount,
                                  context,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                  backgroundColor: GFColors.LIGHT,
                                  trailing: const Icon(
                                    Icons.thumb_up_rounded,
                                    color: GFColors.SUCCESS,
                                  )
                                );
                                Future.delayed(const Duration(seconds: 2), () {
                                  // Pass the username and password back to the login screen
                                  Navigator.pop(context, {
                                    'username': usernameController.text.trim(),
                                    'password': passwordController.text.trim(),
                                  });
                                });
                              } on FirebaseAuthException catch (e) {
                                String message = "";
                                if (e.code == 'weak-password') {
                                  message = DemoLocalizations.of(context).errWeakCreateAccount;
                                } else if (e.code == 'email-already-in-use') {
                                  message = DemoLocalizations.of(context).errExtCreateAccount;
                                }
                                GFToast.showToast(
                                  DemoLocalizations.of(context).errToastCreateAccount + message,
                                  context,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                  backgroundColor: GFColors.LIGHT,
                                  trailing: const Icon(
                                    Icons.thumb_down_rounded,
                                    color: GFColors.WARNING,
                                  )
                                );
                              } catch (e) {
                                GFToast.showToast(
                                  DemoLocalizations.of(context).errToastCreateAccount + e.toString(),
                                  context,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                  backgroundColor: GFColors.LIGHT,
                                  trailing: const Icon(
                                    Icons.thumb_down_rounded,
                                    color: GFColors.WARNING,
                                  )
                                );
                              }
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}