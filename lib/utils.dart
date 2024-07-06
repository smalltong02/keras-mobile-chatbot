import 'dart:io';
import 'package:googleapis/speech/v1.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String systemInstruction = "You are now my secretary, and you need to help me solve problems in my personal life or at work. Your name is ";

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

class SettingProvider with ChangeNotifier {
  String _modelName = 'gemini-1.5-pro';
  String _currentRole = 'Jessica';
  String _roleIconPath = 'assets/icons/11/11.png';
  String _playerIconPath = 'assets/icons/14/9.png';
  String _homepageWallpaperPath = 'assets/backgrounds/49.jpg';
  String _chatpageWallpaperPath = 'assets/backgrounds/64.jpg';

  String get modelName => _modelName;
  String get currentRole => _currentRole;
  String get roleIconPath => _roleIconPath;
  String get playerIconPath => _playerIconPath;
  String get homepageWallpaperPath => _homepageWallpaperPath;
  String get chatpageWallpaperPath => _chatpageWallpaperPath;

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

  Future<void> loadSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     _modelName = prefs.getString('modelName') ?? 'gemini-1.5-pro';
    _currentRole = prefs.getString('currentRole') ?? 'Jessica';
    _roleIconPath = prefs.getString('roleIconPath') ?? 'assets/icons/11/11.png';
    _playerIconPath = prefs.getString('playerIconPath') ?? 'assets/icons/14/9.png';
    _homepageWallpaperPath = prefs.getString('homepageWallpaperPath') ?? 'assets/backgrounds/49.jpg';
    _chatpageWallpaperPath = prefs.getString('chatpageWallpaperPath') ?? 'assets/backgrounds/64.jpg';
  }

  Future<void> saveSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('modelName', _modelName);
    prefs.setString('currentRole', _currentRole);
    prefs.setString('roleIconPath', _roleIconPath);
    prefs.setString('playerIconPath', _playerIconPath);
    prefs.setString('homepageWallpaperPath', _homepageWallpaperPath);
    prefs.setString('chatpageWallpaperPath', _chatpageWallpaperPath);
  }
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
  final postal = _extractValue(geocode, 'postal');
  final countryName = _extractValue(geocode, 'countryName');

  return '$streetNumber $streetAddress\n$city, $region $postal\n$countryName';
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