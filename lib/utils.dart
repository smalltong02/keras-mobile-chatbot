import 'dart:async';
import 'dart:io';
import 'dart:convert';
//import 'package:googleapis/speech/v1.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart' as openai;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keras_mobile_chatbot/function_call.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:qonversion_flutter/qonversion_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keras_mobile_chatbot/google_sign.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:android_id/android_id.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

const int maxTokenLength = 4096;
const int maxReceiveTimeout = 50; // 50 seconds
const int maxConnectTimeout = 30;
const int imageQuality = 80;
const int maxLogginDevices = 3;
const int maxDialogRounds = 5;
const String deleteRequestUrl = "https://github.com/smalltong02/keras-mobile-chatbot/blob/main/assets/docs/delete_request.md";

final List<Map<String, String>> googleDocsTypes = [
  {"application/vnd.google-apps.audio": "audio/wav"},
  {"application/vnd.google-apps.document": "application/pdf"},
  {"application/vnd.google-apps.drive-sdk": ""},
  {"application/vnd.google-apps.drawing": "image/bmp"},
  {"application/vnd.google-apps.file": "application/octet-stream"},
  {"application/vnd.google-apps.folder": ""},
  {"application/vnd.google-apps.form": "application/vnd.ms-excel"},
  {"application/vnd.google-apps.fusiontable": ""},
  {"application/vnd.google-apps.jam": ""},
  {"application/vnd.google-apps.mail-layout": ""},
  {"application/vnd.google-apps.map": ""},
  {"application/vnd.google-apps.photo": "image/jpeg"},
  {"application/vnd.google-apps.presentation": "application/pdf"},
  {"application/vnd.google-apps.script": ""},
  {"application/vnd.google-apps.shortcut": ""},
  {"application/vnd.google-apps.site": ""},
  {"application/vnd.google-apps.spreadsheet": ""},
  {"application/vnd.google-apps.unknown": ""},
  {"application/vnd.google-apps.video": "video/mp4"},
];

final List<String> wallpaperSettingPaths = [
    'assets/backgrounds/1.jpg',
    'assets/backgrounds/2.jpg',
    'assets/backgrounds/3.jpg',
    'assets/backgrounds/4.jpg',
    'assets/backgrounds/5.jpg',
    'assets/backgrounds/6.jpg',
    'assets/backgrounds/7.jpg',
    'assets/backgrounds/8.jpg',
    'assets/backgrounds/9.jpg',
    'assets/backgrounds/10.jpg',
    'assets/backgrounds/11.jpg',
    'assets/backgrounds/12.jpg',
    'assets/backgrounds/13.jpg',
    'assets/backgrounds/14.jpg',
    'assets/backgrounds/15.jpg',
    'assets/backgrounds/16.jpg',
    'assets/backgrounds/17.jpg',
    'assets/backgrounds/18.jpg',
    'assets/backgrounds/19.jpg',
    'assets/backgrounds/20.jpg',
    'assets/backgrounds/21.jpg',
    'assets/backgrounds/22.jpg',
    'assets/backgrounds/23.jpg',
    'assets/backgrounds/24.jpg',
    'assets/backgrounds/25.jpg',
    'assets/backgrounds/26.jpg',
    'assets/backgrounds/27.jpg',
    'assets/backgrounds/28.jpg',
    'assets/backgrounds/29.jpg',
    'assets/backgrounds/30.jpg',
    'assets/backgrounds/31.jpg',
    'assets/backgrounds/32.jpg',
    'assets/backgrounds/33.jpg',
    'assets/backgrounds/34.jpg',
    'assets/backgrounds/35.jpg',
    'assets/backgrounds/36.jpg',
    'assets/backgrounds/37.jpg',
    'assets/backgrounds/38.jpg',
    'assets/backgrounds/39.jpg',
    'assets/backgrounds/40.jpg',
    'assets/backgrounds/41.jpg',
    'assets/backgrounds/42.jpg',
    'assets/backgrounds/43.jpg',
    'assets/backgrounds/44.jpg',
    'assets/backgrounds/45.jpg',
    'assets/backgrounds/46.jpg',
    'assets/backgrounds/47.jpg',
    'assets/backgrounds/48.jpg',
    'assets/backgrounds/49.jpg',
    'assets/backgrounds/50.jpg',
    'assets/backgrounds/51.jpg',
    'assets/backgrounds/52.jpg',
    'assets/backgrounds/53.jpg',
    'assets/backgrounds/54.jpg',
    'assets/backgrounds/55.jpg',
    'assets/backgrounds/56.jpg',
    'assets/backgrounds/57.jpg',
    'assets/backgrounds/58.jpg',
    'assets/backgrounds/59.jpg',
    'assets/backgrounds/60.jpg',
    'assets/backgrounds/61.jpg',
    'assets/backgrounds/62.jpg',
    'assets/backgrounds/63.jpg',
    'assets/backgrounds/64.jpg',
    'assets/backgrounds/65.jpg',
    'assets/backgrounds/66.jpg',
    'assets/backgrounds/67.jpg',
    'assets/backgrounds/68.jpg',
    'assets/backgrounds/69.jpg',
    'assets/backgrounds/70.jpg',
    'assets/backgrounds/71.jpg',
    'assets/backgrounds/72.jpg',
    'assets/backgrounds/73.jpg',
    'assets/backgrounds/74.jpg',
    'assets/backgrounds/75.jpg',
    'assets/backgrounds/76.jpg',
    'assets/backgrounds/77.jpg',
    'assets/backgrounds/78.jpg',
  ];

enum ModelType { unknown, google, openai }

final List<String> lowPowerModel = [
  "gemini-1.5-flash",
  'gpt-4o-mini',
];

final List<String> highPowerModel = [
  "gemini-1.5-pro",
  openai.kGpt4o,
];

final List<String> googleModel = [
  "gemini-1.5-flash",
  "gemini-1.5-pro",
];

final List<String> openAIModel = [
  'gpt-4o-mini',
  openai.kGpt4o,
];

openai.OpenAI? openAIInstance;
String uniqueId = "";
final List<String> allModel = lowPowerModel + highPowerModel;

final List<Locale> supportedLocalesInApp = [
  const Locale('en', 'US'),
  const Locale('fr', 'FR'),
  const Locale('zh', 'CN'),
  const Locale('de', 'DE'),
  const Locale('es', 'ES'),
  const Locale('ja', 'JP'),
  const Locale('ko', 'KR'),
  const Locale('ru', 'RU'),
  const Locale('hi', 'IN'),
  const Locale('zh', 'TW'),
  const Locale('yue', 'CN'),
  const Locale('hi', 'IN'),
  const Locale('vi', 'VN'),
];

List<CameraDescription> cameras = [];
Deepgram? deepgram;
TtsProvider? ttsProviderInstance;
KerasStatisticsInformation statisticsInformation = KerasStatisticsInformation();


enum VoiceProvider { microsoft, google, openai, amazon }

class TtsProvider {
  VoiceProvider defaultProvider = VoiceProvider.google;
  VoiceUniversal? roleVoice;
  List<VoiceUniversal>? voices;

  TtsProvider() {
    return;
  }

  String getProviderName() {
    switch(defaultProvider) {
      case VoiceProvider.microsoft:
        return 'microsoft';
      case VoiceProvider.google:
        return 'google';
      case VoiceProvider.openai:
        return 'openai';
      case VoiceProvider.amazon:
        return 'amazon';
      default:
        return 'google';
    }
  }

  String getDefaultVoice() {
    switch(defaultProvider) {
      case VoiceProvider.microsoft:
        return 'en-US-AnaNeural';
      case VoiceProvider.google:
        return 'en-US-Standard-H';
      // case VoiceProvider.openai:
      //   return 'en-US-JennyNeural';
      // case VoiceProvider.amazon:
      //   return 'Joanna';
      default:
        return 'en-US-Standard-H';
    }
  }

  Future<void> switchProvider(VoiceProvider provider, String? roleSpeech) async {
    try {
      if(defaultProvider != provider) {
        defaultProvider = provider;
        TtsUniversal.setProvider(provider: getProviderName());
      }
      if(roleSpeech != null) {
        String speech = roleSpeech!;
        final voicesResponse = await TtsUniversal.getVoices();
        voices = voicesResponse.voices; 
        if(voices!.isNotEmpty) {
          VoiceUniversal? foundVoice;
          for (int i = 0; i < voices!.length; i++) {
            if (voices![i].code == speech) {
              foundVoice = voices![i];
              break;
            }
          }
          roleVoice = foundVoice;
        }
      }
    } catch (e) {
      print('unInitialize failed: $e');
    }
    return;
  }

  Future<void> unInitialize() async {
    try {
      roleVoice = null;
      voices = null;
    } catch (e) {
      print('unInitialize failed: $e');
    }
    return;
  }

  Future<void> initialize() async {
    try {
      TtsUniversal.init(
        provider: getProviderName(),
        google: InitParamsGoogle(apiKey: dotenv.get("search_key")),
        microsoft: InitParamsMicrosoft(subscriptionKey: dotenv.get("azure_speech_key"), region: dotenv.get("azure_speech_region")),
        withLogs: true
      );
      await switchProvider(defaultProvider, getDefaultVoice());
    } catch (e) {
      print('initialize failed: $e');
    }
    return;
  }

  void initCurrentSpeech(Locale currentLocale, String language) {
    String? roleSpeech;
    if (currentLocale.languageCode == 'en') {
      if(currentLocale.countryCode == 'GB') {
        switch(defaultProvider) {
          case VoiceProvider.microsoft:
            roleSpeech = "en-GB-MaisieNeural";
          case VoiceProvider.google:
            roleSpeech = "en-US-Standard-H";
          default:
            roleSpeech = "en-US-Standard-H";
        }
      } else {
        switch(defaultProvider) {
          case VoiceProvider.microsoft:
            roleSpeech = "en-US-AnaNeural";
          case VoiceProvider.google:
            roleSpeech = "en-GB-Standard-A";
          default:
            roleSpeech = "en-GB-Standard-A";
        }
      }
    } else if(currentLocale.languageCode == "zh") {
      if(currentLocale.countryCode == 'TW') {
        if(language == 'yue') {
          switch(defaultProvider) {
            case VoiceProvider.microsoft:
              roleSpeech = "yue-CN-XiaoMinNeural";
            case VoiceProvider.google:
              roleSpeech = "yue-HK-Standard-A";
            default:
              roleSpeech = "yue-HK-Standard-A";
          }
        } else {
          switch(defaultProvider) {
            case VoiceProvider.microsoft:
              roleSpeech = "zh-TW-HsiaoChenNeural";
            case VoiceProvider.google:
              roleSpeech = "cmn-TW-Standard-A";
            default:
              roleSpeech = "cmn-TW-Standard-A";
          }
        }
      }
      else {
        switch(defaultProvider) {
          case VoiceProvider.microsoft:
            roleSpeech = "zh-CN-XiaoyouNeural";
          case VoiceProvider.google:
            roleSpeech = "cmn-CN-Standard-D";
          default:
            roleSpeech = "cmn-CN-Standard-D";
        }
      }
    } else if(currentLocale.languageCode == "de") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "de-DE-GiselaNeural";
        case VoiceProvider.google:
          roleSpeech = "de-DE-Standard-A";
        default:
          roleSpeech = "de-DE-Standard-A";
      }
    } else if(currentLocale.languageCode == "fr") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "fr-FR-EloiseNeural";
        case VoiceProvider.google:
          roleSpeech = "fr-FR-Standard-A";
        default:
          roleSpeech = "fr-FR-Standard-A";
      }
    } else if (currentLocale.languageCode == "es") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "es-ES-AlvaroNeural";
        case VoiceProvider.google:
          roleSpeech = "es-ES-Standard-A";
        default:
          roleSpeech = "es-ES-Standard-A";
      }
    } else if (currentLocale.languageCode == "ja") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "ja-JP-MayuNeural";
        case VoiceProvider.google:
          roleSpeech = "ja-JP-Standard-B";
        default:
          roleSpeech = "ja-JP-Standard-B";
      }
    } else if (currentLocale.languageCode == "ko") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "ko-KR-GookMinNeural";
        case VoiceProvider.google:
          roleSpeech = "ko-KR-Standard-A";
        default:
          roleSpeech = "ko-KR-Standard-A";
      }
    } else if (currentLocale.languageCode == "ru") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "ru-RU-DariyaNeural";
        case VoiceProvider.google:
          roleSpeech = "ru-RU-Standard-C";
        default:
          roleSpeech = "ru-RU-Standard-C";
      }
    } else if (currentLocale.languageCode == "hi") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "hi-IN-SwaraNeural";
        case VoiceProvider.google:
          roleSpeech = "hi-IN-Standard-A";
        default:
          roleSpeech = "hi-IN-Standard-A";
      }
    } else if (currentLocale.languageCode == "vi") {
      switch(defaultProvider) {
        case VoiceProvider.microsoft:
          roleSpeech = "vi-VN-HoaiMyNeural";
        case VoiceProvider.google:
          roleSpeech = "vi-VN-Standard-A";
        default:
          roleSpeech = "vi-VN-Standard-A";
      }
    }

    switchProvider(defaultProvider, roleSpeech);
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
      final file = File(filePath);
      await file.writeAsBytes(audioBytes);

      // Return the file path.
      return filePath;
    }
    return null;
  }
}

void initCameras() async {
  cameras = await availableCameras();
  uniqueId = await const AndroidId().getId() ?? "unknown";
  final config = new QonversionConfigBuilder(
    dotenv.get("qonversion_proj_key"),
    QLaunchMode.subscriptionManagement
  )
  .setEnvironment(QEnvironment.sandbox)
  .enableKidsMode()
  .build();
  Qonversion.initialize(config);

  openAIInstance = openai.OpenAI.instance.build(token: dotenv.get("openai_key"), baseOption: openai.HttpSetup(receiveTimeout: const Duration(seconds: maxReceiveTimeout), connectTimeout: const Duration(seconds: maxConnectTimeout)),enableLog: true);
  ttsProviderInstance = TtsProvider();
  await ttsProviderInstance!.initialize();
  deepgram = Deepgram(dotenv.get("deepgram_speech_key"), baseQueryParams: {
    'model': 'nova-2-general',
    'detect_language': true,
    'filler_words': false,
    'punctuation': true,
      // more options here : https://developers.deepgram.com/reference/listen-file
  });
}

class Character {
  final String? avatar;
  final String? title;
  final String? description;
  final int? color;

  Character({
    this.avatar,
    this.title,
    this.description,
    this.color,
  });
}

class SettingProvider with ChangeNotifier {
  String _modelName = 'gemini-1.5-flash';
  String _userName = '';
  String _password = '';
  String _currentRole = 'Keras Robot';
  String _roleIconPath = 'assets/icons/11/11.png';
  String _playerIconPath = 'assets/icons/14/9.png';
  String _homepageWallpaperPath = 'assets/backgrounds/49.jpg';
  String _chatpageWallpaperPath = 'assets/backgrounds/64.jpg';
  String _language = 'auto';
  bool _speechEnable = false;
  bool _toolBoxEnable = false;
  bool _showPolicy = false;

  String get modelName => _modelName;
  String get userName => _userName;
  String get password => _password;
  String get currentRole => _currentRole;
  String get roleIconPath => _roleIconPath;
  String get playerIconPath => _playerIconPath;
  String get homepageWallpaperPath => _homepageWallpaperPath;
  String get chatpageWallpaperPath => _chatpageWallpaperPath;
  String get language => _language;
  bool get speechEnable => _speechEnable;
  bool get toolBoxEnable => _toolBoxEnable;
  bool get showPolicy => _showPolicy;

  SettingProvider() {
    return;
  }

  Future<void> initialize() async {
    await loadSetting();
  }

  void updateModel(String name) {
    if(name.isNotEmpty) {
      _modelName = name;
      notifyListeners();
      saveSetting();
    }
  }

  void updateUserName(String userName) {
    _userName = userName;
    notifyListeners();
    saveSetting();
  }

  void updatePassword(String password) {
    _password = password;
    notifyListeners();
    saveSetting();
  }

  void updateRole(String? newRole) {
    if(newRole != null) {
      _currentRole = newRole;
      notifyListeners();
      saveSetting();
    }
  }
  void updateRoleIcon(String? newPath) {
    if(newPath != null) {
      _roleIconPath = newPath;
      notifyListeners();
      saveSetting();
    }
  }
  void updatePlayerIcon(String? newPath) {
    if(newPath != null) {
      _playerIconPath = newPath;
      notifyListeners();
      saveSetting();
    }
  }
  void updateWallpaper(String homepageWallpaper, String chatpageWallpaper) {
    _homepageWallpaperPath = homepageWallpaper;
    _chatpageWallpaperPath = chatpageWallpaper;
    notifyListeners();
    saveSetting();
  }

  void updateSpeechEnable(bool enable) {
    _speechEnable = enable;
    notifyListeners();
    saveSetting();
  }

  void updateLanguage(String language) {
    _language = language;
    notifyListeners();
    saveSetting();
  }

  void updateToolBoxEnable(bool enable) {
    _toolBoxEnable = enable;
    notifyListeners();
    saveSetting();
  }

  void updateShowPolicy(bool bShow) {
    _showPolicy = bShow;
    notifyListeners();
    saveSetting();
  }

  Future<void> loadSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     _modelName = prefs.getString('modelName') ?? 'gemini-1.5-flash';
     _userName = prefs.getString('userName') ?? '';
     _password = prefs.getString('password') ?? '';
     _language = prefs.getString('language') ?? 'auto';
    _currentRole = prefs.getString('currentRole') ?? 'Keras Robot';
    _roleIconPath = prefs.getString('roleIconPath') ?? 'assets/icons/11/11.png';
    _playerIconPath = prefs.getString('playerIconPath') ?? 'assets/icons/14/9.png';
    _homepageWallpaperPath = prefs.getString('homepageWallpaperPath') ?? 'assets/backgrounds/49.jpg';
    _chatpageWallpaperPath = prefs.getString('chatpageWallpaperPath') ?? 'assets/backgrounds/64.jpg';
    _speechEnable = prefs.getBool('speechEnable') ?? true;
    _showPolicy = prefs.getBool('showPolicy') ?? true;
    notifyListeners();
  }

  Future<void> saveSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('modelName', _modelName);
    prefs.setString('userName', _userName);
    prefs.setString('password', _password);
    prefs.setString('language', _language);
    prefs.setString('currentRole', _currentRole);
    prefs.setString('roleIconPath', _roleIconPath);
    prefs.setString('playerIconPath', _playerIconPath);
    prefs.setString('homepageWallpaperPath', _homepageWallpaperPath);
    prefs.setString('chatpageWallpaperPath', _chatpageWallpaperPath);
    prefs.setBool('speechEnable', _speechEnable);
    prefs.setBool('showPolicy', _showPolicy);
  }
}

class OpenAIMessage {
  String text;
  OpenAIMessage({required this.text});
}

class OpenaiChatHistory {
  List<Map<String, dynamic>> history;

  OpenaiChatHistory({required this.history});

  // toList method
  List<Map<String, dynamic>> toList() {
    return history;
  }
}

class LlmModel {
  ModelType type;
  String? name;
  String? systemInstruction;
  dynamic model;
  dynamic chatSession;

  LlmModel({
    this.type = ModelType.unknown,
    this.model,
    this.systemInstruction,
    this.name,
    this.chatSession,
  });

  List<dynamic> getHistory() {
    List<Map<String, String>> history = [];
    if(type == ModelType.google && chatSession != null) {
      List<dynamic> listData = chatSession.history.toList();
      for(final content in listData) {
        String text = "";
        if (content != null && content.parts is List) {
          Iterable<gemini.TextPart> textParts = content.parts.whereType<gemini.TextPart>();
          Iterable<String> texts = textParts.map((textPart) => textPart.text);
          text = texts.join('');
          String role = content.role.toString();
          history.add({"role": role, "content": text});
        }
      }
    }
    else if(type == ModelType.openai && chatSession != null) {
      if (openAIInstance == null) {
        return [];
      }
      return chatSession.toList();
    }
    return history;
  }
}

LlmModel? initLlmModel(String modelName, String systemInstruction, bool toolEnable) {
  if(modelName.isEmpty) {
    return null;
  }
  for(final name in googleModel) {
    if(modelName == name) {
      if(toolEnable) {
        gemini.ToolConfig toolConfig = gemini.ToolConfig(functionCallingConfig: gemini.FunctionCallingConfig(mode: gemini.FunctionCallingMode.auto));
        LlmModel llmModel = LlmModel(type: ModelType.google);
        llmModel.name = modelName;
        llmModel.systemInstruction = systemInstruction;
        final model = gemini.GenerativeModel(
          model: name,
          apiKey: dotenv.get("api_key"),
          tools: [
            gemini.Tool(functionDeclarations: normalFunctionCallTool)
          ],
          toolConfig: toolConfig,
          systemInstruction: gemini.Content.system(systemInstruction),
        );
        llmModel.model = model;
        final chatSession = model.startChat();
        llmModel.chatSession = chatSession;
        return llmModel;
      } else {
        LlmModel llmModel = LlmModel(type: ModelType.google);
        llmModel.name = modelName;
        llmModel.systemInstruction = systemInstruction;
        final model = gemini.GenerativeModel(
          model: name,
          apiKey: dotenv.get("api_key"),
          systemInstruction: gemini.Content.system(systemInstruction),
        );
        llmModel.model = model;
        final chatSession = model.startChat();
        llmModel.chatSession = chatSession;
        return llmModel;
      }
    }
  }
  
  if(openAIInstance != null) {
    for(final name in openAIModel) {
      if(modelName == name && name == 'gpt-4o-mini') {
        LlmModel llmModel = LlmModel(type: ModelType.openai);
        llmModel.name = modelName;
        llmModel.systemInstruction = systemInstruction;
        final model = openai.ChatModelFromValue(model: name);
        llmModel.model = model;
        final chatSession = OpenaiChatHistory(history: [openai.Messages(role: openai.Role.system, content: systemInstruction).toJson()]);
        llmModel.chatSession = chatSession;
        return llmModel;
      }
      else if (modelName == name && name == openai.kGpt4o) {
        LlmModel llmModel = LlmModel(type: ModelType.openai);
        llmModel.name = modelName;
        llmModel.systemInstruction = systemInstruction;
        final model = openai.Gpt4OChatModel();
        llmModel.model = model;
        final chatSession = OpenaiChatHistory(history: [openai.Messages(role: openai.Role.system, content: systemInstruction).toJson()]);
        llmModel.chatSession = chatSession;
        return llmModel;
      }
    }
  }
  return null;
}

String _extractValue(String geocode, String key) {
  final regex = RegExp('$key=([^,]+)');
  final match = regex.firstMatch(geocode);
  return match != null ? match.group(1) ?? '' : '';
}

String parseGeocode(String geocode) {
  final streetNumber = _extractValue(geocode, 'streetNumber');
  final streetAddress = _extractValue(geocode, 'streetAddress');
  final city = _extractValue(geocode, 'city');
  final region = _extractValue(geocode, 'region');
  //final postal = _extractValue(geocode, 'postal');
  final countryName = _extractValue(geocode, 'countryName');

  return '$streetNumber $streetAddress $city, $region, $countryName';
}

void launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

Future<String> getTempPath() async {
  final directory = await getTemporaryDirectory();
  return directory.path;
}

Future<String> getDocumentsPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> getDownloadsPath() async {
  try {
    final directory = await getDownloadsDirectory();
    return directory!.path;
  } catch (e) {
    return "";
  }
}

Future<bool> writeTempFile(String tmpFile, String content) async {
  bool bSuccess = false;
  try {
    String tmpFolder = await getTempPath();
    File file = File("$tmpFolder/$tmpFile");
    await file.writeAsString(content);
    bSuccess = true;
  } catch (e) {
    bSuccess = false;
  }
  return bSuccess;
}

Future<String> readTempFile(String tmpFile) async {
  try {
    String tmpFolder = await getTempPath();
    File file = File("$tmpFolder/$tmpFile");
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    return "";
  }
}

Future<String> getFileTempPath(String tmpFile) async {
  final folder = await getTempPath();
  return "$folder/$tmpFile";
}

Future<String> getFileDocumentsPath(String tmpFile) async {
  final folder = await getDocumentsPath();
  return "$folder/$tmpFile";
}

Future<String> getFileDownloadsPath(String tmpFile) async {
  final folder = await getDownloadsPath();
  return "$folder/$tmpFile";
}

Future<DateTime?> convertTimeToRFC3339Time(String timeStr) async {
  if (timeStr.isEmpty) {
    return null;
  }

  final patternTime = RegExp(r'^\d{2}:\d{2}:\d{2}$');
  final patternDateTime = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$');
  final patternDateTimeTz = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$');

  tz.initializeTimeZones();
  final localTimezone = tz.local;

  if (patternDateTimeTz.hasMatch(timeStr)) {
    final dt = DateTime.parse(timeStr);
    return dt.toLocal();
  } else if (patternDateTime.hasMatch(timeStr)) {
    final timeFormat = DateFormat("yyyy-MM-ddTHH:mm:ss");
    final dateTimeObj = timeFormat.parse(timeStr, true);
    return tz.TZDateTime.from(dateTimeObj, localTimezone);
  } else if (patternTime.hasMatch(timeStr)) {
    final timeFormat = DateFormat("HH:mm:ss");
    final timeObj = timeFormat.parse(timeStr, true);
    final todayDate = DateTime.now();
    final combinedDateTime = DateTime(todayDate.year, todayDate.month, todayDate.day, timeObj.hour, timeObj.minute, timeObj.second);
    return tz.TZDateTime.from(combinedDateTime, localTimezone);
  }

  return null;
}

Future<String> downloadAndSaveImage(String url, String filePath) async {
  var response = await http.get(Uri.parse(url));
  String downloadPath = "";
  if (response.statusCode == 200) {
    var path = File(filePath);
    await path.writeAsBytes(response.bodyBytes);
    downloadPath = filePath;
  }
  return downloadPath;
}

bool checkFreeTrial(DateTime startTime) {
  DateTime now = DateTime.now();
  Duration duration = now.difference(startTime);
  if (duration.inDays >= 1) {
    return false;
  }
  return true;
}

class UserInfo {
  String userId;
  String firstCreate;
  String lastLogin;
  String email;
  List<String> loginDevices;

  UserInfo({
    required this.userId,
    required this.firstCreate,
    required this.lastLogin,
    required this.email,
    required this.loginDevices,
  });

  factory UserInfo.fromMap(Map<dynamic, dynamic> map) {
    return UserInfo(
      userId: map['userId'] ?? '',
      firstCreate: map['firstCreate'] ?? '',
      lastLogin: map['lastLogin'] ?? '',
      email: map['email'] ?? '',
      loginDevices: List<String>.from(map['loginDevices'] ?? []),
    );
  }

  factory UserInfo.fromJson(String jsonStr) {
    final Map<dynamic, dynamic> map = jsonDecode(jsonStr);
    return UserInfo.fromMap(map);
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'userId': userId,
      'firstCreate': firstCreate,
      'lastLogin': lastLogin,
      'email': email,
      'loginDevices': loginDevices,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  String toString() {
    return 'UserInfo(userId: $userId, firstCreate: $firstCreate, lastLogin: $lastLogin, email: $email, loginDevices: $loginDevices)';
  }
}

enum AuthStatus { success, failed, hasLogin, maxLoggin, exceptionError }
enum LoginStatus { emailLogin, googleLogin, logout}

class KerasAuthProvider with ChangeNotifier {
  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  bool bFirstLogin = false;
  bool bsignInSilently = false;
  UserInfo? userInfo;
  LoginStatus loggedStatus = LoginStatus.logout;
  OAuthCredential? googleCredential;
  UserCredential? userCredential;

  LoginStatus getLoginStatus() => loggedStatus;
  bool isLoggedin() => loggedStatus != LoginStatus.logout;
  bool isFirstLogin() => bFirstLogin;

  DateTime getFirstCreateDate() {
    if(userInfo == null) {
      return DateTime(1900, 1, 1, 0, 0, 0);
    }
    String firstCreate = userInfo!.firstCreate;
    DateTime time = DateTime.parse(firstCreate);
    return time;
  }

  String getLoginEmail() {
    if(userCredential == null) {
      return "";
    }
    try {
      String email = userCredential!.user!.email ?? "";
      return email;
    } catch (e) {
      print('getLoginEmail failed: $e');
    }
    return "";
  }

  String getLoginName() {
    if(userCredential == null) {
      return "";
    }
    try {
      String email = userCredential!.user!.displayName ?? "";
      return email;
    } catch (e) {
      print('getLoginName failed: $e');
    }
    return "";
  }

  Future<AuthStatus> isSignInAllowed(UserCredential user) async {
    String uid = user.user!.uid;
    String email = user.user!.email ?? "";
    DatabaseReference userRef = database.child('userLoginInfo').child(uid);
    DataSnapshot snapshot = await userRef.get();

    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (!snapshot.exists) {
      // Create new UserInfo if no record exists
      UserInfo newUserInfo = UserInfo(
        userId: uid,
        firstCreate: currentTime,
        lastLogin: currentTime,
        email: email,
        loginDevices: [uniqueId],
      );
      await userRef.set(newUserInfo.toMap());
      bFirstLogin = true;
      userInfo = newUserInfo;
      return AuthStatus.success;
    } else {
      // Update existing UserInfo
      bFirstLogin = false;
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
      UserInfo existingUserInfo = UserInfo.fromMap(userData);
      if(existingUserInfo.loginDevices.contains(uniqueId)) {
        existingUserInfo.lastLogin = currentTime;
        await userRef.set(existingUserInfo.toMap());
        userInfo = existingUserInfo;
        return AuthStatus.success;
      }
      if (existingUserInfo.loginDevices.length >= maxLogginDevices) {
        return AuthStatus.maxLoggin;
      }
      existingUserInfo.lastLogin = currentTime;
      existingUserInfo.loginDevices.add(uniqueId);
      await userRef.set(existingUserInfo.toMap());
      userInfo = existingUserInfo;
      return AuthStatus.success;
    }
  }

  Future<AuthStatus> handleEmailSignIn(String userName, String password) async {
    if(loggedStatus != LoginStatus.logout) {
      return AuthStatus.hasLogin;
    }
    if(userName.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential user = userCredential ?? await firebaseAuth.signInWithEmailAndPassword(
          email: userName.trim(),
          password: password.trim(),
        );
        AuthStatus status = await isSignInAllowed(user);
        if(status == AuthStatus.success) {
          String uid = user.user!.uid;
          Qonversion.getSharedInstance().identify(uid);
          statisticsInformation.initialize();
          loggedStatus = LoginStatus.emailLogin;
          userCredential = user;
          notifyListeners();
        } else {
          await signOut();
          loggedStatus = LoginStatus.logout;
        }
        return status;
      } on FirebaseAuthException catch (_) {
        return AuthStatus.exceptionError;
      }
    }
    return AuthStatus.failed;
  }

  Future<AuthStatus> googleSignInSilently() async {
    if(loggedStatus != LoginStatus.logout) {
      return AuthStatus.hasLogin;
    }
    if(bsignInSilently == true) {
      return AuthStatus.failed;
    }
    bsignInSilently = true;
    GoogleSignInAccount? account = await googleSignIn.signInSilently();
    if(account != null) {
      if(googleCredential == null) {
        final GoogleSignInAuthentication googleAuth = await account.authentication;
        googleCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
      if(googleCredential != null) {
        UserCredential user = userCredential ?? await firebaseAuth.signInWithCredential(googleCredential!);
        AuthStatus status = await isSignInAllowed(user);
        if(status == AuthStatus.success) {
          String uid = user.user!.uid;
          Qonversion.getSharedInstance().identify(uid);
          statisticsInformation.initialize();
          loggedStatus = LoginStatus.googleLogin;
          userCredential = user;
          notifyListeners();
        } else {
          await signOut();
          loggedStatus = LoginStatus.logout;
        }
        return status;
      }
    }
    return AuthStatus.failed;
  }

  Future<AuthStatus> handleGoogleSignIn() async {
    if(loggedStatus != LoginStatus.logout) {
      return AuthStatus.hasLogin;
    }
    GoogleSignInAccount? account;
    try {
      account = await googleSignIn.signIn();     
      if(account != null) {
        if(googleCredential == null) {
          final GoogleSignInAuthentication googleAuth = await account.authentication;
          googleCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
        }
        if(googleCredential != null) {
          UserCredential user = userCredential ?? await firebaseAuth.signInWithCredential(googleCredential!);
          AuthStatus status = await isSignInAllowed(user);
          if(status == AuthStatus.success) {
            String uid = user.user!.uid;
            Qonversion.getSharedInstance().identify(uid);
            statisticsInformation.initialize();
            loggedStatus = LoginStatus.googleLogin;
            userCredential = user;
            notifyListeners();
          } else {
            await signOut();
            loggedStatus = LoginStatus.logout;
          }
          return status;
        }
      }
    } catch (error) {
      print(error);
    }
    return AuthStatus.failed;
  }

  Future<void> signOut() async {
    if (loggedStatus == LoginStatus.logout) {
      return;
    }
    if (userCredential == null) {
      return;
    }
    try {
      String uid = userCredential!.user!.uid;
      DatabaseReference userRef = database.child('userLoginInfo').child(uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        UserInfo existingUserInfo = UserInfo.fromMap(userData);
        if(existingUserInfo.loginDevices.contains(uniqueId)) {
          existingUserInfo.loginDevices.remove(uniqueId);
          await userRef.set(existingUserInfo.toMap());
        }
      }
      await firebaseAuth.signOut();
      Qonversion.getSharedInstance().logout();
      await statisticsInformation.unInitialize();
      userCredential = null;
      googleCredential = null;
      loggedStatus = LoginStatus.logout;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}

enum SubscriptionStatus { free, basic, professional, premium, ultimate }

class KerasSubscriptionProvider with ChangeNotifier {
  QEntitlement? curEntitlement;
  SubscriptionStatus curSubscriptionStatus = SubscriptionStatus.free;
  Timer? _timer;

  KerasSubscriptionProvider() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await updateSubscriptionState();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  SubscriptionStatus getSubscriptionStatusCode() {
    return curSubscriptionStatus;
  }

  String getSubscriptionStatus() {
    String statusStr = "";
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        statusStr = 'Free';
      case SubscriptionStatus.basic:
        statusStr = 'Basic';
      case SubscriptionStatus.professional:
        statusStr = 'Professional';
      case SubscriptionStatus.premium:
        statusStr = 'Premium';
      case SubscriptionStatus.ultimate:
        statusStr = 'Ultimate';
      default:
        statusStr = 'Unknown';
    }
    print("getSubscriptionStatus: $statusStr");
    return statusStr;
  }

  bool speechPermission() {
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        return true;
      case SubscriptionStatus.basic:
        return true;
      case SubscriptionStatus.professional:
        return true;
      case SubscriptionStatus.premium:
        return true;
      case SubscriptionStatus.ultimate:
        return true;
      default:
        return false;
    }
  }

  bool powerModelPermission() {
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        return false;
      case SubscriptionStatus.basic:
        return false;
      case SubscriptionStatus.professional:
        return false;
      case SubscriptionStatus.premium:
        return true;
      case SubscriptionStatus.ultimate:
        return true;
      default:
        return false;
    }
  }

  bool toolboxPermission() {
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        return false;
      case SubscriptionStatus.basic:
        return false;
      case SubscriptionStatus.professional:
        return false;
      case SubscriptionStatus.premium:
        return false;
      case SubscriptionStatus.ultimate:
        return true;
      default:
        return false;
    }
  }

  Future<void> updateSubscriptionState() async {
    try {
      final Map<String, QEntitlement> ents = await Qonversion.getSharedInstance().checkEntitlements();
      final basic = ents['basic_subscription'];
      final professional = ents['professional_subscription'];
      final premium = ents['premium_subscription'];
      final ultimate = ents['ultimate_subscription'];

      SubscriptionStatus newStatus;
      if (ultimate != null && ultimate.isActive) {
        newStatus = SubscriptionStatus.ultimate;
        print("updateSubscriptionState: ultimate");
        curEntitlement = ultimate;
      } else if (premium != null && premium.isActive) {
        newStatus = SubscriptionStatus.premium;
        print("updateSubscriptionState: premium");
        curEntitlement = premium;
      } else if (professional != null && professional.isActive) {
        newStatus = SubscriptionStatus.professional;
        print("updateSubscriptionState: professional");
        curEntitlement = professional;
      } else if (basic != null && basic.isActive) {
        newStatus = SubscriptionStatus.basic;
        print("updateSubscriptionState: basic");
        curEntitlement = basic;
      } else {
        print("updateSubscriptionState: free");
        newStatus = SubscriptionStatus.free;
        curEntitlement = null;
      }

      if (curSubscriptionStatus != newStatus) {
        print("change status: $curSubscriptionStatus to $newStatus");
        curSubscriptionStatus = newStatus;
        notifyListeners();
      }
    } catch (e) {
      print("updateSubscriptionState: $e");
    }
  }
}

class StatisticsInfo {
  String userId;
  int chatStatistics;
  int imageStatistics;
  int voiceStatistics;
  int speechStatistics;
  int toolBoxStatistics;

  StatisticsInfo({
    required this.userId,
    required this.chatStatistics,
    required this.imageStatistics,
    required this.voiceStatistics,
    required this.speechStatistics,
    required this.toolBoxStatistics,
  });

   factory StatisticsInfo.fromMap(Map<String, dynamic> map) {
    return StatisticsInfo(
      userId: map['userId'] ?? '',
      chatStatistics: map['chatCounts'] ?? 0,
      imageStatistics: map['imageCounts'] ?? 0,
      voiceStatistics: map['voiceCounts'] ?? 0,
      speechStatistics: map['speechCounts'] ?? 0,
      toolBoxStatistics: map['toolBoxCounts'] ?? 0,
    );
  }

  factory StatisticsInfo.fromJson(String jsonStr) {
    final Map<String, dynamic> map = jsonDecode(jsonStr);
    return StatisticsInfo.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'chatCounts': chatStatistics,
      'imageCounts': imageStatistics,
      'voiceCounts': voiceStatistics,
      'speechCounts': speechStatistics,
      'toolBoxCounts': toolBoxStatistics,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'StatisticsInfo(userId: $userId, chatCounts: $chatStatistics, imageCounts: $imageStatistics, voiceCounts: $voiceStatistics, speechCounts: $speechStatistics, toolBoxCounts: $toolBoxStatistics)';
  }
}

class KerasStatisticsInformation {
  static const int maxUpdateCounter = 5;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int statisticsIncrementCounter = 0;
  String loginUserId = "";
  StatisticsInfo? statisticsInfo;

  KerasStatisticsInformation() {
    return;
  }

  Future<void> unInitialize() async {
    try {
      uploadStatistics();
      statisticsIncrementCounter = 0;
      loginUserId = "";
      statisticsInfo = null;
    } catch (e) {
      print('unInitialize failed: $e');
    }
    return;
  }

  Future<void> initialize() async {
    try {
      // Update the statistics information for the previous login user.
      uploadStatistics();

      loginUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      statisticsInfo = StatisticsInfo(
        userId: loginUserId, 
        chatStatistics: 0, 
        imageStatistics: 0,
        voiceStatistics: 0,
        speechStatistics: 0,
        toolBoxStatistics: 0,
      );

    } catch (e) {
      print('Error fetching statistics info: $e');
      statisticsInfo = StatisticsInfo(
          userId: loginUserId, 
          chatStatistics: 0, 
          imageStatistics: 0,
          voiceStatistics: 0,
          speechStatistics: 0,
          toolBoxStatistics: 0,
        );
    }
    return;
  }

  Future<void> tryToUpload() async {
    if(statisticsIncrementCounter >= maxUpdateCounter) {
      await uploadStatistics();
      statisticsIncrementCounter = 0;
    }
  }

  Future<StatisticsInfo> getInfoFromCloud() async {
    try {
      if(loginUserId != "") {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('user_statistics')
        .doc(loginUserId)
        .get();

        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          StatisticsInfo info = StatisticsInfo.fromMap(data);
          print('success get statistics information for userId $loginUserId');
          return info;
        }
      }
    } catch (e) {
      print('Error update statistics: $e');
    }
    return StatisticsInfo(
      userId: loginUserId, 
      chatStatistics: 0, 
      imageStatistics: 0,
      voiceStatistics: 0,
      speechStatistics: 0,
      toolBoxStatistics: 0,
    );
  }

  Future<void> uploadStatistics() async {
    if(loginUserId != "" && statisticsInfo != null) {
      StatisticsInfo info = await getInfoFromCloud();
      info.chatStatistics += statisticsInfo!.chatStatistics;
      info.imageStatistics += statisticsInfo!.imageStatistics;
      info.voiceStatistics += statisticsInfo!.voiceStatistics;
      info.speechStatistics += statisticsInfo!.speechStatistics;
      info.toolBoxStatistics += statisticsInfo!.toolBoxStatistics;
      statisticsInfo!.chatStatistics = 0;
      statisticsInfo!.imageStatistics = 0;
      statisticsInfo!.voiceStatistics = 0;
      statisticsInfo!.speechStatistics = 0;
      statisticsInfo!.toolBoxStatistics = 0;
      Map<String, dynamic> stats = info.toMap();
      await firestore.collection('user_statistics').doc(loginUserId).set(stats);
    }
  }

  void updateChatStatistics() async {
    if(statisticsInfo != null) {
      statisticsInfo!.chatStatistics += 1;
      statisticsIncrementCounter += 1;
      tryToUpload();
    }
  }

  void updateImageStatistics() async {
    if(statisticsInfo != null) {
      statisticsInfo!.imageStatistics += 1;
    }
  }

  void updateVoiceStatistics() async {
    if(statisticsInfo != null) {
      statisticsInfo!.voiceStatistics += 1;
    }
  }

  void updateSpeechStatistics() async {
    if(statisticsInfo != null) {
      statisticsInfo!.speechStatistics += 1;
    }
  }

  void updateToolBoxStatistics() async {
    if(statisticsInfo != null) {
      statisticsInfo!.toolBoxStatistics += 1;
    }
  }
}

class Mailer {
  String defaultRecipients = dotenv.get("author_email");
  String defaultSubject = "Data deletion request";
  String defaultBody1 = "Dear author,\n\nI would like to request the deletion of my data from your application. My Account ID ";
  String defaultBody2 = ".\n\nThank you for your attention to this matter.\n\nBest regards,\n\n";
  String defaultAttachment = "";
  bool defaultIsHTML = false;
  String defaultCC = "";
  String defaultBCC = "";

  Future<bool> sendDeleteDataRequest(String accountID, String accountName) async {
    String body = defaultBody1 + accountID + defaultBody2 + accountName;
    final Email email = Email(
      body: body,
      subject: defaultSubject,
      recipients: [defaultRecipients],
      isHTML: defaultIsHTML,
    );

    await FlutterEmailSender.send(email);
    return true;
  }
  
  Future<bool> sendEmail(String subject, String recipients, String body, String? cc, String? bcc, String? attachment, bool isHTML) async {
    List<String> ccList = cc != null ? [cc] : [];
    List<String> bccList = bcc != null ? [bcc] : [];
    List<String> attachmentList = attachment != null ? [attachment] : [];
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [recipients],
      cc: ccList,
      bcc: bccList,
      attachmentPaths: attachmentList,
      isHTML: isHTML,
    );
    await FlutterEmailSender.send(email);
    return true;
  }
}