import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:record/record.dart';
import 'l10n/localization_intl.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:keras_mobile_chatbot/function_call.dart';
import 'package:keras_mobile_chatbot/chat_bubble.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:keras_mobile_chatbot/setting_page.dart';
import 'package:keras_mobile_chatbot/takepicture_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';

class ChatHome extends StatelessWidget {
  const ChatHome({super.key});

  @override
  Widget build(BuildContext context) {
    String name = Provider.of<SettingProvider>(context, listen: false).modelName;
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontSize: 25)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              semanticLabel: 'settings',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: ChatUI(),
    );
  }
}

class ChatUI extends StatefulWidget {
  @override
  _ChatUIState createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  late GenerativeModel? _model;
  late ChatSession _chatSession;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  String wallpaperPath = "";
  List<String> fileUploadList = [];
  Map<int, dynamic> internalMessageList = {};
  Map<int, dynamic> extendMessageList = {};
  Map<int, Map<String, dynamic>> speechMessageList = {};
  String roleIconPath = '';
  String playerIconPath = '';
  bool speechEnable = false;
  final record = AudioRecorder();
  String recordPath = "";
  bool isRecording = false;
  Timer? timer;
  int silenceDuration = 0;
  double bubbleSize = 200.0;
  List<Character> assistantCharacters = [];
  List<Character> playerCharacters = [];


  String getSystemInstruction(String role) {

    Character character = findCharacterByTitle(role);
    String description = character.description ?? "";
    
    String dot = ".";
    String printLog = DemoLocalizations.of(context).promptSysInstruction2;
    print("promptSysInstruction2: $printLog");
    return DemoLocalizations.of(context).promptSysInstruction1 + role + dot + DemoLocalizations.of(context).promptSysInstruction2 + description;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToolConfig toolConfig = ToolConfig(functionCallingConfig: FunctionCallingConfig(mode: FunctionCallingMode.auto));
    String name = Provider.of<SettingProvider>(context, listen: false).modelName;
    String role = Provider.of<SettingProvider>(context, listen: false).currentRole;
    initAssistantCharacters();
    initPlayerCharacters();
    initCurrentSpeech();
    String newSystemInstruction = getSystemInstruction(role);
    //if(_model == null) {
      _model = GenerativeModel(
        model: name,
        apiKey: dotenv.get("api_key"),
        tools: [
          Tool(functionDeclarations: normalFunctionCallTool)
        ],
        toolConfig: toolConfig,
        systemInstruction: Content.system(newSystemInstruction),
      );
      _chatSession = _model!.startChat();
    //}
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void initCurrentSpeech() {
    String roleSpeech = "en-US-AnaNeural";
    Locale currentLocale = Localizations.localeOf(context);
    if (currentLocale.languageCode == 'en') {
      if(currentLocale.countryCode == 'GB') {
        roleSpeech = "en-GB-MaisieNeural";
      }
    } else if(currentLocale.languageCode == "zh") {
      roleSpeech = "zh-CN-XiaoyouNeural";
    } else if(currentLocale.languageCode == "de") {
      roleSpeech = "de-DE-GiselaNeural";
    } else if(currentLocale.languageCode == "fr") {
      roleSpeech = "fr-FR-EloiseNeural";
    }

    if(voicesList.isNotEmpty) {
      VoiceUniversal? foundVoice;
      for (int i = 0; i < voicesList.length; i++) {
        if (voicesList[i].code == roleSpeech) {
          foundVoice = voicesList[i];
          break;
        }
      }
      roleVoice = foundVoice;
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

  Character findCharacterByTitle(String title) {
    Character character = Character();

    for (var char in assistantCharacters) {
      if (char.title == title) {
        character = char;
        break;
      }
    }
    
    return character;
  }

  Character findCharacterByAvatar(String avatar) {
    Character character = Character();

    for (var char in assistantCharacters) {
      if (char.avatar == avatar) {
        character = char;
        break;
      }
    }
    
    return character;
  }

  double calculateBubbleSize(dynamic data) {

    dynamic newData = 200.0 + data * 10.0;
    if(newData < 30.0) {
      newData = 30.0;
    } else if(newData > 250.0) {
      newData = 250;
    }
    return newData;
  }

  Future<void> startRecording() async {
    if(recordPath.isNotEmpty) {
      return;
    }
    if (await record.hasPermission()) {
      final directory = await getTemporaryDirectory();
      // Create a unique file name.
      recordPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      await record.start(
        const RecordConfig(),
        path: recordPath,
      );
      setState(() {
        isRecording = true;
      });
      startMonitoring();
    }
  }

  Future<void> stopRecording() async {
    if(timer != null) {
      timer?.cancel();
      final path = await record.stop();
      setState(() {
        isRecording = false;
        silenceDuration = 0;
      });
      print('Recorded file path: $path');
      io.File audioFile = io.File(recordPath);
      DeepgramSttResult res = await deepgram!.transcribeFromFile(audioFile); // or transcribeFromPath() if you prefer
      String message = res.transcript;
      print("message: $message");
      recordPath = '';
      if(message.isNotEmpty) {
        _textController.text = message;
        _sendChatMessage(_textController.text);
      }
    }
  }

  void startMonitoring() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      Amplitude amplitude = await record.getAmplitude();
      if (amplitude.current > -30.0) {
        silenceDuration = 0;
        double current = amplitude.current;
        print("current1: $current");
      } else {
        silenceDuration += 1;
        double current = amplitude.current;
        print("current2: $current");
      }

      double newBubbleSize = calculateBubbleSize(amplitude.current + 40.0);
      setState(() {
        bubbleSize = newBubbleSize;
      });

      if (silenceDuration >= 20) {
        await stopRecording();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = _chatSession.history.toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<SettingProvider>(
      builder: (context, settingProvider, _) {
        String roleIconPath = settingProvider.roleIconPath;
        String playerIconPath = settingProvider.playerIconPath;
        String wallpaperPath = settingProvider.chatpageWallpaperPath;
        speechEnable = settingProvider.speechEnable;

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
                            final content = history[index];
                            final text = content.parts
                                .whereType<TextPart>()
                                .map<String>((e) => e.text)
                                .join('');
                            if (text.isEmpty) {
                              return const SizedBox.shrink();
                            } else {
                              if (content.role == 'user') {
                                Map<String, dynamic> curExtendMessage = {};
                                if (internalMessageList.containsKey(index)) {
                                  curExtendMessage = internalMessageList[index];
                                }
                                return SentMessageScreen(
                                  message: text,
                                  extendMessage: curExtendMessage,
                                  iconPath: playerIconPath,
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
                              if (deepgram != null) ...{
                                if(isRecording == false) ...{
                                  IconButton(
                                    icon: const Icon(Icons.mic),
                                    onPressed: () async {                                  
                                      await startRecording();
                                      if(isRecording == false) {
                                        print(recordPath);
                                        if(recordPath.isNotEmpty) {
                                          
                                        }
                                      }
                                    },
                                  ),
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
            fileUploadList.add(path);
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
            } catch (e) {
              print(e);
            }
          }
        },
      ),
    );
  }

  Future<void> _sendChatMessage(String message,) async {
    setState(() {
      _loading = true;
    });
    try {
      Uint8List bytesUint8;
      List<DataPart> imageParts = [];
      if(message.isNotEmpty) {
        for (String filePath in fileUploadList) {
          io.File file = io.File(filePath);
          if (await file.exists()) {
            bytesUint8 = await file.readAsBytes().then((value) => value);
            imageParts.add(DataPart('image/jpeg', bytesUint8));
          }
        }
        final textPrompt = TextPart(message);
        
        var response = await _chatSession.sendMessage(
          Content.multi([textPrompt, ...imageParts]),
        );
        Map<String, dynamic> curExtendMessage = {};
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
            response = await _chatSession.sendMessage(Content.functionResponse(functionCall.name, responseFunction));
          }
          // Send the response to the model so that it can use the result to generate
          // text for the user.
        }
        // When the model responds with non-null text content, print it.
        if (response.text case final text?) {
          if (fileUploadList.isNotEmpty && _chatSession.history.isNotEmpty) {
            List<Map<String, String>> photosList = fileUploadList.map((path) => {"imgpath": path}).toList();
            Map<String, dynamic> curInternalMessage = {
              'show_image': {
                'object': "images",
                'images': photosList,
              }
            };
            int index = _chatSession.history.length - 2;
            internalMessageList[index] = curInternalMessage;
          }
          if (curExtendMessage.isNotEmpty && _chatSession.history.isNotEmpty) {
            int index = _chatSession.history.length - 1;
            extendMessageList[index] = curExtendMessage;
          }
          if(speechEnable && _chatSession.history.isNotEmpty) {
            String? audioPath = await generateAudioFile(response.text!);
            if(audioPath != null) {
              int index = _chatSession.history.length - 1;
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

  Future<String?> generateAudioFile(String message) async {
    if (roleVoice != null) {
      TtsParamsUniversal params = TtsParamsUniversal(
        voice: roleVoice!,
        audioFormatGoogle: AudioOutputFormatGoogle.mp3,
        audioFormatMicrosoft: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
        text: message,
        rate: 'default', // optional
        pitch: 'default' // optional
      );

      final ttsResponse = await TtsUniversal.convertTts(params);

      // Get the audio bytes.
      final audioBytes = ttsResponse.audio.buffer.asByteData().buffer.asUint8List();

      // Get the temporary directory of the app.
      final directory = await getTemporaryDirectory();
      
      // Create a unique file name.
      final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

      // Write the audio bytes to the file.
      final file = io.File(filePath);
      await file.writeAsBytes(audioBytes);

      // Return the file path.
      return filePath;
    }
    return null;
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
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}