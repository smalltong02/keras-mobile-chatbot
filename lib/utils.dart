import 'dart:async';
import 'dart:io';
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


const int maxTokenLength = 4096;
const int maxReceiveTimeout = 30; // 30 seconds
const int maxConnectTimeout = 30;
const int maxLogginDevices = 3;

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

final List<String> googleModel = [
  "gemini-1.5-flash",
  "gemini-1.5-pro",
];

final List<String> openAIModel = [
  openai.kGpt4o,
  'gpt-4o-mini'
];
openai.OpenAI? openAIInstance;
String uniqueId = "";
final List<String> llmModel = googleModel + openAIModel;

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
];

List<CameraDescription> cameras = [];
List<VoiceUniversal> voicesList = [];
VoiceUniversal? roleVoice;
Deepgram? deepgram;

void initCameras() async {
  cameras = await availableCameras();
  TtsUniversal.init(
    provider: 'microsoft',
    google: InitParamsGoogle(apiKey: dotenv.get("api_key")),
    microsoft: InitParamsMicrosoft(subscriptionKey: dotenv.get("azure_speech_key"), region: dotenv.get("azure_speech_region")),
    withLogs: true
  );
  uniqueId = await const AndroidId().getId() ?? "unknown";
  final config = new QonversionConfigBuilder(
    dotenv.get("qonversion_proj_key"),
    QLaunchMode.subscriptionManagement
  )
  .enableKidsMode()
  .build();
  Qonversion.initialize(config);

  openAIInstance = openai.OpenAI.instance.build(token: dotenv.get("openai_key"), baseOption: openai.HttpSetup(receiveTimeout: const Duration(seconds: maxReceiveTimeout), connectTimeout: const Duration(seconds: maxConnectTimeout)),enableLog: true);

  deepgram = Deepgram(dotenv.get("deepgram_speech_key"), baseQueryParams: {
    'model': 'nova-2-general',
    'detect_language': true,
    'filler_words': false,
    'punctuation': true,
      // more options here : https://developers.deepgram.com/reference/listen-file
  });

  final voicesResponse = await TtsUniversal.getVoices();
  final voices = voicesResponse.voices; 
  if(voices.isNotEmpty) {
    voicesList = voices;
    VoiceUniversal? foundVoice;
    for (int i = 0; i < voices.length; i++) {
      if (voices[i].code == "en-US-AnaNeural") {
        foundVoice = voices[i];
        break;
      }
    }
    roleVoice = foundVoice;
  }
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

  SettingProvider() {
    _init();
  }

  Future<void> _init() async {
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

enum AuthStatus { success, failed, hasLogin, maxLoggin, exceptionError }
enum LoginStatus { emailLogin, googleLogin, logout}

class KerasAuthProvider with ChangeNotifier {
  final firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  bool bsignInSilently = false;
  LoginStatus loggedStatus = LoginStatus.logout;
  UserCredential? userCredential;

  LoginStatus getLoginStatus() => loggedStatus;
  bool isLoggedin() => loggedStatus != LoginStatus.logout;

  Future<AuthStatus> isSignInAllowed(UserCredential user) async {
    String uid = user.user!.uid;
    DatabaseReference userRef = database.child('userLoginInfo').child(uid);
    DataSnapshot snapshot = await userRef.get();
    List<String> userData = (snapshot.value as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    if(userData.isEmpty) {
      userData.add(uniqueId);
      userRef.set(userData);
      return AuthStatus.success;
    }
    else {
      if(userData.contains(uniqueId)) {
        return AuthStatus.success;
      }
      else {
        if(userData.length >= maxLogginDevices) {
          return AuthStatus.maxLoggin;
        }
        userData.add(uniqueId);
        userRef.set(userData);
        return AuthStatus.success;
      }
    }
  }

  Future<AuthStatus> handleEmailSignIn(String userName, String password) async {
    if(loggedStatus != LoginStatus.logout) {
      return AuthStatus.hasLogin;
    }
    if(userName.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
          email: userName.trim(),
          password: password.trim(),
        );
        AuthStatus status = await isSignInAllowed(user);
        if(status == AuthStatus.success) {
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
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential user = await firebaseAuth.signInWithCredential(googleCredential);
      AuthStatus status = await isSignInAllowed(user);
      if(status == AuthStatus.success) {
        loggedStatus = LoginStatus.googleLogin;
        userCredential = user;
        notifyListeners();
      } else {
        await signOut();
        loggedStatus = LoginStatus.logout;
      }
      return status;
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
    } catch (error) {
      print(error);
    }
    if(account != null) {
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential user = await firebaseAuth.signInWithCredential(googleCredential);
      AuthStatus status = await isSignInAllowed(user);
      if(status == AuthStatus.success) {
        loggedStatus = LoginStatus.googleLogin;
        userCredential = user;
        notifyListeners();
      } else {
        await signOut();
        loggedStatus = LoginStatus.logout;
      }
      return status;
    }
    return AuthStatus.failed;
  }

  Future<void> signOut() async {
    if(loggedStatus == LoginStatus.logout) {
      return;
    }
    if(userCredential == null) {
      return;
    }
    try {
      String uid = userCredential!.user!.uid;
      DatabaseReference userRef = database.child('userLoginInfo').child(uid);
      DataSnapshot snapshot = await userRef.get();
      List<String> userData = (snapshot.value as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
      if(userData.isNotEmpty) {
        if(userData.contains(uniqueId)) {
          userData.remove(uniqueId);
          userRef.set(userData);
        }
      }
      await firebaseAuth.signOut();
      userCredential = null;
      loggedStatus = LoginStatus.logout;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}