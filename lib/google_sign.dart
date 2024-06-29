import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/photoslibrary/v1.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/youtube/v3.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'profile',
    PhotosLibraryApi.photoslibraryScope,
    GmailApi.mailGoogleComScope,
    CalendarApi.calendarScope,
    DriveApi.driveScope,
    YouTubeApi.youtubeScope,
    ],
);

