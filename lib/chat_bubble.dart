import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomShape extends CustomPainter {
  final Color bgColor;

  CustomShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;
    var path = Path();

    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SentMessageScreen extends StatelessWidget {
  final String message;
  final String iconPath;

  static const double _paddingHorizontal = 18.0;
  static const double _paddingVertical = 15.0;
  static const double _messagePaddingAll = 14.0;
  static const double _iconSize = 40.0;
  static const double _messageFontSize = 14.0;
  static const Color _messageBackgroundColor = Colors.cyan;
  static const Color _messageTextColor = Colors.white;

  const SentMessageScreen({
    Key? key,
    required this.message,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(_messagePaddingAll),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: _messageTextColor, fontSize: _messageFontSize),
                ),
              ),
            ),
            CustomPaint(painter: CustomShape(_messageBackgroundColor)),
            SizedBox(width: 4),
            Image.asset(
              iconPath,
              width: _iconSize,
              height: _iconSize,
            ),
          ],
        ));

    return Padding(
      padding: EdgeInsets.only(right: _paddingHorizontal, left: 50, top: _paddingVertical, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}

class ReceivedMessageScreen extends StatelessWidget {
  final String message;
  final String iconPath;

  static const double _paddingHorizontal = 18.0;
  static const double _paddingVertical = 10.0;
  static const double _messagePaddingAll = 14.0;
  static const double _iconSize = 40.0;
  static const double _messageFontSize = 14.0;
  static const Color _messageBackgroundColor = Colors.grey;
  static const Color _messageTextColor = Colors.black;

  const ReceivedMessageScreen({
    Key? key,
    required this.message,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: _iconSize,
              height: _iconSize,
            ),
            SizedBox(width: 4),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: CustomPaint(
                painter: CustomShape(_messageBackgroundColor),
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(_messagePaddingAll),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: _messageTextColor, fontSize: _messageFontSize),
                ),
              ),
            ),
          ],
        ));

    return Padding(
      padding: EdgeInsets.only(right: 50.0, left: _paddingHorizontal, top: _paddingVertical, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}