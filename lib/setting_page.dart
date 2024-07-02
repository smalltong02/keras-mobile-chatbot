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
  String assistantIconPath = 'assets/icons/11/11.png';
  String yourIconPath = 'assets/icons/14/9.png';
  final List<String> aiAppearancePaths = [
    'assets/icons/9/9_0.png',
    'assets/icons/9/9_1.png',
    'assets/icons/9/9_2.png',
    'assets/icons/9/9_3.png',
    'assets/icons/9/9_4.png',
    'assets/icons/9/9_5.png',
    'assets/icons/9/9_6.png',
    'assets/icons/9/9_7.png',
    'assets/icons/9/9_8.png',
    'assets/icons/11/1.png',
    'assets/icons/11/2.png',
    'assets/icons/11/3.png',
    'assets/icons/11/4.png',
    'assets/icons/11/5.png',
    'assets/icons/11/6.png',
    'assets/icons/11/7.png',
    'assets/icons/11/8.png',
    'assets/icons/11/9.png',
    'assets/icons/11/10.png',
    'assets/icons/11/11.png',
    'assets/icons/11/12.png',
  ];

  final List<String> yourAppearancePaths = [
    'assets/icons/2/2_0.png',
    'assets/icons/2/2_1.png',
    'assets/icons/2/2_2.png',
    'assets/icons/2/2_3.png',
    'assets/icons/2/2_4.png',
    'assets/icons/2/2_5.png',
    'assets/icons/2/2_6.png',
    'assets/icons/2/2_7.png',
    'assets/icons/2/2_8.png',
    'assets/icons/3/2.png',
    'assets/icons/3/3.png',
    'assets/icons/3/6.png',
    'assets/icons/3/12.png',
    'assets/icons/3/16.png',
    'assets/icons/4/4.png',
    'assets/icons/4/14.png',
    'assets/icons/14/2.png',
    'assets/icons/14/5.png',
    'assets/icons/14/9.png',
  ];

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
              SettingsTile.navigation(
                leading: Icon(Icons.assistant),
                title: Text('Assistant Icon'),
                trailing: DropdownButton<String>(
                  value: assistantIconPath,
                  onChanged: (String? newValue) {
                    assistantIconPath = newValue!;
                    Provider.of<SettingProvider>(context, listen: false).updateRoleIcon(newValue);
                    setState(() {
                    });
                  },
                  items: aiAppearancePaths.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Image.asset(
                        value,
                        width: 40,
                        height: 40,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.person),
                title: Text('Your Icon'),
                trailing: DropdownButton<String>(
                  value: yourIconPath,
                  onChanged: (String? newValue) {
                    yourIconPath = newValue!;
                    Provider.of<SettingProvider>(context, listen: false).updatePlayerIcon(newValue);
                    setState(() {
                    });
                  },
                  items: yourAppearancePaths.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Image.asset(
                        value,
                        width: 40,
                        height: 40,
                      ),
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