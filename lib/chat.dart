import 'dart:async';
import 'dart:io' as io;
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart' as openai;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:record/record.dart';
import 'l10n/localization_intl.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image/image.dart' as img;
import 'package:qonversion_flutter/qonversion_flutter.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:keras_mobile_chatbot/function_call.dart';
import 'package:keras_mobile_chatbot/chat_bubble.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keras_mobile_chatbot/setting_page.dart';
import 'package:keras_mobile_chatbot/takepicture_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.gradient, this.style});

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style?.copyWith(color: Colors.white),
      ),
    );
  }
}

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  ChatHomeState createState() => ChatHomeState();
}

class ChatHomeState  extends State<ChatHome>  {
  final String paywallCode = dotenv.get('qonversion_paywall');
  List<Character> assistantCharacters = [];
  List<Character> playerCharacters = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    initAssistantCharacters();
    initPlayerCharacters();
  }

  Future<void> subscriptionScreen() async {
    try {
      var config = QScreenPresentationConfig(QScreenPresentationStyle.push, true);
      // Set configuration for all screens.
      Automations.getSharedInstance().setScreenPresentationConfig(config);
      // Set configuration for the concrete screen.
      Automations.getSharedInstance().setScreenPresentationConfig(config, paywallCode);
      await Automations.getSharedInstance().showScreen(paywallCode);
    } catch (e, stackTrace) {
      logger.e("subscriptionScreen crash: ", stackTrace: stackTrace);
    }
  }

  void initAssistantCharacters() {
    assistantCharacters = <Character>[
      Character(
        title: DemoLocalizations.of(context).assistantName1,
        description: DemoLocalizations.of(context).assistantDesc1,
        avatar: "assets/icons/9/9_0.png",
        color: 0xFFE83835,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName2,
        description: DemoLocalizations.of(context).assistantDesc2,
        avatar: "assets/icons/9/9_1.png",
        color: 0xFF238BD0,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName3,
        description: DemoLocalizations.of(context).assistantDesc3,
        avatar: "assets/icons/9/9_2.png",
        color: 0xFF354C6C,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName4,
        description: DemoLocalizations.of(context).assistantDesc4,
        avatar: "assets/icons/9/9_3.png",
        color: 0xFF6F2B62,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName5,
        description: DemoLocalizations.of(context).assistantDesc5,
        avatar: "assets/icons/9/9_4.png",
        color: 0xFF447C12,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName6,
        description: DemoLocalizations.of(context).assistantDesc6,
        avatar: "assets/icons/9/9_5.png",
        color: 0xFFE7668E,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName7,
        description: DemoLocalizations.of(context).assistantDesc7,
        avatar: "assets/icons/9/9_6.png",
        color: 0xFFBD9158,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName8,
        description: DemoLocalizations.of(context).assistantDesc8,
        avatar: "assets/icons/9/9_7.png",
        color: 0xFFE8A2B6,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName9,
        description: DemoLocalizations.of(context).assistantDesc9,
        avatar: "assets/icons/9/9_8.png",
        color: 0xFFC5D128,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName10,
        description: DemoLocalizations.of(context).assistantDesc10,
        avatar: "assets/icons/11/1.png",
        color: 0xFF91AF50,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName11,
        description: DemoLocalizations.of(context).assistantDesc11,
        avatar: "assets/icons/11/2.png",
        color: 0xFF3B7F92,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName12,
        description: DemoLocalizations.of(context).assistantDesc12,
        avatar: "assets/icons/11/3.png",
        color: 0xFF6C83AB,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName13,
        description: DemoLocalizations.of(context).assistantDesc13,
        avatar: "assets/icons/11/4.png",
        color: 0xFFA1B2C3,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName14,
        description: DemoLocalizations.of(context).assistantDesc14,
        avatar: "assets/icons/11/5.png",
        color: 0xFFD4E5F6,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName15,
        description: DemoLocalizations.of(context).assistantDesc15,
        avatar: "assets/icons/11/6.png",
        color: 0xFFFA8072,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName16,
        description: DemoLocalizations.of(context).assistantDesc16,
        avatar: "assets/icons/11/7.png",
        color: 0xFF8A2BE2,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName17,
        description: DemoLocalizations.of(context).assistantDesc17,
        avatar: "assets/icons/11/8.png",
        color: 0xFF5F9EA0,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName18,
        description: DemoLocalizations.of(context).assistantDesc18,
        avatar: "assets/icons/11/9.png",
        color: 0xFF7FFF00,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName19,
        description: DemoLocalizations.of(context).assistantDesc19,
        avatar: "assets/icons/11/10.png",
        color: 0xFFD2691E,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName20,
        description: DemoLocalizations.of(context).assistantDesc20,
        avatar: "assets/icons/11/11.png",
        color: 0xFFFF7F50,
      ),
      Character(
        title: DemoLocalizations.of(context).assistantName21,
        description: DemoLocalizations.of(context).assistantDesc21,
        avatar: "assets/icons/11/12.png",
        color: 0xFF6495ED,
      ),
    ];
  }

  void initPlayerCharacters() {
    playerCharacters = <Character>[
      Character(
        title: DemoLocalizations.of(context).playerName1,
        description: DemoLocalizations.of(context).playerDesc1,
        avatar: "assets/icons/2/2_0.png",
        color: 0xFF86A1F2,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName2,
        description: DemoLocalizations.of(context).playerDesc2,
        avatar: "assets/icons/2/2_1.png",
        color: 0xFFB6E3D4,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName3,
        description: DemoLocalizations.of(context).playerDesc3,
        avatar: "assets/icons/2/2_2.png",
        color: 0xFFD4A7B9,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName4,
        description: DemoLocalizations.of(context).playerDesc4,
        avatar: "assets/icons/2/2_3.png",
        color: 0xFF9CD1A8,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName5,
        description: DemoLocalizations.of(context).playerDesc5,
        avatar: "assets/icons/2/2_4.png",
        color: 0xFF97A4C3,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName6,
        description: DemoLocalizations.of(context).playerDesc6,
        avatar: "assets/icons/2/2_5.png",
        color: 0xFFE9B2CF,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName7,
        description: DemoLocalizations.of(context).playerDesc7,
        avatar: "assets/icons/2/2_6.png",
        color: 0xFFADC7E8,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName8,
        description: DemoLocalizations.of(context).playerDesc8,
        avatar: "assets/icons/2/2_7.png",
        color: 0xFFBBEE9F,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName9,
        description: DemoLocalizations.of(context).playerDesc9,
        avatar: "assets/icons/2/2_8.png",
        color: 0xFF8FABC1,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName10,
        description: DemoLocalizations.of(context).playerDesc10,
        avatar: "assets/icons/3/2.png",
        color: 0xFFE4C1D9,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName11,
        description: DemoLocalizations.of(context).playerDesc11,
        avatar: "assets/icons/3/3.png",
        color: 0xFF74D5E1,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName12,
        description: DemoLocalizations.of(context).playerDesc12,
        avatar: "assets/icons/3/6.png",
        color: 0xFFA9F1B6,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName13,
        description: DemoLocalizations.of(context).playerDesc13,
        avatar: "assets/icons/3/12.png",
        color: 0xFFD9B7A3,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName14,
        description: DemoLocalizations.of(context).playerDesc14,
        avatar: "assets/icons/3/16.png",
        color: 0xFF85C5A1,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName15,
        description: DemoLocalizations.of(context).playerDesc15,
        avatar: "assets/icons/4/4.png",
        color: 0xFF98B6DD,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName16,
        description: DemoLocalizations.of(context).playerDesc16,
        avatar: "assets/icons/4/14.png",
        color: 0xFFD3A9F4,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName17,
        description: DemoLocalizations.of(context).playerDesc17,
        avatar: "assets/icons/14/2.png",
        color: 0xFF9EE7AB,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName18,
        description: DemoLocalizations.of(context).playerDesc18,
        avatar: "assets/icons/14/5.png",
        color: 0xFFC5D1FA,
      ),
      Character(
        title: DemoLocalizations.of(context).playerName19,
        description: DemoLocalizations.of(context).playerDesc19,
        avatar: "assets/icons/14/9.png",
        color: 0xFFB0A8EF,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    String name = DemoLocalizations.of(context).subscriptionBtn;
    final subProvider = Provider.of<KerasSubscriptionProvider>(context);
    Color subTextColor = Colors.white;
    Color subBkColor = Colors.green;
    if(subProvider.isFreeSubscriptionStatus()) {
      subBkColor = Colors.redAccent;
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8), // Adjust padding as needed
                  decoration: BoxDecoration(
                    color: subBkColor,
                    borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                  ),
                  child: Text(
                    subProvider.getSubscriptionStatus(),
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 16, // Adjust font size as needed
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Add spacing between "Play" and other widgets
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                await subscriptionScreen();
                setState(() {
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.subscriptions,
                      semanticLabel: 'subscriptions',
                    ),
                    onPressed: () async {
                      await subscriptionScreen();
                      setState(() {
                      });
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                semanticLabel: 'settings',
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingScreen(assistantCharacters: assistantCharacters, playerCharacters: playerCharacters,)),
                );
              },
            ),
          ],
        ),
      ),
      body: ChatUI(assistantCharacters: assistantCharacters, playerCharacters: playerCharacters,),
    );
  }
}

class ChatUI extends StatefulWidget {
  List<Character> assistantCharacters = [];
  List<Character> playerCharacters = [];

  ChatUI({super.key, required this.assistantCharacters, required this.playerCharacters});

  @override
  ChatUIState createState() => ChatUIState();
}

class ChatUIState extends State<ChatUI> {
  LlmModel? llmModel;
  KerasAuthProvider? authProvider;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  bool toolBoxEnable = false;
  String loadModelName = "";
  String wallpaperPath = "";
  List<String> fileUploadList = [];
  Map<int, dynamic> internalMessageList = {};
  Map<int, dynamic> extendMessageList = {};
  Map<int, Map<String, dynamic>> speechMessageList = {};
  String roleIconPath = '';
  String playerIconPath = '';
  bool speechEnable = false;
  bool freeTrialExpired = false;
  SubscriptionStatus subStatus = SubscriptionStatus.free;
  final record = AudioRecorder();
  String recordPath = "";
  bool isRecording = false;
  Timer? timer;
  int silenceDuration = 0;
  double bubbleSize = 200.0;

  String getSystemInstruction(String role) {

    Character character = findCharacterByTitle(role);
    String description = character.description ?? "";
    String dot = ".";
    String printLog = DemoLocalizations.of(context).promptSysInstruction2;
    logger.i("promptSysInstruction2: $printLog");
    return DemoLocalizations.of(context).promptSysInstruction1 + role + dot + DemoLocalizations.of(context).promptSysInstruction2 + description;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    authProvider = Provider.of<KerasAuthProvider>(context);
    initModel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void initModel() {
    final subProvider = Provider.of<KerasSubscriptionProvider>(context);
    bool permissionCheck = subProvider.toolboxPermission();
    bool normalSpeechCheck = subProvider.normalSpeechPermission();
    bool advancedSpeechCheck = subProvider.advancedSpeechPermission();
    bool baseModelCheck = subProvider.baseModelPermission();
    bool advancedModelCheck = subProvider.powerModelPermission();
    loadModelName = Provider.of<SettingProvider>(context, listen: false).modelName;
    String role = Provider.of<SettingProvider>(context, listen: false).currentRole;
    toolBoxEnable = permissionCheck == true ? Provider.of<SettingProvider>(context, listen: false).toolBoxEnable : permissionCheck;
    toolBoxEnable = osType != OsType.android ? false : toolBoxEnable;
    Locale locale = Localizations.localeOf(context);
    String language = Provider.of<SettingProvider>(context, listen: false).language;
    if(toolBoxEnable) {
      toolBoxEnable = restrictionInformation.isToolboxRestriction() ? false : toolBoxEnable;
    }
    if(normalSpeechCheck) {
      ttsProviderInstance!.switchProvider(VoiceProvider.google, null);
    }
    else if(advancedSpeechCheck) {
      ttsProviderInstance!.switchProvider(VoiceProvider.microsoft, null);
    }
    ttsProviderInstance!.initCurrentSpeech(locale, language);
    String systemInstruction = getSystemInstruction(role);
    if(baseModelCheck || advancedModelCheck) {
      if(llmModel != null) {
        if(llmModel!.name != loadModelName ||
          llmModel!.systemInstruction != systemInstruction ||
          llmModel!.toolEnable != toolBoxEnable) {
          llmModel = initLlmModel(loadModelName, systemInstruction, toolBoxEnable);
        }
      } else {
        llmModel = initLlmModel(loadModelName, systemInstruction, toolBoxEnable);
      }
    }
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

  double calculateBubbleSize(double data) {
    double newData = 200.0 + data * 10.0;
    if(newData < 30.0) {
      newData = 30.0;
    } else if(newData > 250.0) {
      newData = 250.0;
    }
    return newData;
  }

  Future<void> startRecording() async {
    if(recordPath.isNotEmpty) {
      return;
    }
    try {
      if (await record.hasPermission()) {
        final directory = await getTempPath();
        // Create a unique file name.
        recordPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await record.start(
          const RecordConfig(),
          path: recordPath,
        );
        setState(() {
          isRecording = true;
        });
        startMonitoring();
      }
    } catch (e, stackTrace) {
      logger.e("startRecording crash: ", stackTrace: stackTrace);
    }
  }

  Future<void> stopRecording() async {
    if(timer != null) {
      try {
        timer!.cancel();
        final path = await record.stop();
        setState(() {
          _loading = true;
          isRecording = false;
          silenceDuration = 0;
        });
        logger.i('Recorded file path: $path');
        io.File audioFile = io.File(recordPath);
        DeepgramSttResult res = await deepgram!.transcribeFromFile(audioFile); // or transcribeFromPath() if you prefer
        String message = res.transcript;
        logger.i("message: $message");
        recordPath = '';
        if(message.isNotEmpty) {
          _textController.text = message;
          await _sendChatMessage(_textController.text);
        }
        else {
          setState(() {
            _loading = false;
          });
        }
      } catch (e, stackTrace) {
        logger.e("stopRecording crash: $e", stackTrace: stackTrace);
      }
    }
  }
  void startMonitoring() {
    try {
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        Amplitude amplitude = await record.getAmplitude();
        if (amplitude.current > -30.0) {
          silenceDuration = 0;
        } else {
          silenceDuration += 1;
        }

        double newBubbleSize = calculateBubbleSize(amplitude.current + 40.0);
        setState(() {
          bubbleSize = newBubbleSize;
        });

        if (silenceDuration >= 20) {
          await stopRecording();
        }
      });
    } catch (e, stackTrace) {
      logger.e("startMonitoring crash: ", stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = llmModel?.getHistory() ?? [];
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<SettingProvider>(
      builder: (context, settingProvider, _) {
        String roleIconPath = settingProvider.roleIconPath;
        String playerIconPath = settingProvider.playerIconPath;
        String wallpaperPath = settingProvider.chatpageWallpaperPath;
        final subProvider = Provider.of<KerasSubscriptionProvider>(context);
        if(authProvider != null && !subProvider.checkFreeTrial(authProvider!.getFirstCreateDate())) {
          freeTrialExpired = true;
        } else {
          freeTrialExpired = false;
        }
        bool permissionCheck = subProvider.speechPermission();
        speechEnable = permissionCheck == true ? settingProvider.speechEnable : permissionCheck;
        if(speechEnable) {
          speechEnable = restrictionInformation.isSpeechRestriction() ? false : speechEnable;
        }
        if(loadModelName != settingProvider.modelName ||
           toolBoxEnable != settingProvider.toolBoxEnable) {
          initModel();
        }
        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: wallpaperPath.isNotEmpty
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(wallpaperPath),
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            final rule = history[index];
                            String text = rule['content'];
                            if (text.isEmpty) {
                              return const SizedBox.shrink();
                            } else {
                              if(rule['role'] == 'system') {
                                return const SizedBox.shrink();
                              }
                              else if (rule['role'] == 'user') {
                                Map<String, dynamic> curExtendMessage = {};
                                if (internalMessageList.containsKey(index)) {
                                  curExtendMessage = internalMessageList[index];
                                }
                                return SentMessageScreen(
                                  message: text,
                                  extendMessage: curExtendMessage,
                                  iconPath: playerIconPath,
                                  onAddFile: addFile,
                                );
                              } else {
                                Map<String, dynamic> audioDict = {};
                                String audioPath = "";
                                bool autoPlay = false;
                                if (speechMessageList.containsKey(index)) {
                                  audioDict = speechMessageList[index] ?? {};
                                  if(audioDict.isNotEmpty) {
                                    audioPath = audioDict['audioPath'];
                                    autoPlay = audioDict['autoPlay'];
                                    audioDict['autoPlay'] = false;
                                  }
                                }
                                Map<String, dynamic> curExtendMessage = {};
                                if (extendMessageList.containsKey(index)) {
                                  curExtendMessage = extendMessageList[index];
                                }
                                return ReceivedMessageScreen(
                                  message: text,
                                  extendMessage: curExtendMessage,
                                  audioPath: audioPath,
                                  autoPlay: autoPlay,
                                  iconPath: roleIconPath,
                                );
                              }
                            }
                          },
                          itemCount: history.length,
                        ),
                      ),
                      if (fileUploadList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: fileUploadList.map((filePath) {
                              return Stack(
                                children: [
                                  Image.file(
                                    io.File(filePath),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 16,
                                      ),
                                      onPressed: () => removeFile(filePath),
                                    ),
                                  ),
                                ],
                              );
                            }
                          ).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 15,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                autofocus: false,
                                focusNode: _textFieldFocus,
                                decoration: textFieldDecoration(),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                controller: _textController,
                                onSubmitted: _sendChatMessage,
                              ),
                            ),
                            if (!_loading) ...{
                              IconButton(
                                onPressed: () async {
                                  _sendChatMessage(_textController.text);
                                },
                                icon: Icon(
                                  Icons.send,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              if (speechEnable && deepgram != null) ...{
                                if(isRecording == false) ...{
                                  if(!freeTrialExpired) ...{
                                    IconButton(
                                      icon: const Icon(Icons.mic),
                                      onPressed: () async {
                                        statisticsInformation.updateVoiceStatistics();
                                        await startRecording();
                                        if(isRecording == false) {
                                          if(recordPath.isNotEmpty) {
                                          }
                                        }
                                      },
                                    ),
                                  },
                                } else ...{
                                  IconButton(
                                    icon: const Icon(Icons.stop),
                                    onPressed: () async {
                                      await stopRecording();
                                    },
                                  ),
                                }
                              },
                            }
                            else
                              const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if(isRecording) ...{
                Center(
                  child: Container(
                    width: bubbleSize,
                    height: bubbleSize,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              }
            ],
          ),
        );
      },
    );
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;

      setState(() {
        for(PlatformFile file in files) {
          String path = file.path ?? "";
          if(path.isNotEmpty) {
            if(!fileUploadList.contains(path)) {
              fileUploadList.add(path);
            }
          }
        }
      });
    } else {
      
    }
  }

  void removeFile(String filePath) {
    setState(() {
      fileUploadList.remove(filePath);
    });
  }

  void addFile(String filePath) {
    if(!fileUploadList.contains(filePath)) {
      setState(() {
        fileUploadList.add(filePath);
      });
    }
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: DemoLocalizations.of(context).textInputPrompt,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      prefixIcon: IconButton(
        icon: const Icon(Icons.attach_file),
        onPressed: pickFile,
      ),
      suffixIcon: IconButton(
        icon: const Icon(Icons.camera_alt),
        onPressed: () async {
          if(cameras.isNotEmpty) {
            final CameraDescription firstCamera = cameras.first;
            try {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TakePictureScreen(
                    camera: firstCamera,
                  ),
                ),
              );
              if (result != null && result.isNotEmpty) {
                setState(() {
                  fileUploadList.addAll(result);
                });
              }
            } catch (e, stackTrace) {
              logger.e("TakePictureScreen crash: ", stackTrace: stackTrace);
            }
          }
        },
      ),
    );
  }

  Future<void> _sendChatMessage(String message,) async {
    if(freeTrialExpired || restrictionInformation.isConversationRestriction()) {
      String title = freeTrialExpired ? DemoLocalizations.of(context).expiredTitle : 'Restriction!';
      String warning = freeTrialExpired ? DemoLocalizations.of(context).freeTrialWarning: 'Reached the conversation restriction!';
      logger.w('Free trial has expired!');
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.yellowAccent[50],
            title: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              warning,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  DemoLocalizations.of(context).okBtn,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      Uint8List bytesUint8;
      Map<String, dynamic> curExtendMessage = {};
      if(message.isNotEmpty) {
        if(llmModel != null) {
          dynamic response;
          var history = llmModel!.getHistory();
          if(llmModel!.type == ModelType.google) {
            List<gemini.DataPart> imageParts = [];
            if(!restrictionInformation.isImageRestriction()) {
              for (String filePath in fileUploadList) {
                io.File file = io.File(filePath);
                if (await file.exists()) {
                  bytesUint8 = await file.readAsBytes().then((value) => value);
                  img.Image image = img.decodeImage(bytesUint8)!;
                  img.Image resizedImage = img.copyResize(image, width: 400, height: 500);
                  List<int> compressedBytes = img.encodeJpg(resizedImage);
                  imageParts.add(gemini.DataPart('image/jpeg', Uint8List.fromList(compressedBytes)));
                  statisticsInformation.updateImageStatistics();
                }
              }
            } else {
              if(fileUploadList.isNotEmpty) {
                GFToast.showToast(
                  'Reached the image restriction!',
                  context,
                  toastPosition: GFToastPosition.TOP,
                  textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                  backgroundColor: GFColors.WARNING,
                  trailing: const Icon(
                    Icons.error,
                    color: GFColors.DANGER,
                  )
                );
              }
            }
            final textPrompt = gemini.TextPart(message);
            
            response = await llmModel!.chatSession.sendMessage(
              gemini.Content.multi([textPrompt, ...imageParts]),
            );
            
            final functionCalls = response.functionCalls.toList();
            if (functionCalls.isNotEmpty) {
              final functionCall = functionCalls.first;
              final result = switch (functionCall.name) {
                // Forward arguments to the hypothetical API.
                'getCurrentTime' => await getCurrentTime(),
                'getCurrentLocation' => await getCurrentLocation(),
                'getDirections' => await getDirections(functionCall.args),
                'getPlaces' => await getPlaces(functionCall.args),
                'searchVideos' => await searchVideos(functionCall.args),
                'searchInternet' => await searchInternet(functionCall.args),
                'searchEmails' => await searchEmails(functionCall.args),
                'sendEmails' => await sendEmails(functionCall.args),
                'searchDrives' => await searchDrives(functionCall.args),
                'downloadFromDrives' => await downloadFromDrives(functionCall.args),
                'getEventCalendar' => await getEventCalendar(functionCall.args),
                'createEventCalendar' => await createEventCalendar(functionCall.args),
                'searchPhotos' => await searchPhotos(functionCall.args),
                // Throw an exception if the model attempted to call a function that was
                // not declared.
                _ => throw UnimplementedError(
                    'Function not implemented: ${functionCall.name}')
              };
              if(result.isNotEmpty) {
                String resultValue = result['result'];
                if(result.containsKey('show_map')) {
                  curExtendMessage = {'show_map': result['show_map']};
                }
                else if (result.containsKey('show_video')) {
                  curExtendMessage = {'show_video': result['show_video']};
                }
                else if (result.containsKey('show_image')) {
                  curExtendMessage = {'show_image': result['show_image']};
                }
                Map<String, dynamic> responseFunction = {'result': resultValue};
                // Send the result of the function call to the model.
                statisticsInformation.updateChatStatistics();
                response = await llmModel!.chatSession.sendMessage(gemini.Content.functionResponse(functionCall.name, responseFunction));
              }
              // Send the response to the model so that it can use the result to generate
              // text for the user.
            }
            history = llmModel!.getHistory();
          }
          else {
            String text = "";
            List<Map<String, dynamic>> imageList = [];
            if(!restrictionInformation.isImageRestriction()) {
              for (String filePath in fileUploadList) {
                io.File file = io.File(filePath);
                if (await file.exists()) {
                  bytesUint8 = await file.readAsBytes().then((value) => value);
                  img.Image image = img.decodeImage(bytesUint8)!;
                  img.Image resizedImage = img.copyResize(image, width: 400, height: 500);
                  List<int> compressedBytes = img.encodeJpg(resizedImage);
                  String base64Data = base64Encode(compressedBytes);
                  Map<String, dynamic> imageUrlMap = {
                    "type": "image_url",
                    "image_url": {
                      "url": "data:image/jpeg;base64,$base64Data",
                    },
                  };
                  imageList.add(imageUrlMap);
                  statisticsInformation.updateImageStatistics();
                }
              }
            } else {
              if(fileUploadList.isNotEmpty) {
                GFToast.showToast(
                  'Reached the image restriction!',
                  context,
                  toastPosition: GFToastPosition.TOP,
                  textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                  backgroundColor: GFColors.WARNING,
                  trailing: const Icon(
                    Icons.error,
                    color: GFColors.DANGER,
                  )
                );
              }
            }
            List<Map<String, dynamic>> newHistory = history.cast<Map<String, dynamic>>().toList();
            Map<String, dynamic> query = openai.Messages(role: openai.Role.user, content: message).toJson();
            Map<String, dynamic> newQuery = {};
            if(imageList.isEmpty) {
              newQuery = query;
            }
            else {
              if(llmModel!.name == openai.kChatGptTurboModel) {
                newQuery = query;
                GFToast.showToast(
                  DemoLocalizations.of(context).nonSupportVision,
                  context,
                  toastPosition: GFToastPosition.TOP,
                  textStyle: const TextStyle(fontSize: 12, color: GFColors.DARK),
                  backgroundColor: GFColors.WARNING,
                  trailing: const Icon(
                    Icons.error,
                    color: GFColors.DANGER,
                  )
                );
              } else {
                imageList.insert(0, {"type": "text", "text": message});
                newQuery = {
                  "role": "user",
                  "content": imageList,
                };
              }
            }
            newHistory.add(newQuery);
            if(toolBoxEnable) {
              var request = openai.ChatCompleteText(
                model: llmModel!.model,
                messages: newHistory,
                maxToken: maxTokenLength,
                tools: functionCallToolOpenai,
                toolChoice: 'auto',
              );
              openai.ChatCTResponse? chatResponse = await openAIInstance!.onChatCompletion(request: request);
              if(chatResponse != null && chatResponse.choices.isNotEmpty) {
                for (var element in chatResponse.choices) {
                  if(element.message != null) {
                    if(element.message!.toolCalls != null && element.message!.toolCalls!.isNotEmpty) {
                      for (var toolCall in element.message!.toolCalls!) {
                        String toolId = toolCall['id'];
                        //String toolType = toolCall['type'];
                        Map<String, dynamic> functionCall = toolCall['function'];
                        String funcName = functionCall['name'];
                        String arg = functionCall['arguments'];
                        Map<String, dynamic> arguments = json.decode(arg);
                        final result = switch (funcName) {
                          // Forward arguments to the hypothetical API.
                          'getCurrentTime' => await getCurrentTime(),
                          'getCurrentLocation' => await getCurrentLocation(),
                          'getDirections' => await getDirections(arguments),
                          'getPlaces' => await getPlaces(arguments),
                          'searchVideos' => await searchVideos(arguments),
                          'searchInternet' => await searchInternet(arguments),
                          'searchEmails' => await searchEmails(arguments),
                          'sendEmails' => await sendEmails(arguments),
                          'searchDrives' => await searchDrives(arguments),
                          'downloadFromDrives' => await downloadFromDrives(arguments),
                          'getEventCalendar' => await getEventCalendar(arguments),
                          'createEventCalendar' => await createEventCalendar(arguments),
                          'searchPhotos' => await searchPhotos(arguments),
                          // Throw an exception if the model attempted to call a function that was
                          // not declared.
                          _ => throw UnimplementedError(
                              'Function not implemented: ${functionCall['name']}')
                        };
                        if(result.isNotEmpty) {
                          String resultValue = result['result'];
                          if(result.containsKey('show_map')) {
                            curExtendMessage = {'show_map': result['show_map']};
                          }
                          else if (result.containsKey('show_video')) {
                            curExtendMessage = {'show_video': result['show_video']};
                          }
                          else if (result.containsKey('show_image')) {
                            curExtendMessage = {'show_image': result['show_image']};
                          }
                          // Send the result of the function call to the model.
                          final query = {"role": 'function', "tool_call_id": toolId, "name": funcName, "content": resultValue};
                          newHistory.add(query);
                          //response = await llmModel!.chatSession.sendMessage(gemini.Content.functionResponse(functionCall.name, responseFunction));
                        }
                        // Send the response to the model so that it can use the result to generate
                        var request = openai.ChatCompleteText(
                          model: llmModel!.model,
                          messages: newHistory,
                          maxToken: maxTokenLength,
                        );
                        statisticsInformation.updateChatStatistics();
                        openai.ChatCTResponse? chatResponse = await openAIInstance!.onChatCompletion(request: request);
                        if(chatResponse != null && chatResponse.choices.isNotEmpty) {
                          for (var element in chatResponse.choices) {
                            if(element.message != null) {
                              text += element.message!.content;
                            }
                          }
                        }
                        // text for the user.                 
                      }
                    } else if (element.message!.content.isNotEmpty) {
                      text += element.message!.content;
                    }
                  }
                }
              }
            } else {
              var request = openai.ChatCompleteText(
                model: llmModel!.model,
                messages: newHistory,
                maxToken: maxTokenLength,
              );
              openai.ChatCTResponse? chatResponse = await openAIInstance!.onChatCompletion(request: request);
              if(chatResponse != null && chatResponse.choices.isNotEmpty) {
                for (var element in chatResponse.choices) {
                  if(element.message != null) {
                    text += element.message!.content;
                  }
                }
              }
            }
            if(text.isEmpty) {
              text = "There was no response from the model.";
            }
            response = OpenAIMessage(text:text);
            final answer = openai.Messages(role: openai.Role.assistant, content: text).toJson();
            llmModel!.chatSession.history.add(query);
            llmModel!.chatSession.history.add(answer);
            history = llmModel!.getHistory();
          }
          // When the model responds with non-null text content, print it.
          if (response.text case final text?) {
            statisticsInformation.updateChatStatistics();
            if(toolBoxEnable) {
              statisticsInformation.updateToolBoxStatistics();
            }
            if(!restrictionInformation.isImageRestriction()) {
              if (fileUploadList.isNotEmpty && history.isNotEmpty) {
                List<Map<String, String>> photosList = fileUploadList.map((path) => {"imgpath": path}).toList();
                Map<String, dynamic> curInternalMessage = {
                  'show_image': {
                    'object': "images",
                    'images': photosList,
                  }
                };
                int index = history.length - 2;
                internalMessageList[index] = curInternalMessage;
                fileUploadList = [];
              }
            }
            if (curExtendMessage.isNotEmpty && history.isNotEmpty) {
              int index = history.length - 1;
              extendMessageList[index] = curExtendMessage;
            }
            if(speechEnable && history.isNotEmpty) {
              String? audioPath = await ttsProviderInstance!.generateAudioFile(response.text!);
              if(audioPath != null) {
                statisticsInformation.updateSpeechStatistics();
                int index = history.length - 1;
                speechMessageList[index] = {
                  'audioPath': audioPath,
                  'autoPlay': true,
                };
              }
            }
            if(text.isEmpty) {
              _showError('No response from API.');
              return;
            } else {
              setState(() {
                _loading = false;
                _scrollDown();
              });
            }
          }
        }
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      //_textFieldFocus.requestFocus();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(DemoLocalizations.of(context).titleShowError),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(DemoLocalizations.of(context).okBtn),
            )
          ],
        );
      },
    );
  }
}