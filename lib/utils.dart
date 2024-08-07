import 'dart:async';
import 'dart:io';
import 'dart:convert';
//import 'package:googleapis/speech/v1.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
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
import 'package:system_info2/system_info2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:device_info_plus/device_info_plus.dart';


const int maxTokenLength = 4096;
const int maxReceiveTimeout = 50; // 50 seconds
const int maxConnectTimeout = 30;
const int imageQuality = 80;
const int maxLogginDevices = 3;
const int maxDialogRounds = 5;
const String defaultModel = "gemini-1.5-flash";
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

final List<Map<String, dynamic>> wallpaperSettingPaths = [
    {'bk-1': {'Thumbnail': 'assets/bk-thumbnail/1.jpg', 'background': 'assets/backgrounds/1.jpg'}},
    {'bk-2': {'Thumbnail': 'assets/bk-thumbnail/2.jpg', 'background': 'assets/backgrounds/2.jpg'}},
    {'bk-3': {'Thumbnail': 'assets/bk-thumbnail/3.jpg', 'background': 'assets/backgrounds/3.jpg'}},
    {'bk-4': {'Thumbnail': 'assets/bk-thumbnail/4.jpg', 'background': 'assets/backgrounds/4.jpg'}},
    {'bk-5': {'Thumbnail': 'assets/bk-thumbnail/5.jpg', 'background': 'assets/backgrounds/5.jpg'}},
    {'bk-6': {'Thumbnail': 'assets/bk-thumbnail/6.jpg', 'background': 'assets/backgrounds/6.jpg'}},
    {'bk-7': {'Thumbnail': 'assets/bk-thumbnail/7.jpg', 'background': 'assets/backgrounds/7.jpg'}},
    {'bk-8': {'Thumbnail': 'assets/bk-thumbnail/8.jpg', 'background': 'assets/backgrounds/8.jpg'}},
    {'bk-9': {'Thumbnail': 'assets/bk-thumbnail/9.jpg', 'background': 'assets/backgrounds/9.jpg'}},
    {'bk-10': {'Thumbnail': 'assets/bk-thumbnail/10.jpg', 'background': 'assets/backgrounds/10.jpg'}},
    {'bk-11': {'Thumbnail': 'assets/bk-thumbnail/11.jpg', 'background': 'assets/backgrounds/11.jpg'}},
    {'bk-12': {'Thumbnail': 'assets/bk-thumbnail/12.jpg', 'background': 'assets/backgrounds/12.jpg'}},
    {'bk-13': {'Thumbnail': 'assets/bk-thumbnail/13.jpg', 'background': 'assets/backgrounds/13.jpg'}},
    {'bk-14': {'Thumbnail': 'assets/bk-thumbnail/14.jpg', 'background': 'assets/backgrounds/14.jpg'}},
    {'bk-15': {'Thumbnail': 'assets/bk-thumbnail/15.jpg', 'background': 'assets/backgrounds/15.jpg'}},
    {'bk-16': {'Thumbnail': 'assets/bk-thumbnail/16.jpg', 'background': 'assets/backgrounds/16.jpg'}},
    {'bk-17': {'Thumbnail': 'assets/bk-thumbnail/17.jpg', 'background': 'assets/backgrounds/17.jpg'}},
    {'bk-18': {'Thumbnail': 'assets/bk-thumbnail/18.jpg', 'background': 'assets/backgrounds/18.jpg'}},
    {'bk-19': {'Thumbnail': 'assets/bk-thumbnail/19.jpg', 'background': 'assets/backgrounds/19.jpg'}},
    {'bk-20': {'Thumbnail': 'assets/bk-thumbnail/20.jpg', 'background': 'assets/backgrounds/20.jpg'}},
    {'bk-21': {'Thumbnail': 'assets/bk-thumbnail/21.jpg', 'background': 'assets/backgrounds/21.jpg'}},
    {'bk-22': {'Thumbnail': 'assets/bk-thumbnail/22.jpg', 'background': 'assets/backgrounds/22.jpg'}},
    {'bk-23': {'Thumbnail': 'assets/bk-thumbnail/23.jpg', 'background': 'assets/backgrounds/23.jpg'}},
    {'bk-24': {'Thumbnail': 'assets/bk-thumbnail/24.jpg', 'background': 'assets/backgrounds/24.jpg'}},
    {'bk-25': {'Thumbnail': 'assets/bk-thumbnail/25.jpg', 'background': 'assets/backgrounds/25.jpg'}},
    {'bk-26': {'Thumbnail': 'assets/bk-thumbnail/26.jpg', 'background': 'assets/backgrounds/26.jpg'}},
    {'bk-27': {'Thumbnail': 'assets/bk-thumbnail/27.jpg', 'background': 'assets/backgrounds/27.jpg'}},
    {'bk-28': {'Thumbnail': 'assets/bk-thumbnail/28.jpg', 'background': 'assets/backgrounds/28.jpg'}},
    {'bk-29': {'Thumbnail': 'assets/bk-thumbnail/29.jpg', 'background': 'assets/backgrounds/29.jpg'}},
    {'bk-30': {'Thumbnail': 'assets/bk-thumbnail/30.jpg', 'background': 'assets/backgrounds/30.jpg'}},
    {'bk-31': {'Thumbnail': 'assets/bk-thumbnail/31.jpg', 'background': 'assets/backgrounds/31.jpg'}},
    {'bk-32': {'Thumbnail': 'assets/bk-thumbnail/32.jpg', 'background': 'assets/backgrounds/32.jpg'}},
    {'bk-33': {'Thumbnail': 'assets/bk-thumbnail/33.jpg', 'background': 'assets/backgrounds/33.jpg'}},
    {'bk-34': {'Thumbnail': 'assets/bk-thumbnail/34.jpg', 'background': 'assets/backgrounds/34.jpg'}},
    {'bk-35': {'Thumbnail': 'assets/bk-thumbnail/35.jpg', 'background': 'assets/backgrounds/35.jpg'}},
    {'bk-36': {'Thumbnail': 'assets/bk-thumbnail/36.jpg', 'background': 'assets/backgrounds/36.jpg'}},
    {'bk-37': {'Thumbnail': 'assets/bk-thumbnail/37.jpg', 'background': 'assets/backgrounds/37.jpg'}},
    {'bk-38': {'Thumbnail': 'assets/bk-thumbnail/38.jpg', 'background': 'assets/backgrounds/38.jpg'}},
    {'bk-39': {'Thumbnail': 'assets/bk-thumbnail/39.jpg', 'background': 'assets/backgrounds/39.jpg'}},
    {'bk-40': {'Thumbnail': 'assets/bk-thumbnail/40.jpg', 'background': 'assets/backgrounds/40.jpg'}},
    {'bk-41': {'Thumbnail': 'assets/bk-thumbnail/41.jpg', 'background': 'assets/backgrounds/41.jpg'}},
    {'bk-42': {'Thumbnail': 'assets/bk-thumbnail/42.jpg', 'background': 'assets/backgrounds/42.jpg'}},
    {'bk-43': {'Thumbnail': 'assets/bk-thumbnail/43.jpg', 'background': 'assets/backgrounds/43.jpg'}},
    {'bk-44': {'Thumbnail': 'assets/bk-thumbnail/44.jpg', 'background': 'assets/backgrounds/44.jpg'}},
    {'bk-45': {'Thumbnail': 'assets/bk-thumbnail/45.jpg', 'background': 'assets/backgrounds/45.jpg'}},
    {'bk-46': {'Thumbnail': 'assets/bk-thumbnail/46.jpg', 'background': 'assets/backgrounds/46.jpg'}},
    {'bk-47': {'Thumbnail': 'assets/bk-thumbnail/47.jpg', 'background': 'assets/backgrounds/47.jpg'}},
    {'bk-48': {'Thumbnail': 'assets/bk-thumbnail/48.jpg', 'background': 'assets/backgrounds/48.jpg'}},
    {'bk-49': {'Thumbnail': 'assets/bk-thumbnail/49.jpg', 'background': 'assets/backgrounds/49.jpg'}},
    {'bk-50': {'Thumbnail': 'assets/bk-thumbnail/50.jpg', 'background': 'assets/backgrounds/50.jpg'}},
    {'bk-51': {'Thumbnail': 'assets/bk-thumbnail/51.jpg', 'background': 'assets/backgrounds/51.jpg'}},
    {'bk-52': {'Thumbnail': 'assets/bk-thumbnail/52.jpg', 'background': 'assets/backgrounds/52.jpg'}},
    {'bk-53': {'Thumbnail': 'assets/bk-thumbnail/53.jpg', 'background': 'assets/backgrounds/53.jpg'}},
    {'bk-54': {'Thumbnail': 'assets/bk-thumbnail/54.jpg', 'background': 'assets/backgrounds/54.jpg'}},
    {'bk-55': {'Thumbnail': 'assets/bk-thumbnail/55.jpg', 'background': 'assets/backgrounds/55.jpg'}},
    {'bk-56': {'Thumbnail': 'assets/bk-thumbnail/56.jpg', 'background': 'assets/backgrounds/56.jpg'}},
    {'bk-57': {'Thumbnail': 'assets/bk-thumbnail/57.jpg', 'background': 'assets/backgrounds/57.jpg'}},
    {'bk-58': {'Thumbnail': 'assets/bk-thumbnail/58.jpg', 'background': 'assets/backgrounds/58.jpg'}},
    {'bk-59': {'Thumbnail': 'assets/bk-thumbnail/59.jpg', 'background': 'assets/backgrounds/59.jpg'}},
    {'bk-60': {'Thumbnail': 'assets/bk-thumbnail/60.jpg', 'background': 'assets/backgrounds/60.jpg'}},
    {'bk-61': {'Thumbnail': 'assets/bk-thumbnail/61.jpg', 'background': 'assets/backgrounds/61.jpg'}},
    {'bk-62': {'Thumbnail': 'assets/bk-thumbnail/62.jpg', 'background': 'assets/backgrounds/62.jpg'}},
    {'bk-63': {'Thumbnail': 'assets/bk-thumbnail/63.jpg', 'background': 'assets/backgrounds/63.jpg'}},
    {'bk-64': {'Thumbnail': 'assets/bk-thumbnail/64.jpg', 'background': 'assets/backgrounds/64.jpg'}},
    {'bk-65': {'Thumbnail': 'assets/bk-thumbnail/65.jpg', 'background': 'assets/backgrounds/65.jpg'}},
    {'bk-66': {'Thumbnail': 'assets/bk-thumbnail/66.jpg', 'background': 'assets/backgrounds/66.jpg'}},
    {'bk-67': {'Thumbnail': 'assets/bk-thumbnail/67.jpg', 'background': 'assets/backgrounds/67.jpg'}},
    {'bk-68': {'Thumbnail': 'assets/bk-thumbnail/68.jpg', 'background': 'assets/backgrounds/68.jpg'}},
    {'bk-69': {'Thumbnail': 'assets/bk-thumbnail/69.jpg', 'background': 'assets/backgrounds/69.jpg'}},
    {'bk-70': {'Thumbnail': 'assets/bk-thumbnail/70.jpg', 'background': 'assets/backgrounds/70.jpg'}},
    {'bk-71': {'Thumbnail': 'assets/bk-thumbnail/71.jpg', 'background': 'assets/backgrounds/71.jpg'}},
    {'bk-72': {'Thumbnail': 'assets/bk-thumbnail/72.jpg', 'background': 'assets/backgrounds/72.jpg'}},
    {'bk-73': {'Thumbnail': 'assets/bk-thumbnail/73.jpg', 'background': 'assets/backgrounds/73.jpg'}},
    {'bk-74': {'Thumbnail': 'assets/bk-thumbnail/74.jpg', 'background': 'assets/backgrounds/74.jpg'}},
    {'bk-75': {'Thumbnail': 'assets/bk-thumbnail/75.jpg', 'background': 'assets/backgrounds/75.jpg'}},
    {'bk-76': {'Thumbnail': 'assets/bk-thumbnail/76.jpg', 'background': 'assets/backgrounds/76.jpg'}},
    {'bk-77': {'Thumbnail': 'assets/bk-thumbnail/77.jpg', 'background': 'assets/backgrounds/77.jpg'}},
    {'bk-78': {'Thumbnail': 'assets/bk-thumbnail/78.jpg', 'background': 'assets/backgrounds/78.jpg'}},
    {'bk-79': {'Thumbnail': 'assets/bk-thumbnail/79.jpg', 'background': 'assets/backgrounds/79.jpg'}},
    {'bk-80': {'Thumbnail': 'assets/bk-thumbnail/80.jpg', 'background': 'assets/backgrounds/80.jpg'}},
    {'bk-81': {'Thumbnail': 'assets/bk-thumbnail/81.jpg', 'background': 'assets/backgrounds/81.jpg'}},
    {'bk-82': {'Thumbnail': 'assets/bk-thumbnail/82.jpg', 'background': 'assets/backgrounds/82.jpg'}},
    {'bk-83': {'Thumbnail': 'assets/bk-thumbnail/83.jpg', 'background': 'assets/backgrounds/83.jpg'}},
    {'bk-84': {'Thumbnail': 'assets/bk-thumbnail/84.jpg', 'background': 'assets/backgrounds/84.jpg'}},
    {'bk-85': {'Thumbnail': 'assets/bk-thumbnail/85.jpg', 'background': 'assets/backgrounds/85.jpg'}},
    {'bk-86': {'Thumbnail': 'assets/bk-thumbnail/86.jpg', 'background': 'assets/backgrounds/86.jpg'}},
  ];

enum ModelType { unknown, google, openai }
enum OsType { unknown, android, ios, macos, windows, web }
enum SystemResource { low, medium, high, ultra }

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

final List<int> fontSizeList = [
  14,
  18,
  22,
  26,
];

openai.OpenAI? openAIInstance;
String uniqueId = "unknown";
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
RestrictionInformation restrictionInformation = RestrictionInformation();
final logger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(
    lineLength: 120,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ), // Use the PrettyPrinter to format and print log
  output: null, // Use the default LogOutput (-> send everything to console)
);
OsType osType = OsType.android;
SystemResource systemResource = SystemResource.low;

enum VoiceProvider { microsoft, google, openai, amazon }

class TtsProvider {
  VoiceProvider defaultProvider = VoiceProvider.google;
  String currentSpeech = 'en-US-AnaNeural';
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
      if(roleSpeech != null && currentSpeech != roleSpeech) {
        String speech = roleSpeech;
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
          currentSpeech = speech;
          roleVoice = foundVoice;
        }
      }
    } catch (e) {
      logger.e("switchProvider crash: $e");
    }
    return;
  }

  Future<void> unInitialize() async {
    roleVoice = null;
    voices = null;
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
    } catch (e, stackTrace) {
      logger.e("TtsUniversal init crash: ", stackTrace: stackTrace);
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
      try {
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
        final directory = await getTempPath();
        
        // Create a unique file name.
        final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3';

        // Write the audio bytes to the file.
        final file = File(filePath);
        await file.writeAsBytes(audioBytes);

        // Return the file path.
        return filePath;
      } catch (e, stackTrace) {
        logger.e("generateAudioFile crash: ", stackTrace: stackTrace);
      }
    }
    return null;
  }
}

String getWallpaperTbPath(String wallpaperKey) {
    if(wallpaperKey.isEmpty) {
      wallpaperKey = 'bk-49';
    }

    for(final wallpaper in wallpaperSettingPaths) {
      for (final key in wallpaper.keys) {
        if (key == wallpaperKey) {
          return wallpaper[key]['Thumbnail'];
        }
      }
    }
    return 'assets/bk-thumbnail/49.jpg';
  }

  String getWallpaperBkPath(String wallpaperKey) {
    if(wallpaperKey.isEmpty) {
      wallpaperKey = 'bk-49';
    }
    for(final wallpaper in wallpaperSettingPaths) {
      for (final key in wallpaper.keys) {
        if (key == wallpaperKey) {
          if(systemResource == SystemResource.low ||
            systemResource == SystemResource.medium) {
            return wallpaper[key]['Thumbnail'];
          } else {
            return wallpaper[key]['background'];
          }
        }
      }
    }
    if(systemResource == SystemResource.ultra) {
      return 'assets/backgrounds/49.jpg';
    } else {
      return 'assets/bk-thumbnail/49.jpg';
    }
  }

OsType getOsType() {
  if (Platform.isAndroid) {
    return OsType.android;
  } else if (Platform.isIOS) {
    return OsType.ios;
  } else if (Platform.isWindows) {
    return OsType.windows;
  } else if (Platform.isMacOS) {
    return OsType.macos;
  }
  return OsType.unknown;
}

SystemResource initSystemResource() {
  int totalMemory = SysInfo.getTotalPhysicalMemory();
    logger.i("Total Physical Memory: $totalMemory");

    if(totalMemory < 2123585024) {  // <= 2G
      return SystemResource.low;
    } else if(totalMemory < 4294967296) {  // <= 4G
      return SystemResource.medium;
    } else if(totalMemory < 8589934592) {  // <= 8G
      return SystemResource.high;
    } else {
      return SystemResource.ultra;
    }
}

String getSystemResource() {
  String strResource = "low";
  switch (systemResource) {
    case SystemResource.low:
      strResource = "low";
      break;
    case SystemResource.medium:
      strResource = "medium";
      break;
    case SystemResource.high:
      strResource = "high";
      break;
    case SystemResource.ultra:
      strResource = "ultra";
      break;
  }
  return strResource;
}

void initApp() async {
  try {
    cameras = await availableCameras();
    osType = getOsType();
    if(osType == OsType.ios) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      uniqueId = iosInfo.identifierForVendor ?? "unknown";
    } else if(osType == OsType.android) {
      uniqueId = await const AndroidId().getId() ?? "unknown";
    }
    systemResource = initSystemResource();
    final config = QonversionConfigBuilder(
      dotenv.get("qonversion_proj_key"),
      QLaunchMode.subscriptionManagement
    )
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
  } catch (e, stackTrace) {
    logger.e("initCameras crash: ", stackTrace: stackTrace);
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
  String _homepageWallpaperKey = 'bk-49';
  String _chatpageWallpaperKey = 'bk-64';
  String _language = 'auto';
  int _chatFontSize = 14;
  bool _speechEnable = false;
  bool _toolBoxEnable = false;
  bool _showPolicy = false;

  String get modelName => _modelName;
  String get userName => _userName;
  String get password => _password;
  String get currentRole => _currentRole;
  String get roleIconPath => _roleIconPath;
  String get playerIconPath => _playerIconPath;
  String get homepageWallpaperKey => _homepageWallpaperKey;
  String get chatpageWallpaperKey => _chatpageWallpaperKey;
  String get language => _language;
  int get chatFontSize => _chatFontSize;
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
    _homepageWallpaperKey = homepageWallpaper;
    _chatpageWallpaperKey = chatpageWallpaper;
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

  void updateChatFontSize(int fontSize) {
    _chatFontSize = fontSize;
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
     _chatFontSize = prefs.getInt('chatFontSize') ?? 14;
    _currentRole = prefs.getString('currentRole') ?? 'Keras Robot';
    _roleIconPath = prefs.getString('roleIconPath') ?? 'assets/icons/11/11.png';
    _playerIconPath = prefs.getString('playerIconPath') ?? 'assets/icons/14/9.png';
    _homepageWallpaperKey = prefs.getString('homepageWallpaperKey') ?? 'bk-49';
    _chatpageWallpaperKey = prefs.getString('chatpageWallpaperKey') ?? 'bk-64';
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
    prefs.setInt('chatFontSize', _chatFontSize);
    prefs.setString('currentRole', _currentRole);
    prefs.setString('roleIconPath', _roleIconPath);
    prefs.setString('playerIconPath', _playerIconPath);
    prefs.setString('homepageWallpaperKey', _homepageWallpaperKey);
    prefs.setString('chatpageWallpaperKey', _chatpageWallpaperKey);
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
  bool? toolEnable;

  LlmModel({
    this.type = ModelType.unknown,
    this.model,
    this.systemInstruction,
    this.name,
    this.toolEnable,
    this.chatSession,
  });

  List<dynamic> getHistory() {
    List<Map<String, String>> history = [];
    
    try {
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
    } catch (e, stackTrace) {
      logger.e("getHistory crash: ", stackTrace: stackTrace);
    }
    return history;
  }
}

LlmModel? initLlmModel(String modelName, String systemInstruction, bool toolEnable) {
  if(modelName.isEmpty) {
    return null;
  }
  try {
    for(final name in googleModel) {
      if(modelName == name) {
        if(toolEnable) {
          gemini.ToolConfig toolConfig = gemini.ToolConfig(functionCallingConfig: gemini.FunctionCallingConfig(mode: gemini.FunctionCallingMode.auto));
          LlmModel llmModel = LlmModel(type: ModelType.google);
          llmModel.name = modelName;
          llmModel.toolEnable = toolEnable;
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
          logger.i("model change to $modelName");
          return llmModel;
        } else {
          LlmModel llmModel = LlmModel(type: ModelType.google);
          llmModel.name = modelName;
          llmModel.toolEnable = toolEnable;
          llmModel.systemInstruction = systemInstruction;
          final model = gemini.GenerativeModel(
            model: name,
            apiKey: dotenv.get("api_key"),
            systemInstruction: gemini.Content.system(systemInstruction),
          );
          llmModel.model = model;
          final chatSession = model.startChat();
          llmModel.chatSession = chatSession;
          logger.i("model change to $modelName");
          return llmModel;
        }
      }
    }
    
    if(openAIInstance != null) {
      for(final name in openAIModel) {
        if(modelName == name && name == 'gpt-4o-mini') {
          LlmModel llmModel = LlmModel(type: ModelType.openai);
          llmModel.name = modelName;
          llmModel.toolEnable = toolEnable;
          llmModel.systemInstruction = systemInstruction;
          final model = openai.ChatModelFromValue(model: name);
          llmModel.model = model;
          final chatSession = OpenaiChatHistory(history: [openai.Messages(role: openai.Role.system, content: systemInstruction).toJson()]);
          llmModel.chatSession = chatSession;
          logger.i("model change to $modelName");
          return llmModel;
        }
        else if (modelName == name && name == openai.kGpt4o) {
          LlmModel llmModel = LlmModel(type: ModelType.openai);
          llmModel.name = modelName;
          llmModel.toolEnable = toolEnable;
          llmModel.systemInstruction = systemInstruction;
          final model = openai.Gpt4OChatModel();
          llmModel.model = model;
          final chatSession = OpenaiChatHistory(history: [openai.Messages(role: openai.Role.system, content: systemInstruction).toJson()]);
          llmModel.chatSession = chatSession;
          logger.i("model change to $modelName");
          return llmModel;
        }
      }
    }
  } catch (e, stackTrace) {
    logger.e("initLlmModel crash: ", stackTrace: stackTrace);
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
      logger.e("Could not launch $url");
      throw 'Could not launch $url';
    }
  }

Future<Directory> getTempPath() async {
  final directory = await getTemporaryDirectory();
  final appTempPath = '${directory.path}/temp';
  final tempDir = Directory(appTempPath);
  if (!await tempDir.exists()) {
    await tempDir.create(recursive: true);
  }
  return tempDir;
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
    final tmpFolder = await getTempPath();
  File file = File("${tmpFolder.path}/$tmpFile");
    await file.writeAsString(content);
    bSuccess = true;
  } catch (e, stackTrace) {
    logger.e("writeTempFile crash: ", stackTrace: stackTrace);
    bSuccess = false;
  }
  return bSuccess;
}

Future<String> readTempFile(String tmpFile) async {
  try {
    final tmpFolder = await getTempPath();
    File file = File("${tmpFolder.path}/$tmpFile");
    String contents = await file.readAsString();
    return contents;
  } catch (e, stackTrace) {
    logger.e("readTempFile crash: ", stackTrace: stackTrace);
    return "";
  }
}

Future<String> getFileTempPath(String tmpFile) async {
  final folder = await getTempPath();
  if(tmpFile.isEmpty) {
    return folder.path;
  }
  return "$folder/$tmpFile";
}

Future<String> getFileDocumentsPath(String tmpFile) async {
  final folder = await getDocumentsPath();
  if(tmpFile.isEmpty) {
    return folder;
  }
  return "$folder/$tmpFile";
}

Future<String> getFileDownloadsPath(String tmpFile) async {
  final folder = await getDownloadsPath();
  if(tmpFile.isEmpty) {
    return folder;
  }
  return "$folder/$tmpFile";
}

Future<DateTime?> convertTimeToRFC3339Time(String timeStr) async {
  if (timeStr.isEmpty) {
    return null;
  }

  final patternTime = RegExp(r'^\d{2}:\d{2}:\d{2}$');
  final patternDateTime = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$');
  final patternDateTimeTz = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$');

  try {
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
  } catch (e, stackTrace) {
    logger.e("convertTimeToRFC3339Time crash: ", stackTrace: stackTrace);
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

class UserInfo {
  String userId;
  String firstCreate;
  String lastLogin;
  String email;
  String systemResource;
  List<String> loginDevices;

  UserInfo({
    required this.userId,
    required this.firstCreate,
    required this.lastLogin,
    required this.email,
    required this.systemResource,
    required this.loginDevices,
  });

  factory UserInfo.fromMap(Map<dynamic, dynamic> map) {
    return UserInfo(
      userId: map['userId'] ?? '',
      firstCreate: map['firstCreate'] ?? '',
      lastLogin: map['lastLogin'] ?? '',
      email: map['email'] ?? '',
      systemResource: map['systemResource'] ?? '',
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
      'systemResource': systemResource,
      'loginDevices': loginDevices,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  String toString() {
    return 'UserInfo(userId: $userId, firstCreate: $firstCreate, lastLogin: $lastLogin, email: $email, systemResource: $systemResource, loginDevices: $loginDevices)';
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
    try {
      String firstCreate = userInfo!.firstCreate;
      DateTime time = DateTime.parse(firstCreate);
      return time;
    } catch (e, stackTrace) {
      logger.e("getFirstCreateDate crash: ", stackTrace: stackTrace);
    }
    return DateTime(1900, 1, 1, 0, 0, 0);
  }

  String getLoginEmail() {
    if(userCredential == null) {
      return "";
    }
    try {
      String email = userCredential!.user!.email ?? "";
      return email;
    } catch (e, stackTrace) {
      logger.e("getLoginEmail crash: ", stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      logger.e("getLoginName crash: ", stackTrace: stackTrace);
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
        systemResource: getSystemResource(),
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
        existingUserInfo.systemResource = getSystemResource();
        await userRef.set(existingUserInfo.toMap());
        userInfo = existingUserInfo;
        return AuthStatus.success;
      }
      if (existingUserInfo.loginDevices.length >= maxLogginDevices) {
        return AuthStatus.maxLoggin;
      }
      existingUserInfo.lastLogin = currentTime;
      existingUserInfo.systemResource = getSystemResource();
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
      } on FirebaseAuthException catch (e, stackTrace) {
        logger.e("getLoginName crash: ", stackTrace: stackTrace);
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
    try {
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
    } catch (e, stackTrace) {
      logger.e("googleSignInSilently crash: ", stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      logger.e("handleGoogleSignIn crash: ", stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      logger.e("signOut crash: ", stackTrace: stackTrace);
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

  bool isFreeSubscriptionStatus() {
    return curSubscriptionStatus == SubscriptionStatus.free;
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
    logger.i("getSubscriptionStatus: $statusStr");
    return statusStr;
  }

  bool checkFreeTrial(DateTime startTime) {
    if(curSubscriptionStatus != SubscriptionStatus.free) {
      return true;
    }
    try {
      final remoteConfig = FirebaseRemoteConfigService();
      int freeTrialDays = remoteConfig.getInt(FirebaseRemoteConfigKeys.freeTrialDaysKey);
      DateTime now = DateTime.now();
      Duration duration = now.difference(startTime);
      if (duration.inDays >= freeTrialDays) {
        return false;
      }
    } catch (e, stackTrace) {
      logger.e("checkFreeTrial crash: ", stackTrace: stackTrace);
    }
    return true;
  }

  bool normalSpeechPermission() {
    List<FeatureRights> rights = [];
    SubscriptionRights curSubscriptionRights = SubscriptionRights();
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        rights = curSubscriptionRights.getFreeTrialRights();
      case SubscriptionStatus.basic:
        rights = curSubscriptionRights.getBaseSubRights();
      case SubscriptionStatus.professional:
        rights = curSubscriptionRights.getProSubRights();
      case SubscriptionStatus.premium:
        rights = curSubscriptionRights.getPremiumSubRights();
      case SubscriptionStatus.ultimate:
        rights = curSubscriptionRights.getUltimateSubRights();
      default:
    }
    return curSubscriptionRights.havingNormalSpeechRight(rights);
  }

  bool advancedSpeechPermission() {
    List<FeatureRights> rights = [];
    SubscriptionRights curSubscriptionRights = SubscriptionRights();
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        rights = curSubscriptionRights.getFreeTrialRights();
      case SubscriptionStatus.basic:
        rights = curSubscriptionRights.getBaseSubRights();
      case SubscriptionStatus.professional:
        rights = curSubscriptionRights.getProSubRights();
      case SubscriptionStatus.premium:
        rights = curSubscriptionRights.getPremiumSubRights();
      case SubscriptionStatus.ultimate:
        rights = curSubscriptionRights.getUltimateSubRights();
      default:
    }
    return curSubscriptionRights.havingAdvancedSpeechRight(rights);
  }

  bool speechPermission() {
    return (normalSpeechPermission() || advancedSpeechPermission());
  }

  bool baseModelPermission() {
    List<FeatureRights> rights = [];
    SubscriptionRights curSubscriptionRights = SubscriptionRights();
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        rights = curSubscriptionRights.getFreeTrialRights();
      case SubscriptionStatus.basic:
        rights = curSubscriptionRights.getBaseSubRights();
      case SubscriptionStatus.professional:
        rights = curSubscriptionRights.getProSubRights();
      case SubscriptionStatus.premium:
        rights = curSubscriptionRights.getPremiumSubRights();
      case SubscriptionStatus.ultimate:
        rights = curSubscriptionRights.getUltimateSubRights();
      default:
    }
    return curSubscriptionRights.havingBaseModelRight(rights);
  }

  bool powerModelPermission() {
    List<FeatureRights> rights = [];
    SubscriptionRights curSubscriptionRights = SubscriptionRights();
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        rights = curSubscriptionRights.getFreeTrialRights();
      case SubscriptionStatus.basic:
        rights = curSubscriptionRights.getBaseSubRights();
      case SubscriptionStatus.professional:
        rights = curSubscriptionRights.getProSubRights();
      case SubscriptionStatus.premium:
        rights = curSubscriptionRights.getPremiumSubRights();
      case SubscriptionStatus.ultimate:
        rights = curSubscriptionRights.getUltimateSubRights();
      default:
    }
    return curSubscriptionRights.havingAdvancedModelRight(rights);
  }

  bool toolboxPermission() {
    List<FeatureRights> rights = [];
    SubscriptionRights curSubscriptionRights = SubscriptionRights();
    switch (curSubscriptionStatus) {
      case SubscriptionStatus.free:
        rights = curSubscriptionRights.getFreeTrialRights();
      case SubscriptionStatus.basic:
        rights = curSubscriptionRights.getBaseSubRights();
      case SubscriptionStatus.professional:
        rights = curSubscriptionRights.getProSubRights();
      case SubscriptionStatus.premium:
        rights = curSubscriptionRights.getPremiumSubRights();
      case SubscriptionStatus.ultimate:
        rights = curSubscriptionRights.getUltimateSubRights();
      default:
    }
    return curSubscriptionRights.havingToolboxRight(rights);
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
        logger.i("updateSubscriptionState: ultimate");
        curEntitlement = ultimate;
      } else if (premium != null && premium.isActive) {
        newStatus = SubscriptionStatus.premium;
        logger.i("updateSubscriptionState: premium");
        curEntitlement = premium;
      } else if (professional != null && professional.isActive) {
        newStatus = SubscriptionStatus.professional;
        logger.i("updateSubscriptionState: professional");
        curEntitlement = professional;
      } else if (basic != null && basic.isActive) {
        newStatus = SubscriptionStatus.basic;
        logger.i("updateSubscriptionState: basic");
        curEntitlement = basic;
      } else {
        logger.i("updateSubscriptionState: free");
        newStatus = SubscriptionStatus.free;
        curEntitlement = null;
      }

      if (curSubscriptionStatus != newStatus) {
        logger.i("change status: $curSubscriptionStatus to $newStatus");
        curSubscriptionStatus = newStatus;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      logger.e("updateSubscriptionState crash: ", stackTrace: stackTrace);
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
  StatisticsInfo? totalstatisticsInfo;

  KerasStatisticsInformation() {
    return;
  }

  int getTotalChatStatistics() {
    if(totalstatisticsInfo != null) {
      return totalstatisticsInfo!.chatStatistics;
    }
    return 0;
  }

  int getTotalImageStatistics() {
    if(totalstatisticsInfo != null) {
      return totalstatisticsInfo!.imageStatistics;
    }
    return 0;
  }

  int getTotalVoiceStatistics() {
    if(totalstatisticsInfo != null) {
      return totalstatisticsInfo!.voiceStatistics;
    }
    return 0;
  }

  int getTotalSpeechStatistics() {
    if(totalstatisticsInfo != null) {
      return totalstatisticsInfo!.speechStatistics;
    }
    return 0;
  }

  int getTotalToolBoxStatistics() {
    if(totalstatisticsInfo != null) {
      return totalstatisticsInfo!.toolBoxStatistics;
    }
    return 0;
  }

  Future<void> unInitialize() async {
    try {
      uploadStatistics();
      statisticsIncrementCounter = 0;
      loginUserId = "";
      statisticsInfo = null;
      totalstatisticsInfo = null;
    } catch (e, stackTrace) {
      logger.e("unInitialize crash: ", stackTrace: stackTrace);
    }
    return;
  }

  Future<void> initialize() async {
    try {
      // Update the statistics information for the previous login user.
      uploadStatistics();

      loginUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final info = await getInfoFromCloud();
      statisticsInfo = StatisticsInfo(
        userId: loginUserId, 
        chatStatistics: 0, 
        imageStatistics: 0,
        voiceStatistics: 0,
        speechStatistics: 0,
        toolBoxStatistics: 0,
      );
      totalstatisticsInfo = info;

    } catch (e, stackTrace) {
      logger.e('Error fetching statistics info:', stackTrace: stackTrace);
      statisticsInfo = StatisticsInfo(
          userId: loginUserId, 
          chatStatistics: 0, 
          imageStatistics: 0,
          voiceStatistics: 0,
          speechStatistics: 0,
          toolBoxStatistics: 0,
      );
      totalstatisticsInfo = StatisticsInfo(
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
          logger.i('success get statistics information for userId $loginUserId');
          return info;
        }
      }
    } catch (e, stackTrace) {
      logger.e("getInfoFromCloud crash: ", stackTrace: stackTrace);
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
      try {
        StatisticsInfo info = await getInfoFromCloud();
        info.chatStatistics += statisticsInfo!.chatStatistics;
        info.imageStatistics += statisticsInfo!.imageStatistics;
        info.voiceStatistics += statisticsInfo!.voiceStatistics;
        info.speechStatistics += statisticsInfo!.speechStatistics;
        info.toolBoxStatistics += statisticsInfo!.toolBoxStatistics;
        if(totalstatisticsInfo != null) {
          totalstatisticsInfo = info;
        }
        statisticsInfo!.chatStatistics = 0;
        statisticsInfo!.imageStatistics = 0;
        statisticsInfo!.voiceStatistics = 0;
        statisticsInfo!.speechStatistics = 0;
        statisticsInfo!.toolBoxStatistics = 0;
        Map<String, dynamic> stats = info.toMap();
        await firestore.collection('user_statistics').doc(loginUserId).set(stats);
      } catch (e, stackTrace) {
        logger.e("uploadStatistics crash: ", stackTrace: stackTrace);
      }
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
    try {
      String body = defaultBody1 + accountID + defaultBody2 + accountName;
      final Email email = Email(
        body: body,
        subject: defaultSubject,
        recipients: [defaultRecipients],
        isHTML: defaultIsHTML,
      );

      await FlutterEmailSender.send(email);
      return true;
    } catch (e) {
      logger.e("sendDeleteDataRequest crash: $e");
    };

    try {
      launchURL(deleteRequestUrl);
    } catch (e) {
      logger.e("sendDeleteDataRequest crash: $e");
    }
    return false;
  }
  
  Future<bool> sendEmail(String subject, String recipients, String body, String? cc, String? bcc, String? attachment, bool isHTML) async {
    List<String> ccList = cc != null ? [cc] : [];
    List<String> bccList = bcc != null ? [bcc] : [];
    List<String> attachmentList = attachment != null ? [attachment] : [];
    try {
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
    } catch (e) {
      logger.e("sendEmail crash: $e");
    }   
    return false;
  }
}

class RestrictionInformation {
  final remoteConfig = FirebaseRemoteConfigService();

  bool restrictionsEnable() {
    try {
      if(remoteConfig.binitialize) {
        bool enable = remoteConfig.getBool(FirebaseRemoteConfigKeys.restrictionsEnableKey);
        return enable;
      }
    } catch (e, stackTrace) {
      logger.e("restrictionsEnable crash: ", stackTrace: stackTrace);
    }
    return false;
  }

  int getConversationRestriction() {
    if(restrictionsEnable()) {
      int counts = remoteConfig.getInt(FirebaseRemoteConfigKeys.conversationRestKey);
      return counts;
    }
    return 30000;
  }

  int getImageRestriction() {
    if(restrictionsEnable()) {
      int counts = remoteConfig.getInt(FirebaseRemoteConfigKeys.imageRestKey);
      return counts;
    }
    return 30000;
  }

  int getVoiceRestriction() {
    if(restrictionsEnable()) {
      int counts = remoteConfig.getInt(FirebaseRemoteConfigKeys.voiceRestKey);
      return counts;
    }
    return 30000;
  }

  int getToolboxRestriction() {
    if(restrictionsEnable()) {
      int counts = remoteConfig.getInt(FirebaseRemoteConfigKeys.toolboxRestKey);
      return counts;
    }
    return 30000;
  }

  bool isConversationRestriction() {
    int totalCounts = statisticsInformation.getTotalChatStatistics();
    int maxCounts = getConversationRestriction();
    return totalCounts >= maxCounts;
  }

  bool isImageRestriction() {
    int totalCounts = statisticsInformation.getTotalImageStatistics();
    int maxCounts = getImageRestriction();
    return totalCounts >= maxCounts;
  }

  bool isVoiceRestriction() {
    int totalCounts = statisticsInformation.getTotalVoiceStatistics();
    int maxCounts = getVoiceRestriction();
    return totalCounts >= maxCounts;
  }

  bool isSpeechRestriction() {
    int totalCounts = statisticsInformation.getTotalSpeechStatistics();
    int maxCounts = getVoiceRestriction();
    return totalCounts >= maxCounts;
  }

  bool isToolboxRestriction() {
    int totalCounts = statisticsInformation.getTotalToolBoxStatistics();
    int maxCounts = getToolboxRestriction();
    return totalCounts >= maxCounts;
  }
}

enum FeatureRights { basemodel, advancedmodel, normalspeech, advancedspeech, toolbox }

class SubscriptionRights {
  final remoteConfig = FirebaseRemoteConfigService();

  bool remoteConfigInitSuccess() {
    try {
      return remoteConfig.binitialize;
    } catch (e, stackTrace) {
      logger.e("remoteConfigInitSuccess crash: ", stackTrace: stackTrace);
    }
    return false;
  }

  List<FeatureRights> getRights(String rightsString) {
    List<FeatureRights> rights = [];
    if(rightsString.isEmpty) {
      return rights;
    }
    List<String> substrings = rightsString.split(',');
    if(substrings.isEmpty) {
      return rights;
    }
    for(String substring in substrings) {
      switch(substring) {
        case "base_model":
          rights.add(FeatureRights.basemodel);
          break;
        case "advanced_model":
          rights.add(FeatureRights.advancedmodel);
          break;
        case "normal_speech":
          rights.add(FeatureRights.normalspeech);
          break;
        case "advanced_speech":
          rights.add(FeatureRights.advancedspeech);
          break;
        case "toolbox":
          rights.add(FeatureRights.toolbox);
          break;
        default:
          break;
      }
    }
    return rights;
  }

  bool havingBaseModelRight(List<FeatureRights> rights) {
    return rights.contains(FeatureRights.basemodel);
  }

  bool havingAdvancedModelRight(List<FeatureRights> rights) {
    return rights.contains(FeatureRights.advancedmodel);
  }

  bool havingNormalSpeechRight(List<FeatureRights> rights) {
    return rights.contains(FeatureRights.normalspeech);
  }

  bool havingAdvancedSpeechRight(List<FeatureRights> rights) {
    return rights.contains(FeatureRights.advancedspeech);
  }

  bool havingToolboxRight(List<FeatureRights> rights) {
    return rights.contains(FeatureRights.toolbox);
  }

  List<FeatureRights> getFreeTrialRights() {
    List<FeatureRights> rights = [];
    if(!remoteConfigInitSuccess()) {
      return rights;
    }
    try {
      String rightsString = remoteConfig.getString(FirebaseRemoteConfigKeys.freeTrialRightsKey);
      if(rightsString.isNotEmpty) {
        rights = getRights(rightsString);
      }
    } catch (e, stackTrace) {
      logger.e("getFreeTrialRights crash: ", stackTrace: stackTrace);
    }
    return rights;
  }

  List<FeatureRights> getBaseSubRights() {
    List<FeatureRights> rights = [];
    if(!remoteConfigInitSuccess()) {
      return rights;
    }
    try {
      String rightsString = remoteConfig.getString(FirebaseRemoteConfigKeys.baseSubRightsKey);
      if(rightsString.isNotEmpty) {
        rights = getRights(rightsString);
      }
    } catch (e, stackTrace) {
      logger.e("getBaseSubRights crash: ", stackTrace: stackTrace);
    }
    return rights;
  }

  List<FeatureRights> getProSubRights() {
    List<FeatureRights> rights = [];
    if(!remoteConfigInitSuccess()) {
      return rights;
    }
    try {
      String rightsString = remoteConfig.getString(FirebaseRemoteConfigKeys.proSubRightsKey);
      if(rightsString.isNotEmpty) {
        rights = getRights(rightsString);
      }
    } catch (e, stackTrace) {
      logger.e("getProSubRights crash: ", stackTrace: stackTrace);
    }
    return rights;
  }

  List<FeatureRights> getPremiumSubRights() {
    List<FeatureRights> rights = [];
    if(!remoteConfigInitSuccess()) {
      return rights;
    }
    try {
      String rightsString = remoteConfig.getString(FirebaseRemoteConfigKeys.premiumSubRightsKey);
      if(rightsString.isNotEmpty) {
        rights = getRights(rightsString);
      }
    } catch (e, stackTrace) {
      logger.e("getPremiumSubRights crash: ", stackTrace: stackTrace);
    }
    return rights;
  }

  List<FeatureRights> getUltimateSubRights() {
    List<FeatureRights> rights = [];
    if(!remoteConfigInitSuccess()) {
      return rights;
    }
    try {
      String rightsString = remoteConfig.getString(FirebaseRemoteConfigKeys.ultimateSubRightsKey);
      if(rightsString.isNotEmpty) {
        rights = getRights(rightsString);
      }
    } catch (e, stackTrace) {
      logger.e("getUltimateSubRights crash: ", stackTrace: stackTrace);
    }
    return rights;
  }
}

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._() : _remoteConfig = FirebaseRemoteConfig.instance;

  static FirebaseRemoteConfigService? _instance;
  factory FirebaseRemoteConfigService() => _instance ??= FirebaseRemoteConfigService._();
  bool binitialize = false;
  final FirebaseRemoteConfig _remoteConfig;

  Future<void> initialize() async {
    await setConfigSettings();
    await setDefaults();
    await fetchAndActivate();
    binitialize = true;
}

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) =>_remoteConfig.getBool(key);
  int getInt(String key) =>_remoteConfig.getInt(key);
  double getDouble(String key) =>_remoteConfig.getDouble(key);

  Future<void> setConfigSettings() async => _remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 12),
    ),
  );

  Future<void> setDefaults() async => _remoteConfig.setDefaults(
    const {
      FirebaseRemoteConfigKeys.restrictionsEnableKey: false,
      FirebaseRemoteConfigKeys.conversationRestKey: 30000,
      FirebaseRemoteConfigKeys.imageRestKey: 3000,
      FirebaseRemoteConfigKeys.voiceRestKey: 30000,
      FirebaseRemoteConfigKeys.toolboxRestKey: 30000,

      FirebaseRemoteConfigKeys.freeTrialRightsKey: 'advanced_speech,base_model',
      FirebaseRemoteConfigKeys.baseSubRightsKey: 'base_model',
      FirebaseRemoteConfigKeys.proSubRightsKey: 'normal_speech,base_model',
      FirebaseRemoteConfigKeys.premiumSubRightsKey: 'advanced_speech,base_model',
      FirebaseRemoteConfigKeys.ultimateSubRightsKey: 'advanced_speech,advanced_model,toolbox',

      FirebaseRemoteConfigKeys.freeTrialDaysKey: 3,
    },
  );

  Future<void> fetchAndActivate() async {
    bool updated = await _remoteConfig.fetchAndActivate();

    if (updated) {
      logger.d('The config has been updated.');
    } else {
      logger.d('The config is not updated..');
    }
  }
}

class FirebaseRemoteConfigKeys {
  static const String restrictionsEnableKey = 'restrictions_enable';
  static const String conversationRestKey = 'conversation_restriction_counts';
  static const String imageRestKey = 'image_restriction_counts';
  static const String voiceRestKey = 'voice_restriction_counts';
  static const String toolboxRestKey = 'toolbox_restriction_counts';

  static const String freeTrialRightsKey = 'free_trial_rights';
  static const String baseSubRightsKey = 'base_subscription_rights';
  static const String proSubRightsKey = 'pro_subscription_rights';
  static const String premiumSubRightsKey = 'premium_subscription_rights';
  static const String ultimateSubRightsKey = 'ultimate_subscription_rights';

  static const String freeTrialDaysKey = 'free_trial_days';
}

class StringStackTrace implements StackTrace {

 final String _stackTrace;

 const StringStackTrace(this._stackTrace);

 String toString() => _stackTrace;

}