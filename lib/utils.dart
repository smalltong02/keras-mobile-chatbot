import 'dart:io';
//import 'package:googleapis/speech/v1.dart';
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

final assistantCharacters = <Character>[
  Character(
    title: "Cassie Tunes",
    description:
        "In a cozy corner of Retroland, Cassie Tunes plays heartwarming melodies, whisking listeners back to simpler times with each magnetic note from her vibrant, buttoned facade. 🎶",
    avatar: "assets/icons/9/9_0.png",
    color: 0xFFE83835,
  ),
  Character(
    title: "HappyBot",
    description:
        "HappyBot loved adventures. One day, it found a mysterious garden. There, it met many strange creatures and beautiful plants. HappyBot used its buttons to play music and danced with new friends.",
    avatar: "assets/icons/9/9_1.png",
    color: 0xFF238BD0,
  ),
  Character(
    title: "Little Explorer",
    description:
        "Little Explorer zoomed through space. Its mission: find new stars. Each discovery was shared with Earth, bringing hope and wonder to those gazing up at the night sky.",
    avatar: "assets/icons/9/9_2.png",
    color: 0xFF354C6C,
  ),
  Character(
    title: "Bluebie",
    description:
        "Bluebie, the adorable little robot, was always curious about exploring the world. One day, it found a book in the park. Sitting on a bench, Bluebie became deeply engrossed in the stories within.",
    avatar: "assets/icons/9/9_3.png",
    color: 0xFF6F2B62,
  ),
  Character(
    title: "Blue Ears",
    description:
        "Blue Ears is a puppy living in a village filled with music. Its large ears can hear the faintest sounds and feel the villagers’ joy. Whenever Blue Ears waggles its soft ears, beautiful melodies surround it.",
    avatar: "assets/icons/9/9_4.png",
    color: 0xFF447C12,
  ),
  Character(
    title: "Eye-Eye Beastie",
    description:
        "Eye-Eye Beastie floats in the digital world, capturing information with colorful rings. It spots novelties first, sharing news with electronic companions.",
    avatar: "assets/icons/9/9_5.png",
    color: 0xFFE7668E,
  ),
  Character(
    title: "SweetBot",
    description:
        "In a city filled with technology, SweetBot helps children learn and play every day. Its large eyes twinkle with warmth, always finding ways to make the kids happy.",
    avatar: "assets/icons/9/9_6.png",
    color: 0xFFBD9158,
  ),
  Character(
    title: "Magni-Buddy",
    description:
        "Once upon a time, Magni-Buddy lived in a tech playground, helping kids fix their toys every day and bringing them joy. Magni-Buddy's favorite task was repairing toy cars.",
    avatar: "assets/icons/9/9_7.png",
    color: 0xFFE8A2B6,
  ),
  Character(
    title: "MelodyBot",
    description:
        "MelodyBot, the magical device, not only plays tunes but shifts genres to match the listener's mood. As night falls, MelodyBot soothes souls with its melodies.",
    avatar: "assets/icons/9/9_8.png",
    color: 0xFFC5D128,
  ),
  Character(
    title: "Little Smart Painter",
    description:
        "Little Smart Painter, a robot passionate about art, creates daily in its studio. Its central eye gleams with pride for the beautiful landscape it painted.",
    avatar: "assets/icons/11/1.png",
    color: 0xFF91AF50,
  ),
  Character(
    title: "WittyBot",
    description:
        "WittyBot, a clever robot, always helps friends solve problems. One day, it found a mysterious book and used its wisdom to unlock the secrets within.",
    avatar: "assets/icons/11/2.png",
    color: 0xFF3B7F92,
  ),
  Character(
    title: "Blinky Zoomer",
    description:
        "Blinky Zoomer, the tiny robot with a big eye, loved racing around the garden. Every day, Blinky Zoomer would find new friends among the flowers and insects, sharing stories and playing hide-and-seek until sunset painted the sky in hues matching its colorful stripes.",
    avatar: "assets/icons/11/3.png",
    color: 0xFF6C83AB,
  ),
  Character(
    title: "Little Orange Rotor",
    description:
        "Little Orange Rotor, a friendly helicopter, soars through fluffy clouds against the bright blue sky. Its rotors glisten in the sunlight, bringing joy to children below.",
    avatar: "assets/icons/11/4.png",
    color: 0xFFA1B2C3,
  ),
  Character(
    title: "Colorful Baby",
    description:
        "Colorful Baby, a lively robot, loves chasing butterflies in the garden. As the sun rises, it weaves through flowers with its colorful body, spreading joy to all.",
    avatar: "assets/icons/11/5.png",
    color: 0xFFD4E5F6,
  ),
  Character(
    title: "Little Mech-Pup",
    description:
        "Little Mech-Pup plays daily in the digital world with futuristic gadgets, its antenna always receiving signals of joy.",
    avatar: "assets/icons/11/6.png",
    color: 0xFFFA8072,
  ),
  Character(
    title: "Robo-Cub",
    description:
        "Robo-Cub got lost in the Digital Forest. Every day, it used its shiny eyes to search for the way home. One day, it met the friendly Light Bird who guided it back.",
    avatar: "assets/icons/11/7.png",
    color: 0xFF8A2BE2,
  ),
  Character(
    title: "Music Baby",
    description:
        "Music Baby plays sweet melodies through its headphones every day. The village children dance to the rhythm, filling the air with laughter. MelodyBot became their joyful music companion.",
    avatar: "assets/icons/11/8.png",
    color: 0xFF5F9EA0,
  ),
  Character(
    title: "Melody Bot",
    description:
        "In a world filled with music, Melody Bot explores melodies through its headphones. Each button press unveils a new tale; every beat brings endless joy.",
    avatar: "assets/icons/11/9.png",
    color: 0xFF7FFF00,
  ),
  Character(
    title: "Ears Joy",
    description:
        "Ears Joy loves dancing in the sunshine, its large ears swaying with the music. Everyone is infected by its happiness, joining in the dance.",
    avatar: "assets/icons/11/10.png",
    color: 0xFFD2691E,
  ),
  Character(
    title: "Keras Robot",
    description:
        "Keras Robot always dreamed of exploring outer space. One day, it finally embarked on its journey, weaving through the galaxy dotted with stars, discovering many wondrous planets and unknown mysteries.",
    avatar: "assets/icons/11/11.png",
    color: 0xFFFF7F50,
  ),
  Character(
    title: "Lele Robot",
    description:
        "Lele Robot always carries a smile, playing joyful tunes with its buttons. Everyone who meets it feels happiness and warmth.",
    avatar: "assets/icons/11/12.png",
    color: 0xFF6495ED,
  ),
];

final playerCharacters = <Character>[
  Character(
    title: "Cloud Treasure",
    description:
        "Cloud Treasure floated freely in the sky, meeting twinkling stars and gentle breezes. Each encounter made its smile brighter, spreading joy and love.",
    avatar: "assets/icons/2/2_0.png",
    color: 0xFF86A1F2,
  ),
  Character(
    title: "Blue Bear Meow",
    description:
        "An adventurous kitten in a blue bear-eared hood, encounters various magical creatures in an enchanted forest. Friendship and laughter abound.",
    avatar: "assets/icons/2/2_1.png",
    color: 0xFFB6E3D4,
  ),
  Character(
    title: "Cuddly Catball",
    description:
        "Cuddly Catball held a picnic under the cherry blossoms in spring, sharing joy and treats with friends. Its smile bloomed like the flowers.",
    avatar: "assets/icons/2/2_2.png",
    color: 0xFFD4A7B9,
  ),
  Character(
    title: "Orange Bubble",
    description:
        "Orange Bubble met new friends at the park. They played together, basking in the sunshine. Happy times are fleeting, but friendship lasts forever.",
    avatar: "assets/icons/2/2_3.png",
    color: 0xFF9CD1A8,
  ),
  Character(
    title: "Heartie Koala",
    description:
        "Heartie Koala got lost in the magical forest. It met a talking butterfly that guided it home. Along the way, they sang and danced together, filling the forest with laughter.",
    avatar: "assets/icons/2/2_4.png",
    color: 0xFF97A4C3,
  ),
  Character(
    title: "Leafy Cat",
    description:
        "Leafy Cat loves adventures. One sunny day, Leafy Cat found a magical leaf that could fly. Together, they soared above parks, making new friends everywhere they went.",
    avatar: "assets/icons/2/2_5.png",
    color: 0xFFE9B2CF,
  ),
  Character(
    title: "Leafy Bird",
    description:
        "Leafy Bird loves forest adventures. One day, it found a dazzling crystal cave. The brave Leafy Bird decided to explore and found many sparkling gems.",
    avatar: "assets/icons/2/2_6.png",
    color: 0xFFADC7E8,
  ),
  Character(
    title: "Cloudy Heart",
    description:
        "Cloudy Heart smiles in the sky every day, warming the world with its love. One day, Cloudy Heart met Little Raindrop, and they became best friends. Since then, they travel together sharing happiness and love.",
    avatar: "assets/icons/2/2_7.png",
    color: 0xFFBBEE9F,
  ),
  Character(
    title: "Sweetie Puff",
    description:
        "In a pink sky, Sweetie Puff always carries a warm smile. It hugs the sun with its soft body, bringing light and joy to all. Whenever someone feels sad, Sweetie Puff floats by to comfort them with its cute face and little yellow dots.",
    avatar: "assets/icons/2/2_8.png",
    color: 0xFF8FABC1,
  ),
  Character(
    title: "Bubbly Chat",
    description:
        "In the smartphone world, “Bubbly Chat” was the favorite emoji, always spreading warmth and joy with its sweet voice.",
    avatar: "assets/icons/3/2.png",
    color: 0xFFE4C1D9,
  ),
  Character(
    title: "Blue Heart Speech",
    description:
        "Blue Heart Speech, an energetic messenger of words, always flits joyfully through the library, loving adventures among the sea of books, leaping with excitement at each new discovery.",
    avatar: "assets/icons/3/3.png",
    color: 0xFF74D5E1,
  ),
  Character(
    title: "Bubbly Charm",
    description:
        "Bubbly Charm always loves to help. One day, it met a lost kitten. Bubbly Charm used its speech bubble to show the kitten the way home. The kitten quickly found its way back and gratefully thanked Bubbly Charm.",
    avatar: "assets/icons/3/6.png",
    color: 0xFFA9F1B6,
  ),
  Character(
    title: "Starlight Bubble",
    description:
        "Starlight Bubble shimmers in the sky every night, loving to dance with shooting stars. One day, it decides to explore space and makes many new friends.",
    avatar: "assets/icons/3/12.png",
    color: 0xFFD9B7A3,
  ),
  Character(
    title: "Smiling Talk",
    description:
        "Smiling Talk is a sprite that warms hearts with its smile and words every day. It spreads joy among friends, making everyone’s day sunny.",
    avatar: "assets/icons/3/16.png",
    color: 0xFF85C5A1,
  ),
  Character(
    title: "Blinky Blue",
    description:
        "Blinky Blue lives in an enchanted forest, loving adventures. Today, it met a group of friendly animals, played together, and had a joyful day.",
    avatar: "assets/icons/4/4.png",
    color: 0xFF98B6DD,
  ),
  Character(
    title: "Starry Cloud Baby",
    description:
        "Starry Cloud Baby travels the sky nightly. One day, met Mr. Moon and explored the Milky Way together. Sharing stories, laughter echoed through the night.",
    avatar: "assets/icons/4/14.png",
    color: 0xFFD3A9F4,
  ),
  Character(
    title: "Sweetalk",
    description:
        "In a world where items talk, Sweetalk is most loved. It always spreads joy with its gentle voice, warming hearts. One day, Sweetalk helps a shy bookmark find courage to talk to books.",
    avatar: "assets/icons/14/2.png",
    color: 0xFF9EE7AB,
  ),
  Character(
    title: "Cuddlybot",
    description:
        "Cuddlybot, the adorable robot cat, ventures through the starry sky. It flies past colorful planets, greeting the smiling moon. Every creature it meets is touched by its warmth and kindness.",
    avatar: "assets/icons/14/5.png",
    color: 0xFFC5D1FA,
  ),
  Character(
    title: "Pinky Melody",
    description:
        "Pinky Melody, a musical octopus, always plays the coral keys under the sea. As notes leap, ocean beings gather to admire.",
    avatar: "assets/icons/14/9.png",
    color: 0xFFB0A8EF,
  ),
];

class SettingProvider with ChangeNotifier {
  String _modelName = 'gemini-1.5-pro';
  String _currentRole = 'Keras Robot';
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