import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'l10n/localization_intl.dart';
import 'package:provider/provider.dart';
import 'package:getwidget/getwidget.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:keras_mobile_chatbot/wheel_character.dart';
import 'package:keras_mobile_chatbot/wallpaper_page.dart';

class SettingScreen extends StatefulWidget {
  final List<Character> assistantCharacters;
  final List<Character> playerCharacters;
  const SettingScreen({super.key, required this.assistantCharacters, required this.playerCharacters});

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  String modelName = defaultModel;
  String assistantIconPath = 'assets/icons/11/11.png';
  String yourIconPath = 'assets/icons/14/9.png';
  String homepageWallpaperPath = 'assets/backgrounds/49.jpg';
  String chatpageWallpaperPath = 'assets/backgrounds/64.jpg';
  String currentLanguage = '';
  int chatFontSize = 14;
  bool speechEnable = false;
  bool toolBoxEnable = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Character findCharacterByTitle(String title) {
    Character character = Character();

    for (var char in widget.assistantCharacters) {
      if (char.title == title) {
        character = char;
        break;
      }
    }
    
    return character;
  }

  Character findCharacterByAvatar(String avatar) {
    Character character = Character();

    for (var char in widget.assistantCharacters) {
      if (char.avatar == avatar) {
        character = char;
        break;
      }
    }
    
    return character;
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
      Character character = findCharacterByAvatar(path);
      String roleName = character.title ?? DemoLocalizations.of(context).assistantName20;
      Provider.of<SettingProvider>(context, listen: false).updateRole(roleName);
    });
  }

  void playerCallback(String path) {
    setState(() {
      yourIconPath = path;
      Provider.of<SettingProvider>(context, listen: false).updatePlayerIcon(yourIconPath);
    });
  }

  Future<void> clearCache() async {
    io.Directory cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
      setState(() {
      });
    }
  }

  String formatBytes(int bytes) {
    const suffix = ['B', 'KB', 'MB', 'GB', 'TB'];
    int index = 0;
    while (bytes > 1024) {
      bytes = (bytes ~/ 1024);
      index++;
    }
    return '$bytes ${suffix[index]}';
  }

  String convertLanguage(String language) {
    currentLanguage = DemoLocalizations.of(context).titleAuto;
    if(language == 'en') {
      currentLanguage = DemoLocalizations.of(context).titleEnglish;
    }
    else if(language == 'fr') {
      currentLanguage = DemoLocalizations.of(context).titleFrench;
    }
    else if(language == 'zh-cn') {
      currentLanguage = DemoLocalizations.of(context).titleChinese;
    }
    else if(language == 'zh-tw') {
      currentLanguage = DemoLocalizations.of(context).titletraditional;
    }
    else if(language == 'yue') {
      currentLanguage = DemoLocalizations.of(context).titleCantonese;
    }
    else if(language == 'de') {
      currentLanguage = DemoLocalizations.of(context).titleGerman;
    }
    else if(language == 'es') {
      currentLanguage = DemoLocalizations.of(context).titleSpanish;
    }
    else if(language == 'ru') {
      currentLanguage = DemoLocalizations.of(context).titleRussian;
    }
    else if(language == 'ko') {
      currentLanguage = DemoLocalizations.of(context).titleKorean;
    }
    else if(language == 'ja') {
      currentLanguage = DemoLocalizations.of(context).titleJapanese;
    }
    else if(language == 'hi') {
      currentLanguage = DemoLocalizations.of(context).titleIndia;
    }
    else if(language == 'vi') {
      currentLanguage = DemoLocalizations.of(context).titleVietnam;
    }
    return currentLanguage;
  }

  String revertLanguage(String language) {
    String settingLanguage = 'auto';
    if(language == DemoLocalizations.of(context).titleEnglish) {
      settingLanguage = 'en';
    }
    else if(language == DemoLocalizations.of(context).titleFrench) {
      settingLanguage = 'fr';
    }
    else if(language == DemoLocalizations.of(context).titleChinese) {
      settingLanguage = 'zh-cn';
    }
    else if(language == DemoLocalizations.of(context).titletraditional) {
      settingLanguage = 'zh-tw';
    }
    else if(language == DemoLocalizations.of(context).titleCantonese) {
      settingLanguage = 'yue';
    }
    else if(language == DemoLocalizations.of(context).titleGerman) {
      settingLanguage = 'de';
    }
    else if(language == DemoLocalizations.of(context).titleSpanish) {
      settingLanguage = 'es';
    }
    else if(language == DemoLocalizations.of(context).titleRussian) {
      settingLanguage = 'ru';
    }
    else if(language == DemoLocalizations.of(context).titleKorean) {
      settingLanguage = 'ko';
    }
    else if(language == DemoLocalizations.of(context).titleJapanese) {
      settingLanguage = 'ja';
    }
    else if(language == DemoLocalizations.of(context).titleIndia) {
      settingLanguage = 'in';
    }
    else if(language == DemoLocalizations.of(context).titleVietnam) {
      settingLanguage = 'vi';
    }
    return settingLanguage;
  }

  @override
  Widget build(BuildContext context) {
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    currentLanguage = convertLanguage(Provider.of<SettingProvider>(context, listen: false).language);
    chatFontSize = Provider.of<SettingProvider>(context, listen: false).chatFontSize;
    modelName = Provider.of<SettingProvider>(context, listen: false).modelName;
    assistantIconPath = Provider.of<SettingProvider>(context, listen: false).roleIconPath;
    yourIconPath = Provider.of<SettingProvider>(context, listen: false).playerIconPath;
    homepageWallpaperPath = Provider.of<SettingProvider>(context, listen: false).homepageWallpaperPath;
    chatpageWallpaperPath = Provider.of<SettingProvider>(context, listen: false).chatpageWallpaperPath;
    speechEnable = Provider.of<SettingProvider>(context, listen: false).speechEnable;
    toolBoxEnable = Provider.of<SettingProvider>(context, listen: false).toolBoxEnable;
    final subProvider = Provider.of<KerasSubscriptionProvider>(context);
    final authProvider = Provider.of<KerasAuthProvider>(context);
    bool speechPermission = subProvider.speechPermission();
    bool baseModelPremission = subProvider.baseModelPermission();
    bool powerModelPermission = subProvider.powerModelPermission();
    bool toolboxPermission = subProvider.toolboxPermission();
    List<String> modelList = [];
    if(baseModelPremission) {
      modelList = lowPowerModel;
    }
    if(powerModelPermission) {
      modelList = allModel;
    }
    if(modelList.isNotEmpty) {
      if(!modelList.contains(modelName)) {
        modelName = modelList[0];
      }
    } else {
      modelName = "";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DemoLocalizations.of(context).titleSetting,
          style: const TextStyle(
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
                title: Text(
                  DemoLocalizations.of(context).titleChatSetting,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.chat),
                    title: Text(DemoLocalizations.of(context).titleModel),
                    trailing: DropdownButton<String>(
                      value: modelName,
                      onChanged: (String? newValue) {
                        if(modelName != newValue) {
                          modelName = newValue!;
                          Provider.of<SettingProvider>(context, listen: false).updateModel(modelName);
                          GFToast.showToast(
                            "Loading $modelName...",
                            context,
                            toastPosition: GFToastPosition.TOP,
                            textStyle: const TextStyle(fontSize: 12, color: GFColors.WHITE),
                            backgroundColor: GFColors.FOCUS,
                            trailing: const Icon(
                              Icons.error,
                              color: GFColors.INFO,
                            )
                          );
                          setState(() {});
                        }
                      },
                      items: modelList.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.pets),
                    title: Text(DemoLocalizations.of(context).titleAssistantIcon),
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
                            charactersList: widget.assistantCharacters,
                            characterIconPath: assistantIconPath,
                            characterCallback: roleCallback,
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.person),
                    title: Text(DemoLocalizations.of(context).titlePlayerIcon),
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
                            charactersList: widget.playerCharacters,
                            characterIconPath: yourIconPath,
                            characterCallback: playerCallback,
                          ),
                        ),
                      );
                    },
                  ),
                  if(speechPermission)
                    SettingsTile.switchTile(
                      initialValue: speechEnable,
                      title: Text(DemoLocalizations.of(context).titleSpeech),
                      leading: const Icon(Icons.volume_up_sharp),
                      activeSwitchColor: Theme.of(context).colorScheme.primary,
                      onToggle: (value) {
                        setState(() {
                          speechEnable = value;
                          Provider.of<SettingProvider>(context, listen: false).updateSpeechEnable(speechEnable);
                        });
                      },
                    ),
                  if(toolboxPermission)
                    SettingsTile.switchTile(
                      initialValue: toolBoxEnable,
                      title: Text(DemoLocalizations.of(context).titleToolBox),
                      leading: const Icon(Icons.all_inbox_rounded),
                      activeSwitchColor: Theme.of(context).colorScheme.primary,
                      onToggle: (value) {
                        setState(() {
                          toolBoxEnable = value;
                          Provider.of<SettingProvider>(context, listen: false).updateToolBoxEnable(toolBoxEnable);
                          Provider.of<SettingProvider>(context, listen: false).updateLanguage(revertLanguage(currentLanguage));
                          setState(() {});
                        });
                      },
                    ),
                ],
              ),
              SettingsSection(
                title: Text(
                  DemoLocalizations.of(context).titleGeneral,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.image),
                    title: Text(DemoLocalizations.of(context).titleWallpaper),
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
                    title: Text(DemoLocalizations.of(context).titleLanguage),
                    trailing: DropdownButton<String>(
                      value: currentLanguage,
                      onChanged: (String? newValue) {
                        if(currentLanguage != newValue) {
                          currentLanguage = newValue!;
                          Provider.of<SettingProvider>(context, listen: false).updateLanguage(revertLanguage(currentLanguage));
                          setState(() {});
                        }
                      },
                      items: <String>[
                        DemoLocalizations.of(context).titleAuto, 
                        DemoLocalizations.of(context).titleEnglish, 
                        DemoLocalizations.of(context).titleFrench, 
                        DemoLocalizations.of(context).titleSpanish, 
                        DemoLocalizations.of(context).titleGerman,
                        DemoLocalizations.of(context).titleRussian,
                        DemoLocalizations.of(context).titleKorean,
                        DemoLocalizations.of(context).titleJapanese,
                        DemoLocalizations.of(context).titleChinese,
                        DemoLocalizations.of(context).titletraditional,
                        DemoLocalizations.of(context).titleCantonese,
                        DemoLocalizations.of(context).titleIndia,
                        DemoLocalizations.of(context).titleVietnam,]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: Text(DemoLocalizations.of(context).chatFontSize),
                    trailing: DropdownButton<int>(
                      value: chatFontSize,
                      onChanged: (int? newValue) {
                        if(chatFontSize != newValue) {
                          chatFontSize = newValue!;
                          Provider.of<SettingProvider>(context, listen: false).updateChatFontSize(chatFontSize);
                          setState(() {});
                        }
                      },
                      items: fontSizeList
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: Text(
                  DemoLocalizations.of(context).titleCache,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile(
                    leading: const Icon(Icons.cached_sharp),
                    title: Text(DemoLocalizations.of(context).titleCacheSize),
                    trailing: FutureBuilder<io.Directory>(
                      future: getTemporaryDirectory(),
                      builder: (BuildContext context, AsyncSnapshot<io.Directory> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(DemoLocalizations.of(context).promptCalculating);
                        } else if (snapshot.hasError) {
                          return const Text('Error');
                        } else if (snapshot.hasData) {
                          int size = snapshot.data!.listSync(recursive: true, followLinks: false)
                              .fold<int>(0, (prev, element) => prev + io.File(element.path).statSync().size);
                          return Text(formatBytes(size));
                        } else {
                          return const Text('Unknown');
                        }
                      },
                    ),
                    onPressed: (context) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(DemoLocalizations.of(context).titleClearCache),
                            content: Text(DemoLocalizations.of(context).confirmClearCache),
                            actions: <Widget>[
                              TextButton(
                                child: Text(DemoLocalizations.of(context).cancelBtn),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(DemoLocalizations.of(context).clearBtn),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await clearCache();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text(
                  DemoLocalizations.of(context).userAccountTitle,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile(
                    leading: const Icon(Icons.auto_delete_sharp),
                    title: Text(DemoLocalizations.of(context).accountDialogTitle),
                    onPressed: (context) async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(DemoLocalizations.of(context).accountDialogTitle),
                            content: Text(DemoLocalizations.of(context).submitRequestQuery),
                            actions: <Widget>[
                              TextButton(
                                child: Text(DemoLocalizations.of(context).cancelBtn),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(DemoLocalizations.of(context).submitBtn),
                                onPressed: () async {
                                  final mailer = Mailer();
                                  await mailer.sendDeleteDataRequest(authProvider.getLoginEmail(), authProvider.getLoginName());
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.email_rounded),
                    title: Text(DemoLocalizations.of(context).otherRequestTitle),
                    onPressed: (context) async {
                      final mailer = Mailer();
                      await mailer.sendEmail("",mailer.defaultRecipients, "", null, null, null, false);
                    },
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