import 'package:flutter/material.dart';
import 'package:keras_mobile_chatbot/chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keras Mobile ChatBot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Keras Mobile ChatBot!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator to chat UI
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatHome()),
                );
              },
              child: Text('Start Chatting'),
            ),
          ],
        ),
      ),
    );
  }
}
