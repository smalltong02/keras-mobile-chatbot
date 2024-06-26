import 'package:flutter/material.dart';
import 'package:keras_mobile_chatbot/chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
                  'Keras Mobile ChatBot',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,),
              ],
            ),
            // spacer
            const SizedBox(height: 120.0),
            // [Name]
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Username',
              ),
            ),
            // spacer
            const SizedBox(height: 12.0),
            // [Password]
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10.0),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              // TODO: Add a beveled rectangular border to CANCEL (103)
              children: <Widget>[
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                ),
                // TODO: Add an elevation to NEXT (103)
                // TODO: Add a beveled rectangular border to NEXT (103)
                ElevatedButton(
                  child: const Text('NEXT'),
                  onPressed: () {
                    String username = _usernameController.text;
                    String password = _passwordController.text;
                    if (username == 'admin' && password == 'admin') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatHome()),
                      );
                    } else {
                      // Show an alert dialog with the message "Invalid username or password"
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Invalid username or password'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
            // TODO: Remove filled: true values (103)
            // TODO: Add TextField widgets (101)
            // TODO: Add button bar (101)
          ],
        ),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text(
      //         'Welcome to Keras Mobile ChatBot!',
      //         style: TextStyle(fontSize: 24),
      //       ),
      //       SizedBox(height: 16),
      //       ElevatedButton(
      //         onPressed: () {
      //           // Navigator to chat UI
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => ChatHome()),
      //           );
      //         },
      //         child: Text('Start Chatting'),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
