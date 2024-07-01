import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:neom_maps_services/timezone.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

class SentMessageScreen extends StatelessWidget {
  final String message;
  final String iconPath;

  static const double _paddingHorizontal = 18.0;
  static const double _paddingVertical = 15.0;
  static const double _messagePaddingAll = 14.0;
  static const double _iconSize = 40.0;
  static const double _messageFontSize = 14.0;
  static const Color _messageBackgroundColor = Colors.cyan;
  static const Color _messageTextColor = Colors.white;

  const SentMessageScreen({
    Key? key,
    required this.message,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(_messagePaddingAll),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: _messageTextColor, fontSize: _messageFontSize),
                ),
              ),
            ),
            CustomPaint(painter: CustomShape(_messageBackgroundColor)),
            SizedBox(width: 4),
            Image.asset(
              iconPath,
              width: _iconSize,
              height: _iconSize,
            ),
          ],
        ));

    return Padding(
      padding: EdgeInsets.only(right: _paddingHorizontal, left: 50, top: _paddingVertical, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}

class ReceivedMessageScreen extends StatelessWidget {
  final String message;
  final Map<String, dynamic> extendMessage;
  final String iconPath;

  static const double _paddingHorizontal = 18.0;
  static const double _paddingVertical = 10.0;
  static const double _messagePaddingAll = 14.0;
  static const double _iconSize = 40.0;
  static const double _messageFontSize = 14.0;
  static const Color _messageBackgroundColor = Colors.grey;
  static const Color _messageTextColor = Colors.black;

  const ReceivedMessageScreen({
    Key? key,
    required this.message,
    required this.extendMessage,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: _iconSize,
              height: _iconSize,
            ),
            SizedBox(width: 4),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: CustomPaint(
                painter: CustomShape(_messageBackgroundColor),
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(_messagePaddingAll),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: _messageTextColor, fontSize: _messageFontSize),
                ),
              ),
            ),
          ],
        ));

    List<Widget> extendMessageGroupList = [];

    if (extendMessage.containsKey('show_map')) {
      Map<String, dynamic> showMap = extendMessage['show_map'];
      if (showMap['object'] == 'position') {
        double lat = showMap['position']['lat'];
        double lng = showMap['position']['lng'];
        Set<Marker> _markers = {};
        final marker = Marker(
          markerId: MarkerId('Your location'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: 'Your location',
          ),
        );
        _markers..add(marker);
        extendMessageGroupList.add(Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                iconPath,
                width: _iconSize,
                height: _iconSize,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 12,
                    ),
                    markers: _markers,
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
        String distance = showMap['distance'];
        String duration = showMap['duration'];
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
        Set<Marker> _markers = {};
        final markerStart = Marker(
          markerId: MarkerId('Start'),
          position: LatLng(startLocation.lat, startLocation.lng),
          infoWindow: InfoWindow(
            title: startAddress,
          ),
        );
        _markers.add(markerStart);

        final markerEnd = Marker(
          markerId: MarkerId('End'),
          position: LatLng(endLocation.lat, endLocation.lng),
          infoWindow: InfoWindow(
            title: endAddress,
          ),
        );
        _markers.add(markerEnd);
        extendMessageGroupList.add(Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                iconPath,
                width: _iconSize,
                height: _iconSize,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: polylineCoordinates[0] ?? LatLng(0.0, 0.0),
                      zoom: 12,
                    ),
                    markers: _markers,
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
        Set<Marker> _markers = {};
        String location = showMap['location'];
        Location position = showMap['position'];
        final marker_pos = Marker(
          markerId: MarkerId("Start"),
          position: LatLng(position.lat, position.lng),
          infoWindow: InfoWindow(
            title: location,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed
          ),
        );
        _markers.add(marker_pos);
        List<Map<String, dynamic>> placesList = showMap['places'];
        for(Map<String, dynamic> place in placesList) {
          String name = place['name'];
          String level = place['level'];
          String address = place['address'];
          String placeId = place['place_id'];
          String icon = place['icon'];
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
          _markers.add(marker);
        }
        extendMessageGroupList.add(Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                iconPath,
                width: _iconSize,
                height: _iconSize,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(position.lat, position.lng),
                      zoom: 12,
                    ),
                    markers: _markers,
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
    else if (extendMessage.containsKey('show_video')) {
      Map<String, dynamic> showVideo = extendMessage['show_video'];
      if (showVideo['object'] == 'videos') {
        List<Map<String, dynamic>> videosList = showVideo['videos'];
        if (videosList.isNotEmpty) {
          for(Map<String, dynamic> video in videosList) {
            String videoTitle = video['title'];
            String videoId = video['video_id'];
            String videoDescription = video['description'];
            String videoUrl = video['url'];
            YoutubePlayerController controllerYoutube = YoutubePlayerController(
              initialVideoId: videoId,
              flags: YoutubePlayerFlags(
                  autoPlay: false,
                  mute: true,
              ),
            );

            YoutubePlayer player = YoutubePlayer(
              controller: controllerYoutube,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
              progressColors: const ProgressBarColors(
                playedColor: Colors.amber,
                handleColor: Colors.amberAccent,
              ),
              onReady: () {
                //_controller.addListener(listener);
              },
            );
            extendMessageGroupList.add(Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    iconPath,
                    width: _iconSize,
                    height: _iconSize,
                  ),
                  SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      child: player,
                    ),
                  ),
                ],
              ))
            );
          }
        }
      }
    }
    else if (extendMessage.containsKey('show_image')) {
      Map<String, dynamic> showVideo = extendMessage['show_image'];
      if (showVideo['object'] == 'images') {
        List<Map<String, dynamic>> imagesList = showVideo['images'];
        if (imagesList.isNotEmpty) {
          for(Map<String, dynamic> image in imagesList) {
            String imageName = image['name'];
            String imageDescription = image['description'];
            String imageCreationTime = image['creation_time'];
            String imgPath = image['imgpath'];
            extendMessageGroupList.add(Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    iconPath,
                    width: _iconSize,
                    height: _iconSize,
                  ),
                  SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      child: Image.file(io.File(imgPath)),
                    ),
                  ),
                ],
              ))
            );
          }
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(right: 50.0, left: _paddingHorizontal, top: _paddingVertical, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(height: 30),
              messageTextGroup,
            ],
          ),
          if(extendMessageGroupList.isNotEmpty) ...{
            for(Widget extendMessageGroup in extendMessageGroupList) ...{
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(height: 30),
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
    PolylineId id = PolylineId('poly');
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