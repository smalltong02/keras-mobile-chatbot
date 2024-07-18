import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;
import 'l10n/localization_intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:neom_maps_services/timezone.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class CustomShape extends CustomPainter {
  final Color bgColor;

  CustomShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;
    var path = Path();

    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class EditableTextWithLinks extends StatefulWidget {
  final String message;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;

  const EditableTextWithLinks({
    Key? key,
    required this.message,
    required this.fontSize,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  _EditableTextWithLinksState createState() => _EditableTextWithLinksState();
}

class _EditableTextWithLinksState extends State<EditableTextWithLinks> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = widget.message;
  }

  void launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: textController.text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(DemoLocalizations.of(context).textCopyClipboard)),
        );
      },
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                backgroundColor: widget.backgroundColor,
              ),
              children: _buildTextSpans(textController.text),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String text) {
    final RegExp urlRegex = RegExp(
      r'((https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?)',
      caseSensitive: false,
    );

    final List<TextSpan> spans = [];
    final matches = urlRegex.allMatches(text);

    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      final url = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()..onTap = () => launchURL(url),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}

class SentMessageScreen extends StatelessWidget {
  final String message;
  final Map<String, dynamic> extendMessage;
  final String iconPath;

  static const double _paddingHorizontal = 18.0;
  static const double _paddingVertical = 15.0;
  static const double _messagePaddingAll = 14.0;
  static const double _iconSize = 40.0;
  static const double _messageFontSize = 14.0;
  static const Color _messageBackgroundColor = Colors.cyan;
  static const Color _messageTextColor = Colors.white;

  const SentMessageScreen({
    super.key,
    required this.message,
    required this.extendMessage,
    required this.iconPath,
  });

  Future<bool> saveImage(String filePath) async {
    final result = await ImageGallerySaver.saveFile(filePath);
    //print(result);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(_messagePaddingAll),
              decoration: const BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: EditableTextWithLinks(message: message, fontSize: _messageFontSize, textColor: _messageTextColor, backgroundColor: _messageBackgroundColor,),
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            iconPath,
            width: _iconSize,
            height: _iconSize,
          ),
        ],
      ));

    List<Widget> extendMessageGroupList = [];

    if (extendMessage.containsKey('show_image')) {
      Map<String, dynamic> showImage = extendMessage['show_image'];
      if (showImage['object'] == 'images') {
        List<Map<String, dynamic>> imagesList = showImage['images'];
        if (imagesList.isNotEmpty) {
          for(Map<String, dynamic> image in imagesList) {
            String imgPath = image['imgpath'];
            extendMessageGroupList.add(Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(DemoLocalizations.of(context).imageSaveToPhotos),
                                content: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Center(
                                    child: Image.file(io.File(imgPath)),
                                  ),
                                ),
                                actions: <Widget>[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: 
                                          ElevatedButton(
                                            onPressed: () async {
                                              bool bSuccess = await saveImage(imgPath);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    backgroundColor: bSuccess ? Colors.green[50] : Colors.red[50],
                                                    title: Row(
                                                      children: [
                                                        Icon(
                                                          bSuccess ? Icons.check_circle : Icons.error,
                                                          color: bSuccess ? Colors.green : Colors.red,
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          bSuccess ? DemoLocalizations.of(context).saveSuccess : DemoLocalizations.of(context).saveFailed,
                                                          style: TextStyle(
                                                            color: bSuccess ? Colors.green : Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: Text(
                                                      bSuccess ? DemoLocalizations.of(context).saveSuccessDetail : DemoLocalizations.of(context).saveFailedDetail,
                                                      style: TextStyle(
                                                        color: bSuccess ? Colors.green[700] : Colors.red[700],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            color: bSuccess ? Colors.green : Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                              elevation: 10,
                                              backgroundColor: Colors.pinkAccent.withOpacity(0.6),
                                            ),
                                            child: Text(DemoLocalizations.of(context).saveBtn),
                                          ),
                                        )
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: 
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(24),
                                              ),
                                              elevation: 10,
                                              backgroundColor: Colors.amberAccent.withOpacity(0.6),
                                            ),
                                            child: Text(DemoLocalizations.of(context).cancelBtn),
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          );
                        },
                        child: Image.file(io.File(imgPath)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    iconPath,
                    width: _iconSize,
                    height: _iconSize,
                  ),
                ],
              ))
            );
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: _paddingHorizontal, left: 50, top: _paddingVertical, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const SizedBox(height: 30),
              messageTextGroup,
            ],
          ),
          if(extendMessageGroupList.isNotEmpty) ...{
            for(Widget extendMessageGroup in extendMessageGroupList) ...{
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(height: 30),
                  extendMessageGroup,
                ],
              ),
            }
          }
        ],
      )
    );
  }
}

class ReceivedMessageScreen extends StatefulWidget {
  final String message;
  final Map<String, dynamic> extendMessage;
  final String audioPath;
  final bool autoPlay;
  final String iconPath;

  const ReceivedMessageScreen({
    super.key,
    required this.message,
    required this.extendMessage,
    required this.audioPath,
    required this.autoPlay,
    required this.iconPath,
  });

  @override
  _ReceivedMessageScreenState createState() => _ReceivedMessageScreenState();
}

class _ReceivedMessageScreenState extends State<ReceivedMessageScreen> {
  static const double _paddingHorizontal = 18.0;
  static const double _paddingVertical = 10.0;
  static const double _messagePaddingAll = 14.0;
  static const double _iconSize = 40.0;
  static const double _messageFontSize = 14.0;
  static const Color _messageBackgroundColor = Colors.grey;
  static const Color _messageTextColor = Colors.black;

  audio.AudioPlayer? audioPlayer;
  bool hasPlayed = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    hasPlayed = !widget.autoPlay;
    audioPlayer = audio.AudioPlayer();
    audioPlayer!.onPlayerStateChanged.listen((state) {
    if (state == audio.PlayerState.stopped || state == audio.PlayerState.completed) {
      setState(() {
        isPlaying = false;
      });
      }
    });
  }

  @override
  void dispose() {
    stopAudio();
    super.dispose();
  }

  Future<void> playAudioFile(String audioPath) async {
    if(audioPath.isEmpty) {
      return;
    }
    if (audioPlayer != null && !isPlaying && !hasPlayed) {
      isPlaying = true;
      audioPlayer!.setReleaseMode(audio.ReleaseMode.stop);
      await audioPlayer!.setSourceDeviceFile(audioPath);
      await audioPlayer!.resume();
      setState(() {
        hasPlayed = true;
      });
    }
  }

  void stopAudio() async {
    if(audioPlayer != null && isPlaying == true) {
      await audioPlayer!.stop();
      setState(() {
        hasPlayed = true;
        isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            widget.iconPath,
            width: _iconSize,
            height: _iconSize,
          ),
          const SizedBox(width: 4),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: CustomPaint(
              painter: CustomShape(_messageBackgroundColor),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(_messagePaddingAll),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: EditableTextWithLinks(message: widget.message, fontSize: _messageFontSize, textColor: _messageTextColor, backgroundColor: _messageBackgroundColor,),
            ),
          ),
        ],
      )
    );

    List<Widget> extendMessageGroupList = [];

    if (widget.extendMessage.containsKey('show_map')) {
      Map<String, dynamic> showMap = widget.extendMessage['show_map'];
      if (showMap['object'] == 'position') {
        double lat = showMap['position']['lat'];
        double lng = showMap['position']['lng'];
        Set<Marker> markers = {};
        final marker = Marker(
          markerId: const MarkerId('Your location'),
          position: LatLng(lat, lng),
          infoWindow: const InfoWindow(
            title: 'Your location',
          ),
        );
        markers.add(marker);
        extendMessageGroupList.add(Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                widget.iconPath,
                width: _iconSize,
                height: _iconSize,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 12,
                    ),
                    markers: markers,
                    // Ensure that gestures work properly
                    gestureRecognizers: Set()
                    ..add(Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer())),
                  ),
                ),
              ),
            ],
          ))
        );
      }
      else if (showMap['object'] == 'polyline') {
        String startAddress = showMap['start_address'];
        Location startLocation = showMap['start_location'];
        String endAddress = showMap['end_address'];
        Location endLocation = showMap['end_location'];
        //String distance = showMap['distance'];
        //String duration = showMap['duration'];
        String overviewPolyline = showMap['overview_polyline'];
        // Decode the polyline string to a list of LatLng coordinates
        PolylinePoints polylinePoints = PolylinePoints();
        List<PointLatLng> pointList = polylinePoints.decodePolyline(overviewPolyline);
        List<LatLng?> polylineCoordinates = [];
        pointList.forEach((point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        List<LatLng> nonNullPolylineCoordinates = polylineCoordinates.where((element) => element != null).cast<LatLng>().toList();
        var polylines = generatePolyLineFromPoints(nonNullPolylineCoordinates);
        Set<Marker> markers = {};
        final markerStart = Marker(
          markerId: const MarkerId('Start'),
          position: LatLng(startLocation.lat, startLocation.lng),
          infoWindow: InfoWindow(
            title: startAddress,
          ),
        );
        markers.add(markerStart);

        final markerEnd = Marker(
          markerId: const MarkerId('End'),
          position: LatLng(endLocation.lat, endLocation.lng),
          infoWindow: InfoWindow(
            title: endAddress,
          ),
        );
        markers.add(markerEnd);
        extendMessageGroupList.add(Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                widget.iconPath,
                width: _iconSize,
                height: _iconSize,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: polylineCoordinates[0] ?? const LatLng(0.0, 0.0),
                      zoom: 12,
                    ),
                    markers: markers,
                    polylines: Set<Polyline>.of(polylines.values),
                    // Ensure that gestures work properly
                    gestureRecognizers: Set()
                    ..add(Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer())),
                  ),
                ),
              ),
            ],
          ))
        );
      }
      else if (showMap['object'] == 'places') {
        Set<Marker> markers = {};
        String location = showMap['location'];
        Location position = showMap['position'];
        final markerPos = Marker(
          markerId: const MarkerId("Start"),
          position: LatLng(position.lat, position.lng),
          infoWindow: InfoWindow(
            title: location,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed
          ),
        );
        markers.add(markerPos);
        List<Map<String, dynamic>> placesList = showMap['places'];
        for(Map<String, dynamic> place in placesList) {
          String name = place['name'];
          //String level = place['level'];
          //String address = place['address'];
          //String placeId = place['place_id'];
          //String icon = place['icon'];
          Location location = place['location'];
          final marker = Marker(
            markerId: MarkerId(name),
            position: LatLng(location.lat, location.lng),
            infoWindow: InfoWindow(
              title: name,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow
            ),
          );
          markers.add(marker);
        }
        extendMessageGroupList.add(Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                widget.iconPath,
                width: _iconSize,
                height: _iconSize,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(position.lat, position.lng),
                      zoom: 12,
                    ),
                    markers: markers,
                    // Ensure that gestures work properly
                    gestureRecognizers: Set()
                    ..add(Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer())),
                  ),
                ),
              ),
            ],
          ))
        );
      } 
    }
    else if (widget.extendMessage.containsKey('show_video')) {
      Map<String, dynamic> showVideo = widget.extendMessage['show_video'];
      if (showVideo['object'] == 'videos') {
        List<Map<String, dynamic>> videosList = showVideo['videos'];
        if (videosList.isNotEmpty) {
          for (Map<String, dynamic> video in videosList) {
            String videoTitle = video['title'];
            String videoId = video['video_id'];
            String videoDescription = video['description'];
            String thumbnailUrl = video['thumbnail'];

            YoutubePlayerController controllerYoutube = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            );

            extendMessageGroupList.add(Flexible(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        insetPadding: const EdgeInsets.all(0),
                        child: Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            title: Text(
                              videoTitle,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            centerTitle: true,
                            flexibleSpace: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.blue, Colors.purple],
                                ),
                              ),
                            ),
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          body: Column(
                            children: [
                              Expanded(
                                child: YoutubePlayer(
                                  controller: controllerYoutube,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: Colors.amber,
                                  progressColors: const ProgressBarColors(
                                    playedColor: Colors.amber,
                                    handleColor: Colors.amberAccent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade100, Colors.purple.shade100],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    videoDescription,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 12,
                                      color: Colors.grey[800],
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      thumbnailUrl,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    const Icon(
                      Icons.play_circle_fill,
                      size: 64,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ));
          }
        }
      }
    }
    else if (widget.extendMessage.containsKey('show_image')) {
      Map<String, dynamic> showVideo = widget.extendMessage['show_image'];
      if (showVideo['object'] == 'images') {
        List<Map<String, dynamic>> imagesList = showVideo['images'];
        if (imagesList.isNotEmpty) {
          for(Map<String, dynamic> image in imagesList) {
            //String imageName = image['name'];
            //String imageDescription = image['description'];
            //String imageCreationTime = image['creation_time'];
            String imgPath = image['imgpath'];
            extendMessageGroupList.add(Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    widget.iconPath,
                    width: _iconSize,
                    height: _iconSize,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Center(
                                  child: Image.file(io.File(imgPath)),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.file(io.File(imgPath)),
                      ),
                    ),
                  ),
                ],
              ))
            );
          }
        }
      }
    }
    playAudioFile(widget.audioPath);
    return Padding(
      padding: const EdgeInsets.only(right: 50.0, left: _paddingHorizontal, top: _paddingVertical, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const SizedBox(height: 30),
              messageTextGroup,
              if(widget.audioPath.isNotEmpty) ...{
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.stop : Icons.volume_up,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      stopAudio();
                    } else {
                      hasPlayed = false;
                      playAudioFile(widget.audioPath);
                    }
                  },
                ),
              }
            ],
          ),
          if(extendMessageGroupList.isNotEmpty) ...{
            for(Widget extendMessageGroup in extendMessageGroupList) ...{
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(height: 30),
                  extendMessageGroup,
                ],
              ),
            }
          }
        ],
      ),
    );
  }

  Map<PolylineId, Polyline> generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      consumeTapEvents: true,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 8,
    );
    Map<PolylineId, Polyline> polylines = {};
    polylines[id] = polyline;
    return polylines;
  }
}