import 'package:flutter/material.dart';
import 'l10n/localization_intl.dart';

class WelcomeDialog extends StatelessWidget {
  final double radius;

  const WelcomeDialog({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                  bottomLeft: const Radius.circular(0),
                  bottomRight: const Radius.circular(0),
                ),
              ),
              child: Text(
                DemoLocalizations.of(context).welcomeTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph1,
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph2,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph3,
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph4,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph6,
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph2,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph7,
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph8,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph9,
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph4,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph11,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph12,
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph13,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph14,
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph15,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          TextSpan(
                            text: DemoLocalizations.of(context).welcomeParagraph16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // Return result when "CLOSE" is clicked
                  Navigator.of(context).pop('close');
                },
                child: Text(
                  DemoLocalizations.of(context).okBtn,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}