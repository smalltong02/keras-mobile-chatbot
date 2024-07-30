import 'package:flutter/material.dart';
import 'package:keras_mobile_chatbot/policy_dialog.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keras Subscription'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Stack(children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(
                          'assets/streamer/keras_subscription.jpeg',
                        ),
                      ),
                    ),
                    height: 420.0,
                  ),
                  Container(
                    height: 420.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          Colors.grey.withOpacity(0.0),
                          Colors.purple.shade200,
                        ],
                        stops: const [
                          0.5,
                          1.0
                        ]
                      )
                    ),
                  )
                ]
              ),),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubscriptionDetail(
                      icon: Icons.circle,
                      color: Colors.red,
                      text: 'Basic Sub: Gemini flash + image recognition',
                      textColor: Colors.blue,
                    ),
                    SubscriptionDetail(
                      icon: Icons.circle,
                      color: Colors.red,
                      text: 'Professional Sub: Basic + Speech',
                      textColor: Colors.blue,
                    ),
                    SubscriptionDetail(
                      icon: Icons.circle,
                      color: Colors.red,
                      text: 'Premium Sub: Pro + Gemini Pro (or GPT 4o)',
                      textColor: Colors.blue,
                    ),
                    SubscriptionDetail(
                      icon: Icons.circle,
                      color: Colors.red,
                      text: 'Ultimate Sub: Premium + Google ToolBox',
                      textColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              SubscriptionButton(
                text: 'Basic Subscription  \$2.99/month',
                color: Colors.yellow,
                onPressed: () {
                  // Handle Basic Subscription press
                },
              ),
              SubscriptionButton(
                text: 'Professional Subscription \$4.99/month',
                color: Colors.orange,
                onPressed: () {
                  // Handle Pro Subscription press
                },
              ),
              SubscriptionButton(
                text: 'Premium Subscription \$8.99/month',
                color: Colors.green,
                onPressed: () {
                  // Handle Premium Subscription press
                },
              ),
              SubscriptionButton(
                text: 'Ultimate Subscription \$12.99/month',
                color: Colors.teal,
                onPressed: () {
                  // Handle Ultimate Subscription press
                },
              ),
              TextButton(
                onPressed: () {
                  // Handle Terms of use press
                },
                child: GestureDetector(
                  onTap: () {
                    showDialog(context: context, builder: (context) => PolicyDialog(mdFileName: 'terms_conditions.md', justShow: true,));
                  },
                  child: const Text(
                    'Terms of use',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubscriptionDetail extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final Color textColor;

  const SubscriptionDetail({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const SubscriptionButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () {
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: color.withOpacity(0.6),
        ),
        child: Text(text),
      ),
    );
  }
}