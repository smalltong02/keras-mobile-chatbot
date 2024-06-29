import 'dart:convert';
import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:googleapis/drive/v2.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:location/location.dart' as locationpkg;
import 'package:geocode/geocode.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:keras_mobile_chatbot/youtube_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:neom_maps_services/directions.dart';
//import 'package:neom_maps_services/distance.dart';
import 'package:neom_maps_services/geocoding.dart';
//import 'package:neom_maps_services/geolocation.dart';
import 'package:neom_maps_services/places.dart';
//import 'package:neom_maps_services/staticmap.dart';
//import 'package:neom_maps_services/timezone.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/calendar/v3.dart' as gcalendar;
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis/photoslibrary/v1.dart' as gphotos;
import 'package:keras_mobile_chatbot/google_sign.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

Future<Tuple2<double, double>> getGeocode(String address) async {
  String geoKey = dotenv.get("geocode_key");
  GeoCode geoCode = GeoCode(apiKey: geoKey);

  try {
    Coordinates coordinates = await geoCode.forwardGeocoding(
        address: address);

    double lat = coordinates.latitude ?? 0.0;
    double lng = coordinates.longitude ?? 0.0;
    return Tuple2(lat, lng);
  } catch (e) {
    return Tuple2(0.0, 0.0);
  }
}

Future<String> getReverseGeocode(double latitude, double longitude) async {
  GeoCode geoCode = GeoCode();

  try {
    final address = await geoCode.reverseGeocoding(
        latitude: latitude, longitude: longitude);

    return address.toString();
  } catch (e) {
    return "";
  }
}

Future<Map<String, dynamic>> getCurrentTime() async {
  DateTime now = DateTime.now();
  String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  return {
    'result': formattedTime,
  };
}

Future<Tuple2<double, double>> getLocation(String? address) async {
  if (address == null) {
    locationpkg.Location location = new locationpkg.Location();
    bool serviceEnabled;
    locationpkg.PermissionStatus permissionGranted;
    locationpkg.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Tuple2(0.0, 0.0);
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == locationpkg.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != locationpkg.PermissionStatus.granted) {
        return Tuple2(0.0, 0.0);
      }
    }

    locationData = await location.getLocation();
    return Tuple2(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
  } else {
    return getGeocode(address);
  }
}

Future<Map<String, dynamic>> getCurrentLocation() async {
  Tuple2<double, double> location = await getLocation(null);

  final result = await getReverseGeocode(location.item1, location.item2);
  if(result.isEmpty) {
    return {
        'result': "Unknown Address!",
    };
  }
  String address = parseGeocode(result);
  return {
    'result': address,
    'show_map': {
      'object': "position",
      'position': {
        'lat': location.item1,
        'lng': location.item2,
      },
    }
  };
}

TravelMode GetTravelModel(String mode) {
  switch (mode) {
    case "driving":
      return TravelMode.driving;
    case "walking":
      return TravelMode.walking;
    case "bicycling":
      return TravelMode.bicycling;
    case "transit":
      return TravelMode.transit;
    default:
      return TravelMode.driving;
  }
}

Future<Map<String, dynamic>> getDirections(Map<String, Object?> arguments, ) async {

  String resultStr = "";
  try {
    String start = arguments['start'] as String? ?? "";
    String end = arguments['end'] as String? ?? "";
    String mode = arguments['mode'] as String? ?? "";

    String apiKey = dotenv.get("search_key");
    TravelMode travelMode = GetTravelModel(mode);
    GoogleMapsDirections directions = GoogleMapsDirections(apiKey: apiKey);
    DirectionsResponse response = await directions.directionsWithAddress(start, end, travelMode: travelMode,);
    if(response.isOkay) {
      Route route = response.routes[0];
      String summary = route.summary;
      String startAddress = route.legs[0].startAddress;
      Location startLocation = route.legs[0].startLocation;
      String endAddress = route.legs[0].endAddress;
      Location endLocation = route.legs[0].endLocation;
      String distance = route.legs[0].distance.text;
      String duration = route.legs[0].duration.text;
      String overviewPolyline = route.overviewPolyline.points;
      String resultStr = "Starting from '$startAddress', ending at '$endAddress'.the total distance is $distance, and the total time is $duration.The optimal route is to take the '$summary'";
      return {
        'result': resultStr,
        'show_map': {
          'object': "polyline",
          'start_address': startAddress,
          'start_location': startLocation,
          'end_address': endAddress,
          'end_location': endLocation,
          'distance': distance,
          'duration': duration,
          'overview_polyline': overviewPolyline,
          'summary': summary,
        }
      };
    }
    return {
      'result': "Unknown Directions!"
    };
  } catch (e) {
    resultStr = "Failed to get directions. Error: $e";
  }
  return {
    'result': resultStr,
  };
}

String GetPrice(PriceLevel level) {
  switch (level) {
    case PriceLevel.free:
      return "Free";
    case PriceLevel.inexpensive:
      return "Inexpensive";
    case PriceLevel.moderate:
      return "Moderate";
    case PriceLevel.expensive:
      return "Expensive";
    case PriceLevel.veryExpensive:
      return "Very Expensive";
    default:
      return "Unknown";
  }
}

Future<Map<String, dynamic>> getPlaces(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String query = arguments['query'] as String? ?? "";
    String location = arguments['location'] as String? ?? "";
    int radius = arguments['mode'] as int? ?? 100;

    String apiKey = dotenv.get("search_key");
    final geocoding = GoogleMapsGeocoding(apiKey: apiKey);
    Location position = Location(lat: 0, lng: 0);
    if (location.isEmpty) {
      Tuple2<double, double> pos = await getLocation(null);
      position = Location(lat: pos.item1, lng: pos.item2);
    } else {
      GeocodingResponse geoResponse = await geocoding.searchByAddress(location);
      if(geoResponse.isOkay) {
        position = geoResponse.results[0].geometry.location;
      } else {
        return {
          'result': "Unknown Address!",
        };
      }
    }

    final places = GoogleMapsPlaces(apiKey: apiKey);
    PlacesSearchResponse placeResponse = await places.searchByText(query, location: position, radius: radius,);
    if(placeResponse.isOkay) {
      List<PlacesSearchResult> results = placeResponse.results;
      List<Map<String, dynamic>> placesList = [];
      for(PlacesSearchResult result in results) {
        String name = result.name;
        num rating = result.rating ?? 0.0;
        PriceLevel level = result.priceLevel ?? PriceLevel.free;
        String levelStr = GetPrice(level);
        String address = result.formattedAddress ?? "";
        String placeId = result.placeId;
        String icon = result.icon ?? "";
        Location location_l = result.geometry?.location ?? Location(lat: 0, lng: 0);
        placesList.add(
          {
            'name': name,
            'level': levelStr,
            'address': address,
            'place_id': placeId,
            'icon': icon,
            'location': location_l,
          }
        );
        resultStr += "name: $name \naddress: $address \nrating: $rating \nprice: $level\n\n";
      }
      return {
        'result': resultStr,
        'show_map': {
          'object': "places",
          'position': position,
          'places': placesList,
        }
      };
    }
    return {
      'result': "Unknown Places!",
    };
  } catch (e) {
    resultStr = "Failed to get places. Error: $e";
  }
  return {
    'result': resultStr,
  };
}

Future<Map<String, dynamic>> searchVideos(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String title = arguments['title'] as String? ?? "";
    int maxResults = arguments['max_results'] as int? ?? 4;
    String apiKey = dotenv.get("search_key");

    List<Video> videos = await APIService.instance.searchVideos(title: title, maxResults: maxResults, apiKey: apiKey);
    List<Map<String, dynamic>> videoList = [];
    for(Video video in videos) {
      videoList.add(
        {
          'video_id': video.id,
          'title': video.title,
          'description': video.description,
          'url': video.url,
        }
      );
      resultStr += "video_id: ${video.id} \ntitle: ${video.title} \ndescription: ${video.description} \nurl: ${video.url}\n\n";
    }
    return {
      'result': resultStr,
      'show_video': {
        'object': "videos",
        'videos': videoList,
      }
    };
  } catch (e) {
    resultStr = "Failed to search videos. Error: $e";
  }
  return {
    'result': resultStr,
  };
}

Future<Map<String, dynamic>> searchEmails(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String searchCriteria = arguments['search_criteria'] as String? ?? "";
    int maxResults = arguments['max_results'] as int? ?? 4;

    var httpClient = (await googleSignIn.authenticatedClient())!;
    var gmailApi = gmail.GmailApi(httpClient);

    List<gmail.Message> messages = await gmailApi.users.messages.list(
      "me",
      q: searchCriteria,
      maxResults: maxResults,
    ).then((value) => value.messages!);

    for (gmail.Message message in messages) {
      gmail.Message fullMessage = await gmailApi.users.messages.get("me", message.id!);
      String subject = fullMessage.payload!.headers!.firstWhere((header) => header.name == "Subject").value ?? "";
      String from = fullMessage.payload!.headers!.firstWhere((header) => header.name == "From").value ?? "";
      String to = fullMessage.payload!.headers!.firstWhere((header) => header.name == "To").value ?? "";
      String date = fullMessage.payload!.headers!.firstWhere((header) => header.name == "Date").value ?? "";
      String snippet = fullMessage.snippet ?? "";
      String messageId = fullMessage.id ?? "";
      String body = fullMessage.payload!.body!.data ?? "";
      resultStr += "Subject: $subject \nFrom: $from \nTo: $to \nDate: $date \nSnippet: $snippet \nMessage ID: $messageId \nBody: $body\n\n";
    }

    if (resultStr.isEmpty) {
      resultStr = "No emails found.";
    }
  } catch (e) {
    resultStr = "Failed to search email. Error: $e";
  }

  return {
    'result': resultStr,
  };
}

Future<String> addAttachment(String attachmentFile, String subject, String body, String fromAddress, String toAdress) async {
  String content = "";
  if(attachmentFile.isNotEmpty) {
    String attachPath = attachmentFile;
    if(!p.isAbsolute(attachmentFile)) {
      attachPath = await getFileTempPath(attachmentFile);
    }
    if (io.File(attachPath).existsSync()) {
      final file = io.File(attachPath);
      final fileContent = base64Encode(file.readAsBytesSync());
      final mimeType = lookupMimeType(attachmentFile);
      final mimeParts = mimeType?.split('/') ?? ['application', 'octet-stream'];
      final lastMimeType = mimeParts.join('/');

      content = '''
From: $fromAddress
To: $toAdress
Subject: $subject
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="foo_bar_baz"

--foo_bar_baz
Content-Type: text/plain; charset="UTF-8"

$body

--foo_bar_baz
Content-Type: $lastMimeType
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="${file.path.split('/').last}"

$fileContent
--foo_bar_baz--
''';
    }
  }
  if (content.isEmpty) {
    content = "From: $fromAddress\r\n"
              "To: $toAdress\r\n"
              "Subject: $subject\r\n\r\n"
              "$body";
  }
  return content;
}

Future<Map<String, dynamic>> sendEmails(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String subject = arguments['subject'] as String? ?? "";
    String body = arguments['body'] as String? ?? "";
    String toAdress = arguments['to_address'] as String? ?? "";
    String fromAddress = arguments['from_address'] as String? ?? "";
    String attachment = arguments['attachment_file'] as String? ?? "";

    if (fromAddress.isEmpty) {
      fromAddress = "me";
    }

    var httpClient = (await googleSignIn.authenticatedClient())!;
    var gmailApi = gmail.GmailApi(httpClient);

    String emailContent = "";
    if (attachment.isNotEmpty) {
      emailContent = await addAttachment(attachment, subject, body, fromAddress, toAdress);
    } else {
      emailContent = "From: $fromAddress\r\n"
                      "To: $toAdress\r\n"
                      "Subject: $subject\r\n\r\n"
                      "$body";
    }

    gmail.Message message = gmail.Message();
    message.raw = base64Url.encode(utf8.encode(emailContent));
    message = await gmailApi.users.messages.send(message, "me").then((value) => value);
    String id = message.id!;
    resultStr = "Email sent successfully. id=$id";
  } catch (e) {
    resultStr = "Failed to send email. Error: $e";
  }

  return {
    'result': resultStr,
  };
}

Future<Map<String, dynamic>> searchDrives(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String searchCriteria = arguments['search_criteria'] as String? ?? "";
    int maxResults = arguments['max_results'] as int? ?? 4;

    var httpClient = (await googleSignIn.authenticatedClient())!;
    var gdriveApi = gdrive.DriveApi(httpClient);

    var fileList = await gdriveApi.files.list(q: searchCriteria,
                        pageSize: maxResults,
                        $fields: "nextPageToken, files(id, name, size, createdTime, modifiedTime, mimeType, parents)",
                        ).then((value) => value.files!);

      int fileCounts = 1;
      for (var file in fileList) {
        String prefix = "This is file #$fileCounts: \n";
        String name = file.name ?? "";
        String fileName = "File Name: $name \n";
        String id = file.id ?? "";
        String fileId = "File Id: $id \n";
        String size = file.size ?? "0";
        String fileSize = "File Size: $size bytes\n";
        DateTime createTime = file.createdTime ?? DateTime(0);
        String fileCreatedTime = "Created Time: $createTime \n";
        DateTime modifiedTime = file.modifiedTime ?? DateTime(0);
        String fileModifiedTime = "Modified Time: $modifiedTime \n";
        String mimeType = file.mimeType ?? "";
        String fileMimeType = "Mime Type: $mimeType \n";
        if (resultStr.isNotEmpty) {
            resultStr += "\n\n";
        }
        resultStr += "$prefix$fileName$fileId$fileSize$fileCreatedTime$fileModifiedTime$fileMimeType";
        if (fileCounts >= maxResults) {
            break;
        }
        fileCounts += 1;
      }
  } catch (e) {
    resultStr = "Failed to search documents. Error: $e";
  }

  if (resultStr.isEmpty) {
    resultStr = "No documents found.";
  }
  return {
    'result': resultStr,
  };
}

Future<String> getMedia(gdrive.DriveApi gdriveApi, String fileId, String filepath) async {
  Object media = await gdriveApi.files.get(fileId, downloadOptions: DownloadOptions.fullMedia);

  if (media is Media) {
    final file = io.File(filepath);
    final mediaStream = media.stream;
    final fileSink = file.openWrite();
    await mediaStream.pipe(fileSink);
    await fileSink.close();
    return filepath;
  }
  else {
    return "";
  }
}

Future<String> exportMedia(gdrive.DriveApi gdriveApi, String fileId, String mimeType, String filePath) async {
    List<String> parts = mimeType.split('/');
    if(parts.length != 2) {
      return "";
    }
    String fileName = '$filePath.${parts[1]}';
    Media? media = await gdriveApi.files.export(fileId, mimeType, downloadOptions: DownloadOptions.fullMedia);

    if (media != null) {
    final file = io.File(fileName);
    final mediaStream = media.stream.asBroadcastStream();
    final fileSink = file.openWrite();
    await mediaStream.pipe(fileSink);
    await fileSink.close();
    return fileName;
  }
  else {
    return "";
  }
}

Future<Map<String, dynamic>> downloadFromDrives(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String searchCriteria = arguments['search_criteria'] as String? ?? "";
    int maxResults = arguments['max_results'] as int? ?? 4;

    var httpClient = (await googleSignIn.authenticatedClient())!;
    gdrive.DriveApi gdriveApi = gdrive.DriveApi(httpClient);

    var fileList = await gdriveApi.files.list(q: searchCriteria,
                        pageSize: maxResults,
                        $fields: "nextPageToken, files(id, name, size, createdTime, modifiedTime, mimeType, parents)",
                        ).then((value) => value.files!);

      for (var file in fileList) {
        String id = file.id ?? "";
        String fileName = file.name ?? "";
        String mimeType = file.mimeType ?? "";
        String filePath = await getFileTempPath(fileName);

        Map<String, String>? matchedEntry;
        for (var entry in googleDocsTypes) {
          if (entry.containsKey(mimeType)) {
            matchedEntry = entry;
            break;
          }
        }

        if (matchedEntry != null) {
          List<String> values = matchedEntry.values.toList();
          filePath = await exportMedia(gdriveApi, id, values[0], filePath);
        } else {
          filePath = await getMedia(gdriveApi, id, filePath);
        }
        if (resultStr.isNotEmpty) {
          resultStr += "\n\n";
        }
        resultStr += "file '$filePath' downloaded successfully.";
      }
  } catch (e) {
    resultStr = "Failed to download from drives. Error: $e";
    print(e);
  }

  if (resultStr.isEmpty) {
    resultStr = "No documents found.";
  }
  return {
    'result': resultStr,
  };
}

Future<Map<String, dynamic>> getEventCalendar(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String startTime = arguments['start_time'] as String? ?? "";
    String endTime = arguments['end_time'] as String? ?? "";

    var httpClient = (await googleSignIn.authenticatedClient())!;
    gcalendar.CalendarApi gcalendarApi = gcalendar.CalendarApi(httpClient);

    DateTime? rfc3339Start = await convertTimeToRFC3339Time(startTime);
    DateTime? rfc3339End = await convertTimeToRFC3339Time(endTime);

    gcalendar.Events eventsResult = await gcalendarApi.events.list("primary", timeMin: rfc3339Start, timeMax: rfc3339End, maxResults: 10, singleEvents: true, orderBy: "startTime");
    List<gcalendar.Event> events = eventsResult.items ?? [];

    int eventCounts = 1;
    for (var event in events) {
      String eventName = event.summary ?? "";
      String htmlLink = event.htmlLink ?? "";
      String eventDescription = event.description ?? "";
      String eventLocation = event.location ?? "";
      DateTime eventStartTime = event.start?.dateTime ?? DateTime(0);
      String eventStartZone = event.start?.timeZone ?? "";
      DateTime eventEndTime = event.end?.dateTime ?? DateTime(0);
      String eventEndZone = event.end?.timeZone ?? "";
      final startZone = tz.getLocation(eventStartZone);
      final endZone = tz.getLocation(eventEndZone);
      final tz.TZDateTime startDateTime = tz.TZDateTime.from(eventStartTime, startZone);
      final tz.TZDateTime endDateTime = tz.TZDateTime.from(eventEndTime, endZone);
      if (resultStr.isNotEmpty) {
        resultStr += "\n\n";
      }
      String prefix = "This is event #$eventCounts: \n";
      String start = "Start Time: $startDateTime \n";
      String end = "End Time: $endDateTime \n";
      String summary = "Summary: $eventName \n";
      String description = "description: $eventDescription \n";
      String location = "Location: $eventLocation \n";
      htmlLink = "htmlLink: $htmlLink \n";
      if (resultStr.isNotEmpty) {
        resultStr += "\n\n";
      }
      resultStr += prefix + start + end + summary + description + location + htmlLink;
      eventCounts += 1;
    }

  } catch (e) {
    resultStr = "Failed to get event from calendar. Error: $e";
    print(e);
  }

  if (resultStr.isEmpty) {
    resultStr = "No events found from calendar.";
  }
  return {
    'result': resultStr,
  };
}

Future<Map<String, dynamic>> createEventCalendar(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String summary = arguments['summary'] as String? ?? "";
    String description = arguments['description'] as String? ?? "";
    String startTime = arguments['start_time'] as String? ?? "";
    String endTime = arguments['end_time'] as String? ?? "";

    var httpClient = (await googleSignIn.authenticatedClient())!;
    gcalendar.CalendarApi gcalendarApi = gcalendar.CalendarApi(httpClient);

    DateTime? eventStartTime = await convertTimeToRFC3339Time(startTime);
    DateTime? eventEndTime = await convertTimeToRFC3339Time(endTime);
    if(eventStartTime == null || eventEndTime == null){
      return {
        'result': "Failed to create event from calendar. Error: Invalid start or end time.",
      };
    }

    gcalendar.Event event = gcalendar.Event(
      summary: summary,
      description: description,
      start: gcalendar.EventDateTime(dateTime: eventStartTime),
      end: gcalendar.EventDateTime(dateTime: eventEndTime),
    );

    gcalendar.Event newEvent = await gcalendarApi.events.insert(event, 'primary');
    String htmlLink = newEvent.htmlLink ?? "";
    resultStr = "Event created success, Please refer to the following link: \n\n $htmlLink";
  } catch (e) {
    resultStr = "Failed to create event from calendar. Error: $e";
    print(e);
  }

  if (resultStr.isEmpty) {
    resultStr = "No events created in calendar.";
  }
  return {
    'result': resultStr,
  };
}

Future<Map<String, dynamic>> searchPhotos(Map<String, Object?> arguments, ) async {
  String resultStr = "";
  try {
    String albumsName = arguments['albums_name'] as String? ?? "";
    int maxResults = arguments['max_results'] as int? ?? 10;
    
    var httpClient = (await googleSignIn.authenticatedClient())!;
    gphotos.PhotosLibraryApi gphotosApi = gphotos.PhotosLibraryApi(httpClient);

    List<gphotos.Album> albums = await gphotosApi.albums.list().then((value) => value.albums ?? []);
    
    String albumId = "";
    for (gphotos.Album album in albums) {
      String title = album.title ?? "";
      bool isSubstring = albumsName.toLowerCase().contains(title.toLowerCase());
      if (isSubstring) {
        albumId = album.id ?? "";
        break;
      }
    }

    if (albumId.isEmpty) {
      return {
        'result': "Failed to search in google photos. Error: Album not found.",
      };
    }
    int photoIndex = 1;
    List<Map<String, String>> photosList = [];
    List<gphotos.MediaItem> mediaItems = await gphotosApi.mediaItems.search(gphotos.SearchMediaItemsRequest(albumId: albumId, pageSize: maxResults)).then((value) => value.mediaItems ?? []);
    for (gphotos.MediaItem mediaItem in mediaItems) {
      String fileName = mediaItem.filename ?? "";
      String description = mediaItem.description ?? "";
      String creationTime = mediaItem.mediaMetadata!.creationTime ?? "";
      String url = mediaItem.baseUrl ?? "";
      String mimeType = mediaItem.mimeType ?? "";
      if (mimeType.toLowerCase().contains("image")) {
        String filePath = await getFileTempPath(fileName);
        String downloadPath = await downloadAndSaveImage(url, filePath);
        if(downloadPath.isNotEmpty) {
          photosList.add(
            {
              'name': fileName,
              'description': description,
              'creation_time': creationTime,
              'imgpath': downloadPath,
            }
          );
          if(resultStr.isNotEmpty) {
            resultStr += "\n\n";
          }
          resultStr += '''
            photo #$photoIndex
            filename: $fileName
            description: $description
            creationTime: $creationTime
            imgpath: $downloadPath
            ''';
          photoIndex +=1;
        }
      }
    }
    return {
      'result': resultStr,
      'show_image': {
        'object': "images",
        'images': photosList,
      }
    };
  } catch (e) {
    resultStr = "Failed to search in google photos. Error: $e";
    print(e);
  }

  if (resultStr.isEmpty) {
    resultStr = "No photo in google photos.";
  }
  return {
    'result': resultStr,
  };

}

final getCurrentTimeFunc = FunctionDeclaration(
    'getCurrentTime',
    'Get the current local time.',
    null
    );
    
final getCurrentLocationFunc = FunctionDeclaration(
    'getCurrentLocation',
    'Get the current location information.',
    null
    );

final getDirectionsFunc = FunctionDeclaration(
    'getDirections',
    'Get the directions from origin to destination.',
    Schema(SchemaType.object, properties: {
      "start": Schema(SchemaType.string, description: "Starting address, When the location is "", it means that you are in the current location."),
      "end": Schema(SchemaType.string, description: "Destination address."),
      "mode": Schema(SchemaType.string, description: "Specifies the mode of transport to use when calculating directions. One of 'driving', 'walking', 'bicycling' or 'transit'."),
    }));

final getPlacesFunc = FunctionDeclaration(
    'getPlaces',
    'Get the places that match the query, such as restaurants, libraries, parks, airports, stores, etc.',
    Schema(SchemaType.object, properties: {
      "query": Schema(SchemaType.string, description: "The text string on which to search, for example: 'restaurant'."),
      "location": Schema(SchemaType.string, description: "location, When the location is "", it means that you are in the current location."),
      "radius": Schema(SchemaType.number, description: "Distance in meters within which to bias results."),
    }));

final searchVideosFunc = FunctionDeclaration(
    'searchVideos',
    'Get URL about Youtube video from Youtube.',
    Schema(SchemaType.object, properties: {
      "title": Schema(SchemaType.string, description: "Use the advanced search syntax like the Youtube API, Here's an example: 'Language Translation'"),
      //"max_results": Schema(SchemaType.number, description: "The number of returned videos."),
    }));

final searchEmailsFunc = FunctionDeclaration(
    'searchEmails',
    "Find email in Gmail inbox. The parameter 'search_criteria' conforms to gmail's advanced search syntax format.",
    Schema(SchemaType.object, properties: {
      "search_criteria": Schema(SchemaType.string, description: "conforms to email's advanced search syntax format."),
      "max_results": Schema(SchemaType.number, description: "The number of returned emails."),
    }));

final sendEmailsFunc = FunctionDeclaration(
    'sendEmails',
    "Send emails from my inbox to others.",
    Schema(SchemaType.object, properties: {
      "subject": Schema(SchemaType.string, description: "Title of the email."),
      "body": Schema(SchemaType.string, description: "Body of the email."),
      "to_address": Schema(SchemaType.string, description: "The address to receive the email, if not provided, needs to be confirmed by the user."),
      "from_address": Schema(SchemaType.string, description: "The sending address of the email, if using the default address, can be replaced with 'me'."),
      "attachment_file": Schema(SchemaType.string, description: "The attachment parameter can be a file path. If there are no attachments, please pass ""."),
    }));

final searchDrivesFunc = FunctionDeclaration(
    'searchDrives',
    "Search document in Google Drive.",
    Schema(SchemaType.object, properties: {
      "search_criteria": Schema(SchemaType.string, description: '''Use the advanced search syntax like the Google Drive API, Here's an example: name contains "HipsHook Project" and "me" in owners.'''),
      "max_results": Schema(SchemaType.number, description: "The number of returned documents."),
    }));

final downloadFromDrivesFunc = FunctionDeclaration(
    'downloadFromDrives',
    "Download document from Google Drive.",
    Schema(SchemaType.object, properties: {
      "search_criteria": Schema(SchemaType.string, description: '''Use the advanced search syntax like the Google Drive API, Here's an example: name contains "HipsHook Project" and "me" in owners.'''),
      "max_results": Schema(SchemaType.number, description: "The number of returned documents."),
    }));

final getEventCalendarFunc = FunctionDeclaration(
    'getEventCalendar',
    "get event from calendar.",
    Schema(SchemaType.object, properties: {
      "start_time": Schema(SchemaType.string, description: '''This is start time. If the user provides a date and time, then the format “2024-06-01T08:00:00” can be used. If only the time is provided, but the date is today, then the format “08:00:00” can be used. If the date or time are not available, you need to ask the user to provide them.'''),
      "end_time": Schema(SchemaType.string, description: '''This is end time. If the user provides a date and time, then the format “2024-06-01T08:00:00” can be used. If only the time is provided, but the date is today, then the format “08:00:00” can be used. If the date or time are not available, you need to ask the user to provide them.'''),
    }));

final createEventCalendarFunc = FunctionDeclaration(
    'createEventCalendar',
    "create a new event reminder to calendar.",
    Schema(SchemaType.object, properties: {
      "summary": Schema(SchemaType.string, description: '''Title of the event reminder.'''),
      "description": Schema(SchemaType.string, description: '''Brief description of the event reminder.'''),
      "start_time": Schema(SchemaType.string, description: '''This is start time. If the user provides a date and time, then the format “2024-06-01T08:00:00” can be used. If only the time is provided, but the date is today, then the format “08:00:00” can be used. If the date or time are not available, you need to ask the user to provide them.'''),
      "end_time": Schema(SchemaType.string, description: '''This is end time. If the user provides a date and time, then the format “2024-06-01T08:00:00” can be used. If only the time is provided, but the date is today, then the format “08:00:00” can be used. If the date or time are not available, you need to ask the user to provide them.'''),
    }));

final searchPhotosFunc = FunctionDeclaration(
    'searchPhotos',
    "Search and download for photos on Photos Album.",
    Schema(SchemaType.object, properties: {
      "albums_name": Schema(SchemaType.string, description: '''The name of the album will be used to search for photos within the album.'''),
      "max_items": Schema(SchemaType.number, description: '''The maximum number of results to return photos.'''),
    }));
 

final normalFunctionCallTool = [getCurrentTimeFunc, getCurrentLocationFunc, getDirectionsFunc, getPlacesFunc, searchVideosFunc, searchEmailsFunc, sendEmailsFunc, searchDrivesFunc, downloadFromDrivesFunc, getEventCalendarFunc, createEventCalendarFunc, searchPhotosFunc];