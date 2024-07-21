import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PolicyDialog extends StatelessWidget {
  final double radius;
  final String mdFileName;

  PolicyDialog({super.key, this.radius = 16, required this.mdFileName})
      : assert(mdFileName.contains('.md'), 'The file must contain the .md extension');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Make the background transparent
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Material(
        color: Colors.white, // Set the dialog content's background color
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: FutureBuilder(
                future: Future.delayed(const Duration(milliseconds: 150)).then((value) {
                  return rootBundle.loadString('assets/docs/$mdFileName');
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Markdown(
                        data: snapshot.data ?? "",
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "CLOSE",
                  style: TextStyle(
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