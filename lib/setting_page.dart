import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:keras_mobile_chatbot/utils.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String assistantName = "Jessica";

  @override
  void initState() {
    assistantName = Provider.of<SettingProvider>(context, listen: false).currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: <SettingsTile>[
              // SettingsTile.switchTile(
              //   onToggle: (value) {},
              //   initialValue: true,
              //   leading: Icon(Icons.format_paint),
              //   title: Text('Enable custom theme'),
              // ),
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                trailing: DropdownButton<String>(
                  value: 'English',
                  onChanged: (String? newValue) {
                  },
                  items: <String>['English']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.person),
                title: Text('Assistant'),
                trailing: DropdownButton<String>(
                  value: assistantName,
                  onChanged: (String? newValue) {
                    assistantName = newValue!;
                    Provider.of<SettingProvider>(context, listen: false).updateRole(newValue);
                    setState(() {
                    });
                  },
                  items: <String>["James","Michael","William","David","John","Emily","Sarah","Jessica","Elizabeth","Jennifer"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}