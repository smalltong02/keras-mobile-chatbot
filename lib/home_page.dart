import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter/gestures.dart';
import 'package:keras_mobile_chatbot/chat.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:keras_mobile_chatbot/register_screen.dart';
import 'package:keras_mobile_chatbot/policy_dialog.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'l10n/localization_intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isEye = true;
  String userName = "";
  String password = "";
  String wallpaperPath = "";
  KerasAuthProvider? authProvider;
  final _formKey = GlobalKey<FormState>();
  final usernameController =  TextEditingController();
  final passwordController = TextEditingController();
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final pwdRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d@#$%&*!_\-]{6,12}$');

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    authProvider = Provider.of<KerasAuthProvider>(context);
    if(authProvider!.getLoginStatus() == LoginStatus.logout) {
      authProvider!.googleSignInSilently();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<SettingProvider>(
      builder: (context, settingProvider, _) {
        String wallpaperPath = settingProvider.homepageWallpaperPath;
        userName = Provider.of<SettingProvider>(context, listen: false).userName;
        password = Provider.of<SettingProvider>(context, listen: false).password;
        if(authProvider!.getLoginStatus() == LoginStatus.logout) {
          authProvider!.handleEmailSignIn(userName, password);
        }
        return Scaffold(
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
                    if(authProvider != null) ...{
                      if (authProvider!.getLoginStatus() == LoginStatus.logout) ...{
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
                            child: Text(DemoLocalizations.of(context).textSignBtn),
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
                                AuthStatus status = await authProvider!.handleEmailSignIn(usernameController.text.trim(), passwordController.text.trim());
                                if(status == AuthStatus.success) {
                                  GFToast.showToast(
                                    DemoLocalizations.of(context).sucSignBtn,
                                    context,
                                    toastPosition: GFToastPosition.BOTTOM,
                                    textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                    backgroundColor: GFColors.LIGHT,
                                    trailing: const Icon(
                                      Icons.thumb_up_rounded,
                                      color: GFColors.SUCCESS,
                                    )
                                  );
                                  Provider.of<SettingProvider>(context, listen: false).updateUserName(usernameController.text);
                                  Provider.of<SettingProvider>(context, listen: false).updatePassword(passwordController.text);
                                  setState(() {
                                  });
                                } else if(status == AuthStatus.maxLoggin) {
                                  GFToast.showToast(
                                    DemoLocalizations.of(context).moreLoginErrSignBtn,
                                    context,
                                    toastPosition: GFToastPosition.BOTTOM,
                                    textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                    backgroundColor: GFColors.WARNING,
                                    trailing: const Icon(
                                      Icons.error,
                                      color: GFColors.DANGER,
                                    )
                                  );
                                } else {
                                  GFToast.showToast(
                                    DemoLocalizations.of(context).credToastSignBtn,
                                    context,
                                    toastPosition: GFToastPosition.BOTTOM,
                                    textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                    backgroundColor: GFColors.WARNING,
                                    trailing: const Icon(
                                      Icons.thumb_down_rounded,
                                      color: GFColors.DANGER,
                                    )
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        TextButton(
                          onPressed: () async {
                            // Navigate to register screen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                            if (result != null && result is Map<String, String>) {
                              usernameController.text = result['username'] ?? '';
                              passwordController.text = result['password'] ?? '';

                              if(usernameController.text != '' && passwordController.text != '') {
                                Provider.of<SettingProvider>(context, listen: false).updateUserName(usernameController.text);
                                Provider.of<SettingProvider>(context, listen: false).updatePassword(passwordController.text);
                                setState(() {
                                });
                              }
                            }
                          },
                          child: Text(DemoLocalizations.of(context).registerQuery),
                        ),
                        const SizedBox(height: 5.0),
                        SignInButton(
                          Buttons.Google,
                          onPressed: () async {
                            AuthStatus status = await authProvider!.handleGoogleSignIn();
                            if(status == AuthStatus.success) {
                              GFToast.showToast(
                                DemoLocalizations.of(context).sucSignBtn,
                                context,
                                toastPosition: GFToastPosition.BOTTOM,
                                textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                backgroundColor: GFColors.LIGHT,
                                trailing: const Icon(
                                  Icons.thumb_up_rounded,
                                  color: GFColors.SUCCESS,
                                )
                              );
                              Provider.of<SettingProvider>(context, listen: false).updateUserName(usernameController.text);
                              Provider.of<SettingProvider>(context, listen: false).updatePassword(passwordController.text);
                              setState(() {
                              });
                            } else if(status == AuthStatus.maxLoggin) {
                              GFToast.showToast(
                                'Simultaneous logins on more than 2 devices are not allowed.',
                                context,
                                toastPosition: GFToastPosition.BOTTOM,
                                textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                backgroundColor: GFColors.WARNING,
                                trailing: const Icon(
                                  Icons.error,
                                  color: GFColors.DANGER,
                                )
                              );
                            } else {
                              GFToast.showToast(
                                DemoLocalizations.of(context).credToastSignBtn,
                                context,
                                toastPosition: GFToastPosition.BOTTOM,
                                textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                                backgroundColor: GFColors.WARNING,
                                trailing: const Icon(
                                  Icons.thumb_down_rounded,
                                  color: GFColors.DANGER,
                                )
                              );
                            }
                          },
                        ),
                        SignInButton(
                          Buttons.Apple,
                          onPressed: () {},
                        ),
                        SignInButton(
                          Buttons.Microsoft,
                          onPressed: () {},
                        )
                      } else ...{
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                  child: Text(DemoLocalizations.of(context).textChatBtn),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ChatHome()),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(authProvider!.getLoginStatus() == LoginStatus.googleLogin) ...{
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
                                    onPressed: () {
                                      authProvider!.signOut();
                                      Provider.of<SettingProvider>(context, listen: false).updateUserName("");
                                      Provider.of<SettingProvider>(context, listen: false).updatePassword("");
                                      setState(() {
                                      });
                                    },
                                    text: DemoLocalizations.of(context).textSignOutGoogle,
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
                          )
                        } else if (authProvider!.getLoginStatus() == LoginStatus.emailLogin) ...{
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: OverflowBar(
                              alignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(Icons.email_rounded),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: GFButton(
                                    onPressed: () {
                                      authProvider!.signOut();
                                      Provider.of<SettingProvider>(context, listen: false).updateUserName("");
                                      Provider.of<SettingProvider>(context, listen: false).updatePassword("");
                                      setState(() {
                                      });
                                    },
                                    text: DemoLocalizations.of(context).textSignOutEmail,
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
                          )
                        },
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'By creating an account, you are agreeing to our ',
                                style: const TextStyle(color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        showDialog(context: context, builder: (context) => PolicyDialog(mdFileName: 'terms_conditions.md'));
                                      },
                                  ),
                                  const TextSpan(
                                    text: ' and ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        showDialog(context: context, builder: (context) => PolicyDialog(mdFileName: 'privacy_policy.md'));
                                      },
                                  ),
                                  const TextSpan(
                                    text: '!',
                                  ),
                                ],
                              ),
                            ),
                          )
                        ),
                      },
                    },
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