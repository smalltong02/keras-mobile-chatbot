import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/localization_intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PolicyDialog extends StatelessWidget {
  final double radius;
  final String mdFileName;
  bool justShow = false;

  PolicyDialog({super.key, this.radius = 16, required this.mdFileName, required this.justShow})
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
                          p: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16, 
                            color: Colors.black,
                          ),
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
            if(justShow) ...{
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
                    DemoLocalizations.of(context).closeBtn,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            } else ...{
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          // borderRadius: BorderRadius.only(
                          //   bottomLeft: Radius.circular(radius),
                          // ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        // Return result when "CLOSE" is clicked
                        Navigator.of(context).pop('accept');
                      },
                      child: Text(
                        DemoLocalizations.of(context).acceptBtn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          // borderRadius: BorderRadius.only(
                          //   bottomLeft: Radius.circular(radius),
                          // ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        // Return result when "CLOSE" is clicked
                        Navigator.of(context).pop('close');
                      },
                      child: Text(
                        DemoLocalizations.of(context).closeBtn,
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
            },
          ],
        ),
      ),
    );
  }
}