import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Video {
  final String id;
  final String title;
  final String description;
  final String url;

  Video({
    this.id="",
    this.title="",
    this.description="",
    this.url="",
  });
}

class APIService {
  APIService._instantiate();

  static final APIService instance = APIService._instantiate();

  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';

  Future<List<Video>> searchVideos({String title="", int maxResults=4, String apiKey= ""}) async {
    Map<String, String> parameters = {
      'part': 'id,snippet',
      'type': 'video',
      'q': title,
      'maxResults': maxResults.toString(),
      'videoDefinition': 'high',
      'key': apiKey,
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/search',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Videos
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      _nextPageToken = data['nextPageToken'] ?? '';
      List<dynamic> videosJson = data['items'];

      List<Video> videos = [];
      videosJson.forEach(
        (json) => videos.add(
          Video(
            id: json['id']['videoId'],
            title: json['snippet']['title'],
            description: json['snippet']['description'],
            url: 'https://www.youtube.com/watch?v=${json['id']['videoId']}',
          ),
        ),
      );
      return videos;
    }
    return [];
  }
}