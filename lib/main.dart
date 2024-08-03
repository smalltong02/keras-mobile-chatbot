// Copyright 2024 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keras_mobile_chatbot/utils.dart';
import 'package:keras_mobile_chatbot/home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/localization_intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

main() async {
  runZonedGuarded<Future<void>>(() async { 
    dotenv.load(fileName: ".env");
    WidgetsFlutterBinding.ensureInitialized();
    initApp();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
    final settingProvider = SettingProvider();
    await settingProvider.initialize();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => settingProvider),
          ChangeNotifierProvider(create: (context) => KerasAuthProvider()),
          ChangeNotifierProvider(create: (context) => KerasSubscriptionProvider()),
        ],
        child: const KerasMobileChatbotMainUI(),
      ),
    );
    FirebaseRemoteConfigService().initialize();
  }, (error, stack) => 
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)); 
}

class KerasMobileChatbotMainUI extends StatelessWidget {
  const KerasMobileChatbotMainUI({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<SettingProvider>(context).language;
    List<Locale> localesInApp = [];
    if (language == "en") {
      localesInApp = [const Locale('en', 'US')];
    } else if (language == "fr") {
      localesInApp = [const Locale('fr', 'FR')];
    } else if (language == "de") {
      localesInApp = [const Locale('de', 'DE')];
    } else if (language == "es") {
      localesInApp = [const Locale('es', 'ES')];
    } else if (language == "ja") {
      localesInApp = [const Locale('ja', 'JP')];
    } else if (language == "ko") {
      localesInApp = [const Locale('ko', 'KR')];
    } else if (language == "ru") {
      localesInApp = [const Locale('ru', 'RU')];
    } else if (language == "zh-cn" || language == "zh") {
      localesInApp = [const Locale('zh', 'CN')];
    } else if (language == "zh-tw") {
      localesInApp = [const Locale('zh', 'TW')];
    } else if (language == "yue") {
      localesInApp = [const Locale('zh', 'TW')];
    } else if (language == "in") {
      localesInApp = [const Locale('hi', 'IN')];
    } else if (language == "vi") {
      localesInApp = [const Locale('vi', 'VN')];
    } else if (language == "auto") {
      localesInApp = supportedLocalesInApp;
    } else {
      localesInApp = [const Locale('en', 'US')];
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

          for (final locale in locales) {
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