import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  String _currentRole = 'Jessica';

  String get currentRole => _currentRole;

  void updateRole(String? newRole) {
    if(newRole != null) {
      _currentRole = newRole;
      notifyListeners();
    }
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