// Copyright 2024 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/dfareporting/v4.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:keras_mobile_chatbot/home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/localization_intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

main() async {
  dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  initCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingProvider(),
      child: const KerasMobileChatbotMainUI(),
    ),
  );
}

class KerasMobileChatbotMainUI extends StatelessWidget {
  const KerasMobileChatbotMainUI({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<SettingProvider>(context).language;
    List<Locale> localesInApp = [];
    if (language == "en") {
      localesInApp = [const Locale('en', 'US')];
    } else if (language == "zh") {
      localesInApp = [const Locale('zh', 'CN')];
    } else if (language == "auto") {
      localesInApp = supportedLocalesInApp;
    }
    if(localesInApp.length == 1) {
      return MaterialApp(
        localizationsDelegates: const [  
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DemoLocalizationsDelegate(),
        ],
        locale: localesInApp.first,
        supportedLocales: localesInApp,
        onGenerateTitle: (context){
          return DemoLocalizations.of(context).materialTitle;
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      );
    }
    else {
      return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DemoLocalizationsDelegate(),
        ],
        supportedLocales: localesInApp,
        localeListResolutionCallback: (List<Locale>? locales, Iterable<Locale> supportedLocales) {
          // Your custom logic to choose the best locale
          for (final locale in locales!) {
            if (supportedLocales.contains(locale)) {
              return locale;
            }
          }

          for (final locale in locales!) {
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          // If no match is found, return the first supported locale
          return supportedLocales.first;
        },
        localeResolutionCallback:
            (Locale? locale, Iterable<Locale> supportedLocales) {
          // Your custom logic to choose the best locale
          if (locale == null) {
            return supportedLocales.first;
          }

          // If no exact match is found, return the first supported locale with the same language code
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }

          // If no match is found, return the first supported locale
          return supportedLocales.first;
        },
        onGenerateTitle: (context){
          return DemoLocalizations.of(context).materialTitle;
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      );
    }
  }
}