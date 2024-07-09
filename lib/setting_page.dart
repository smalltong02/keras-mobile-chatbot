import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:keras_mobile_chatbot/wheel_character.dart';
import 'package:keras_mobile_chatbot/wallpaper_page.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key,});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String modelName = "gemini-1.5-pro";
  String assistantIconPath = 'assets/icons/11/11.png';
  String yourIconPath = 'assets/icons/14/9.png';
  String homepageWallpaperPath = 'assets/backgrounds/49.jpg';
  String chatpageWallpaperPath = 'assets/backgrounds/64.jpg';
  bool toggleDarkMode = false;
  final List<String> llmModel = [
    "gemini-1.5-pro",
    "gemini-1.5-flash",
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
    super.initState();
  }

  void wallpaperCallback(String homepageWallpaperPath, String chatpageWallpaperPath) {
    setState(() {
      homepageWallpaperPath = homepageWallpaperPath;
      chatpageWallpaperPath = chatpageWallpaperPath;
      Provider.of<SettingProvider>(context, listen: false).updateWallpaper(homepageWallpaperPath, chatpageWallpaperPath);
    });
  }

  void roleCallback(String path) {
    setState(() {
      assistantIconPath = path;
      Provider.of<SettingProvider>(context, listen: false).updateRoleIcon(assistantIconPath);
    });
  }

  void playerCallback(String path) {
    setState(() {
      yourIconPath = path;
      Provider.of<SettingProvider>(context, listen: false).updatePlayerIcon(yourIconPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    modelName = Provider.of<SettingProvider>(context, listen: false).modelName;
    assistantIconPath = Provider.of<SettingProvider>(context, listen: false).roleIconPath;
    yourIconPath = Provider.of<SettingProvider>(context, listen: false).playerIconPath;
    homepageWallpaperPath = Provider.of<SettingProvider>(context, listen: false).homepageWallpaperPath;
    chatpageWallpaperPath = Provider.of<SettingProvider>(context, listen: false).chatpageWallpaperPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: SafeArea(
          child: SettingsList(
            sections: [
              SettingsSection(
                title: const Text(
                  'Chat Settings',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.chat),
                    title: const Text('Model'),
                    trailing: DropdownButton<String>(
                      value: modelName,
                      onChanged: (String? newValue) {
                        modelName = newValue!;
                        Provider.of<SettingProvider>(context, listen: false).updateModel(modelName);
                        setState(() {});
                      },
                      items: llmModel.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.pets),
                    title: const Text('Assistant Icon'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (assistantIconPath.isNotEmpty) ...{
                          Image.asset(
                            assistantIconPath,
                            width: 40,
                            height: 40,
                          )
                        },
                        const Icon(Icons.arrow_right),
                      ],
                    ),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CharactersListPage(
                            charactersList: assistantCharacters,
                            characterIconPath: assistantIconPath,
                            characterCallback: roleCallback,
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.person),
                    title: const Text('Player Icon'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (yourIconPath.isNotEmpty) ...{
                          Image.asset(
                            yourIconPath,
                            width: 40,
                            height: 40,
                          )
                        },
                        const Icon(Icons.arrow_right),
                      ],
                    ),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CharactersListPage(
                            charactersList: playerCharacters,
                            characterIconPath: yourIconPath,
                            characterCallback: playerCallback,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text(
                  'General',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    initialValue: toggleDarkMode,
                    title: const Text('Dark Mode'),
                    leading: const Icon(Icons.cloud),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      toggleDarkMode = value;
                      setState(() {});
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.image),
                    title: const Text('Wallpaper'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (homepageWallpaperPath.isNotEmpty) ...{
                          Image.asset(
                            homepageWallpaperPath,
                            width: 40,
                            height: 40,
                          )
                        },
                        const SizedBox(width: 8),
                        if (chatpageWallpaperPath.isNotEmpty) ...{
                          Image.asset(
                            chatpageWallpaperPath,
                            width: 40,
                            height: 40,
                          ),
                        },
                        const Icon(Icons.arrow_right),
                      ],
                    ),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WallpaperPage(
                            homepageWallpaperPath: homepageWallpaperPath,
                            chatpageWallpaperPath: chatpageWallpaperPath,
                            wallpaperCallback: (String homepagePath, String chatpagePath) {
                              wallpaperCallback(homepagePath, chatpagePath);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}