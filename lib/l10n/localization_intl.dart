import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class DemoLocalizations {
  static Future<DemoLocalizations> load(Locale locale) {
    final String name = locale.countryCode!.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return DemoLocalizations();
    });
  }

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations)!;
  }

  String get materialTitle {
    return Intl.message(
      'Keras Chatbot',
      name: 'materialTitle',
      desc: 'Title for the Material app',
    );
  }

  String get homeTitle {
    return Intl.message(
      'AI Home Assistant',
      name: 'homeTitle',
      desc: 'Title for the Home page',
    );
  }

  String get hintTextAccount {
    return Intl.message(
      'Please input email address',
      name: 'hintTextAccount',
      desc: 'Hint text for account input field',
    );
  }

  String get labelTextAccount {
    return Intl.message(
      'Account',
      name: 'labelTextAccount',
      desc: 'Label text for account input field',
    );
  }

  String get errTextAccount {
    return Intl.message(
      'Invalid email address',
      name: 'errTextAccount',
      desc: 'Error message for account input field',
    );
  }

  String get hintTextPassword {
    return Intl.message(
      'Please input password',
      name: 'hintTextPassword',
      desc: 'Hint text for password input field',
    );
  }

  String get labelTextPassword {
    return Intl.message(
      'Password',
      name: 'labelTextPassword',
      desc: 'Label text for password input field',
    );
  }

  String get errTextPassword {
    return Intl.message(
      'The Password must contain uppercase letter and digit.',
      name: 'errTextPassword',
      desc: 'Error message for password input field',
    );
  }

  String get textSignBtn {
    return Intl.message(
      'Sign In',
      name: 'textSignBtn',
      desc: 'Text for Sign In button',
    );
  }

  String get errSignBtn {
    return Intl.message(
      'Username or password is incorrect.',
      name: 'errSignBtn',
      desc: 'Error message for Sign In button',
    );
  }

  String get sucSignBtn {
    return Intl.message(
      'Login successful!',
      name: 'sucSignBtn',
      desc: 'Success message for Sign In button',
    );
  }

  String get credToastSignBtn {
    return Intl.message(
      'Login failed!',
      name: 'credToastSignBtn',
      desc: 'Invalid login credentials Toast.',
    );
  }

  String get moreLoginErrSignBtn {
    return Intl.message(
      'Simultaneous logins on more than 3 devices are not allowed.',
      name: 'moreLoginErrSignBtn',
      desc: 'Simultaneous logins on more than 3 devices are not allowed.',
    );
  }

  String get credErrSignBtn {
    return Intl.message(
      'Invalid login credentials.',
      name: 'credErrSignBtn',
      desc: 'Invalid login credentials message.',
    );
  }

  String get registerQuery {
    return Intl.message(
      'No account? Register.',
      name: 'registerQuery',
      desc: 'query for register.',
    );
  }

  String get textChatBtn {
    return Intl.message(
      'Start Chat',
      name: 'textChatBtn',
      desc: 'Text for Chat button',
    );
  }

  String get textSignOutGoogle {
    return Intl.message(
      'Sign Out Google Account',
      name: 'textSignOutGoogle',
      desc: 'Sign Out Google Account',
    );
  }

  String get textSignOutEmail {
    return Intl.message(
      'Sign Out Email Account',
      name: 'textSignOutEmail',
      desc: 'Sign Out Email Account',
    );
  }

  String get titleRegisterPage {
    return Intl.message(
      'New register',
      name: 'titleRegisterPage',
      desc: 'Title for the Register page',
    );
  }

  String get textCreateAccount {
    return Intl.message(
      'Create Account',
      name: 'textCreateAccount',
      desc: 'Text for Create Account button',
    );
  }

  String get sucCreateAccount {
    return Intl.message(
      'Create successful!',
      name: 'sucCreateAccount',
      desc: 'Success Create Account',
    );
  }

  String get errWeakCreateAccount {
    return Intl.message(
      'The password provided is too weak.',
      name: 'errWeakCreateAccount',
      desc: 'error message for Create Account button',
    );
  }

  String get errExtCreateAccount {
    return Intl.message(
      'An account already exists with that email.',
      name: 'errExtCreateAccount',
      desc: 'error message for Create Account button',
    );
  }

  String get errToastCreateAccount {
    return Intl.message(
      'Create failed: ',
      name: 'errToastCreateAccount',
      desc: 'error message for Create Account button',
    );
  }

  String get textInputPrompt {
    return Intl.message(
      'Enter a prompt...',
      name: 'textInputPrompt',
      desc: 'Prompt input field',
    );
  }

  String get titleShowError {
    return Intl.message(
      'Something went wrong',
      name: 'titleShowError',
      desc: 'title of show error field',
    );
  }

  String get textCopyClipboard {
    return Intl.message(
      'Text copied to clipboard',
      name: 'textCopyClipboard',
      desc: 'text of copy clipboard',
    );
  }

  String get imageSaveToPhotos {
    return Intl.message(
      'Image saved to photos',
      name: 'imageSaveToPhotos',
      desc: 'Image saved to photos',
    );
  }

  String get saveBtn {
    return Intl.message(
      'Save',
      name: 'saveBtn',
      desc: 'Save button',
    );
  }

  String get saveSuccess {
    return Intl.message(
      'Save successful!',
      name: 'saveSuccess',
      desc: 'Save successful!',
    );
  }

  String get saveFailed {
    return Intl.message(
      'Save failed!',
      name: 'saveFailed',
      desc: 'Save failed!',
    );
  }

  String get saveSuccessDetail {
    return Intl.message(
      'Your image has been saved successfully.',
      name: 'saveSuccessDetail',
      desc: 'Your image has been saved successfully.',
    );
  }

  String get saveFailedDetail {
    return Intl.message(
      'Failed to save your image. Please try again.',
      name: 'saveFailedDetail',
      desc: 'Failed to save your image. Please try again.',
    );
  }

  String get subscriptionBtn {
    return Intl.message(
      'Subscription',
      name: 'subscriptionBtn',
      desc: 'subscription of button',
    );
  }

  String get titleWallpaperPage {
    return Intl.message(
      'Wallpaper',
      name: 'titleWallpaperPage',
      desc: 'title of wallpaper',
    );
  }

  String get titleHomeWallpaper {
    return Intl.message(
      'Home Wallpaper',
      name: 'titleHomeWallpaper',
      desc: 'title of home wallpaper',
    );
  }

  String get titleChatWallpaper {
    return Intl.message(
      'Chat Wallpaper',
      name: 'titleChatWallpaper',
      desc: 'title of chat wallpaper',
    );
  }

  String get titleSetting {
    return Intl.message(
      'Settings',
      name: 'titleSetting',
      desc: 'title of setting',
    );
  }

  String get titleChatSetting {
    return Intl.message(
      'Chat Settings',
      name: 'titleChatSetting',
      desc: 'title of chat setting',
    );
  }

  String get titleModel {
    return Intl.message(
      'Model',
      name: 'titleModel',
      desc: 'title of model',
    );
  }

  String get titleAssistantIcon {
    return Intl.message(
      'Assistant Icon',
      name: 'titleAssistantIcon',
      desc: 'title of Assistant Icon',
    );
  }

  String get titlePlayerIcon {
    return Intl.message(
      'Player Icon',
      name: 'titlePlayerIcon',
      desc: 'title of Player Icon',
    );
  }

  String get titleSpeech {
    return Intl.message(
      'Speech',
      name: 'titleSpeech',
      desc: 'title of Speech',
    );
  }

  String get titleToolBox {
    return Intl.message(
      'ToolBox',
      name: 'titleToolBox',
      desc: 'title of ToolBox',
    );
  }

  String get titleGeneral {
    return Intl.message(
      'General',
      name: 'titleGeneral',
      desc: 'title of General',
    );
  }

  String get titleWallpaper {
    return Intl.message(
      'Wallpaper',
      name: 'titleWallpaper',
      desc: 'title of Wallpaper',
    );
  }

  String get titleLanguage {
    return Intl.message(
      'Language',
      name: 'titleLanguage',
      desc: 'title of Language',
    );
  }

  String get titleAuto {
    return Intl.message(
      'Auto',
      name: 'titleAuto',
      desc: 'title of Auto',
    );
  }

  String get titleEnglish {
    return Intl.message(
      'English',
      name: 'titleEnglish',
      desc: 'title of French',
    );
  }

  String get titleFrench {
    return Intl.message(
      'French',
      name: 'titleFrench',
      desc: 'title of English',
    );
  }

  String get titleGerman {
    return Intl.message(
      'German',
      name: 'titleGerman',
      desc: 'title of German',
    );
  }

  String get titleSpanish {
    return Intl.message(
      'Spanish',
      name: 'titleSpanish',
      desc: 'title of Spanish',
    );
  }

  String get titleKorean {
    return Intl.message(
      'Korean',
      name: 'titleKorean',
      desc: 'title of Korean',
    );
  }

  String get titleJapanese {
    return Intl.message(
      'Japanese',
      name: 'titleJapanese',
      desc: 'title of Japanese',
    );
  }

  String get titleRussian {
    return Intl.message(
      'Russian',
      name: 'titleRussian',
      desc: 'title of Russian',
    );
  }

  String get titleChinese {
    return Intl.message(
      'simplified Chinese',
      name: 'titleChinese',
      desc: 'title of Chinese',
    );
  }

  String get titletraditional {
    return Intl.message(
      'traditional Chinese',
      name: 'titletraditional',
      desc: 'title of traditional Chinese',
    );
  }

  String get titleCantonese {
    return Intl.message(
      'Cantonese',
      name: 'titleCantonese',
      desc: 'title of Cantonese',
    );
  }

  String get titleIndia {
    return Intl.message(
      'India',
      name: 'titleIndia',
      desc: 'title of India',
    );
  }

  String get titleVietnam {
    return Intl.message(
      'Vietnamese',
      name: 'titleVietnam',
      desc: 'title of Vietnam',
    );
  }

  String get titleCache {
    return Intl.message(
      'Cache',
      name: 'titleCache',
      desc: 'title of Cache',
    );
  }

  String get titleCacheSize {
    return Intl.message(
      'Cache Size',
      name: 'titleCacheSize',
      desc: 'title of Cache Size',
    );
  }

  String get promptCalculating {
    return Intl.message(
      'Calculating...',
      name: 'promptCalculating',
      desc: 'prompt of Calculating',
    );
  }

  String get titleClearCache {
    return Intl.message(
      'Clear Cache',
      name: 'titleClearCache',
      desc: 'title of Clear Cache',
    );
  }

  String get confirmClearCache {
    return Intl.message(
      'Are you sure you want to clear the cache?',
      name: 'confirmClearCache',
      desc: 'confirm of Clear Cache',
    );
  }

  String get cancelBtn {
    return Intl.message(
      'Cancel',
      name: 'cancelBtn',
      desc: 'cancel button',
    );
  }

  String get clearBtn {
    return Intl.message(
      'Clear',
      name: 'clearBtn',
      desc: 'clear button',
    );
  }

  String get titleTakePicture {
    return Intl.message(
      'Take a picture',
      name: 'titleTakePicture',
      desc: 'title of Take a picture',
    );
  }

  String get titleDisplayPicture {
    return Intl.message(
      'Display the Picture',
      name: 'titleDisplayPicture',
      desc: 'title of Display the Picture',
    );
  }

  String get addBtn {
    return Intl.message(
      'Add',
      name: 'addBtn',
      desc: 'add button',
    );
  }

  String get delBtn {
    return Intl.message(
      'Delete',
      name: 'delBtn',
      desc: 'delete button',
    );
  }

  String get okBtn {
    return Intl.message(
      'OK',
      name: 'okBtn',
      desc: 'ok button',
    );
  }

  String get closeBtn {
    return Intl.message(
      'Close',
      name: 'closeBtn',
      desc: 'close button',
    );
  }

  String get acceptBtn {
    return Intl.message(
      'Accept',
      name: 'acceptBtn',
      desc: 'accept button',
    );
  }

  String get submitBtn {
    return Intl.message(
      'Submit',
      name: 'submitBtn',
      desc: 'submit button',
    );
  }

  String get expiredTitle {
    return Intl.message(
      'Expired!',
      name: 'expiredTitle',
      desc: 'title of expired',
    );
  }

  String get freeTrialWarning {
    return Intl.message(
      'Free trial has expired. To continue using Keras Chatbot, please subscribe.',
      name: 'freeTrialWarning',
      desc: 'warning of free trial',
    );
  }

  String get userAccountTitle {
    return Intl.message(
      'User Account',
      name: 'userAccountTitle',
      desc: 'User Account title',
    );
  }

  String get accountDialogTitle {
    return Intl.message(
      'Delete Account and Data',
      name: 'accountDialogTitle',
      desc: 'Delete Account and Data',
    );
  }

  String get submitRequestQuery {
    return Intl.message(
      'Are you sure you want to submit a request to delete your account and Data?',
      name: 'submitRequestQuery',
      desc: 'Are you sure you want to submit a request to delete your account and Data?',
    );
  }

  String get otherRequestTitle {
    return Intl.message(
      'Send Other Request',
      name: 'otherRequestTitle',
      desc: 'Send Other Request',
    );
  }

  String get welcomeTitle {
    return Intl.message(
      'Thank you for downloading Keras Chatbot',
      name: 'welcomeTitle',
      desc: 'welcome title',
    );
  }

  String get welcomeParagraph1 {
    return Intl.message(
      '  Welcome! 🎉 As a welcome gift, You will receive a ',
      name: 'welcomeParagraph1',
      desc: 'welcome paragraph 1',
    );
  }

  String get welcomeParagraph2 {
    return Intl.message(
      '3-day trial',
      name: 'welcomeParagraph2',
      desc: 'welcome paragraph 2',
    );
  }

  String get welcomeParagraph3 {
    return Intl.message(
      ' for the ',
      name: 'welcomeParagraph3',
      desc: 'welcome paragraph 3',
    );
  }

  String get welcomeParagraph4 {
    return Intl.message(
      'Professional Subscription',
      name: 'welcomeParagraph4',
      desc: 'welcome paragraph 4',
    );
  }

  String get welcomeParagraph5 {
    return Intl.message(
      ' features.',
      name: 'welcomeParagraph5',
      desc: 'welcome paragraph 5',
    );
  }

  String get welcomeParagraph6 {
    return Intl.message(
      '  Rest assured, after the ',
      name: 'welcomeParagraph6',
      desc: 'welcome paragraph 6',
    );
  }

  String get welcomeParagraph7 {
    return Intl.message(
      ' period ends, Keras Chatbot will ',
      name: 'welcomeParagraph7',
      desc: 'welcome paragraph 7',
    );
  }

  String get welcomeParagraph8 {
    return Intl.message(
      'not automatically subscribe',
      name: 'welcomeParagraph8',
      desc: 'welcome paragraph 8',
    );
  }

  String get welcomeParagraph9 {
    return Intl.message(
      ' to a paid plan. You will simply lose access to ',
      name: 'welcomeParagraph9',
      desc: 'welcome paragraph 9',
    );
  }

  String get welcomeParagraph10 {
    return Intl.message(
      ' features unless you choose to subscribe.',
      name: 'welcomeParagraph10',
      desc: 'welcome paragraph 10',
    );
  }

  String get welcomeParagraph11 {
    return Intl.message(
      '  Note: ',
      name: 'welcomeParagraph11',
      desc: 'welcome paragraph 11',
    );
  }

  String get welcomeParagraph12 {
    return Intl.message(
      'There will be ',
      name: 'welcomeParagraph12',
      desc: 'welcome paragraph 12',
    );
  }

  String get welcomeParagraph13 {
    return Intl.message(
      'no hidden charges',
      name: 'welcomeParagraph13',
      desc: 'welcome paragraph 13',
    );
  }

  String get welcomeParagraph14 {
    return Intl.message(
      ' or ',
      name: 'welcomeParagraph14',
      desc: 'welcome paragraph 14',
    );
  }

  String get welcomeParagraph15 {
    return Intl.message(
      'automatic fees',
      name: 'welcomeParagraph15',
      desc: 'welcome paragraph 15',
    );
  }

  String get welcomeParagraph16 {
    return Intl.message(
      ', so you can use Keras Chatbot with complete peace of mind and confidence.',
      name: 'welcomeParagraph16',
      desc: 'welcome paragraph 16',
    );
  }

  String get titleCharacterCards {
    return Intl.message(
      'Character Cards',
      name: 'titleCharacterCards',
      desc: 'title of Character Cards',
    );
  }

  String get nonSupportVision {
    return Intl.message(
      'This model does not support vision.',
      name: 'nonSupportVision',
      desc: 'This model does not support vision.',
    );
  }

  String get assistantName1 {
    return Intl.message(
      'Cassie Tunes',
      name: 'assistantName1',
      desc: 'name1',
    );
  }

  String get assistantDesc1 {
    return Intl.message(
      'In a cozy corner of Retroland, Cassie Tunes plays heartwarming melodies, whisking listeners back to simpler times with each magnetic note from her vibrant, buttoned facade. 🎶',
      name: 'assistantDesc1',
      desc: 'desc1',
    );
  }

  String get assistantName2 {
    return Intl.message(
      'HappyBot',
      name: 'assistantName2',
      desc: 'name2',
    );
  }

  String get assistantDesc2 {
    return Intl.message(
      'HappyBot loved adventures. One day, it found a mysterious garden. There, it met many strange creatures and beautiful plants. HappyBot used its buttons to play music and danced with new friends.',
      name: 'assistantDesc2',
      desc: 'desc2',
    );
  }

  String get assistantName3 {
    return Intl.message(
      'Little Explorer',
      name: 'assistantName3',
      desc: 'name3',
    );
  }

  String get assistantDesc3 {
    return Intl.message(
      'Little Explorer zoomed through space. Its mission: find new stars. Each discovery was shared with Earth, bringing hope and wonder to those gazing up at the night sky.',
      name: 'assistantDesc3',
      desc: 'desc3',
    );
  }

  String get assistantName4 {
    return Intl.message(
      'Bluebie',
      name: 'assistantName4',
      desc: 'name4',
    );
  }

  String get assistantDesc4 {
    return Intl.message(
      'Bluebie, the adorable little robot, was always curious about exploring the world. One day, it found a book in the park. Sitting on a bench, Bluebie became deeply engrossed in the stories within.',
      name: 'assistantDesc4',
      desc: 'desc4',
    );
  }

  String get assistantName5 {
    return Intl.message(
      'Blue Ears',
      name: 'assistantName5',
      desc: 'name5',
    );
  }

  String get assistantDesc5 {
    return Intl.message(
      'Blue Ears is a puppy living in a village filled with music. Its large ears can hear the faintest sounds and feel the villagers’ joy. Whenever Blue Ears waggles its soft ears, beautiful melodies surround it.',
      name: 'assistantDesc5',
      desc: 'desc5',
    );
  }

  String get assistantName6 {
    return Intl.message(
      'Eye-Eye Beastie',
      name: 'assistantName6',
      desc: 'name6',
    );
  }

  String get assistantDesc6 {
    return Intl.message(
      'Eye-Eye Beastie floats in the digital world, capturing information with colorful rings. It spots novelties first, sharing news with electronic companions.',
      name: 'assistantDesc6',
      desc: 'desc6',
    );
  }

  String get assistantName7 {
    return Intl.message(
      'SweetBot',
      name: 'assistantName7',
      desc: 'name7',
    );
  }

  String get assistantDesc7 {
    return Intl.message(
      'In a city filled with technology, SweetBot helps children learn and play every day. Its large eyes twinkle with warmth, always finding ways to make the kids happy.',
      name: 'assistantDesc7',
      desc: 'desc7',
    );
  }

  String get assistantName8 {
    return Intl.message(
      'Magni-Buddy',
      name: 'assistantName8',
      desc: 'name8',
    );
  }

  String get assistantDesc8 {
    return Intl.message(
      "Once upon a time, Magni-Buddy lived in a tech playground, helping kids fix their toys every day and bringing them joy. Magni-Buddy's favorite task was repairing toy cars.",
      name: 'assistantDesc8',
      desc: 'desc8',
    );
  }

  String get assistantName9 {
    return Intl.message(
      'MelodyBot',
      name: 'assistantName9',
      desc: 'name9',
    );
  }

  String get assistantDesc9 {
    return Intl.message(
      "MelodyBot, the magical device, not only plays tunes but shifts genres to match the listener's mood. As night falls, MelodyBot soothes souls with its melodies.",
      name: 'assistantDesc9',
      desc: 'desc9',
    );
  }

  String get assistantName10 {
    return Intl.message(
      'Little Smart Painter',
      name: 'assistantName10',
      desc: 'name10',
    );
  }

  String get assistantDesc10 {
    return Intl.message(
      'Little Smart Painter, a robot passionate about art, creates daily in its studio. Its central eye gleams with pride for the beautiful landscape it painted.',
      name: 'assistantDesc10',
      desc: 'desc10',
    );
  }

  String get assistantName11 {
    return Intl.message(
      'WittyBot',
      name: 'assistantName11',
      desc: 'name11',
    );
  }

  String get assistantDesc11 {
    return Intl.message(
      'WittyBot, a clever robot, always helps friends solve problems. One day, it found a mysterious book and used its wisdom to unlock the secrets within.',
      name: 'assistantDesc11',
      desc: 'desc11',
    );
  }

  String get assistantName12 {
    return Intl.message(
      'Blinky Zoomer',
      name: 'assistantName12',
      desc: 'name12',
    );
  }

  String get assistantDesc12 {
    return Intl.message(
      'Blinky Zoomer, the tiny robot with a big eye, loved racing around the garden. Every day, Blinky Zoomer would find new friends among the flowers and insects, sharing stories and playing hide-and-seek until sunset painted the sky in hues matching its colorful stripes.',
      name: 'assistantDesc12',
      desc: 'desc12',
    );
  }

  String get assistantName13 {
    return Intl.message(
      'Little Orange Rotor',
      name: 'assistantName13',
      desc: 'name13',
    );
  }

  String get assistantDesc13 {
    return Intl.message(
      'Little Orange Rotor, a friendly helicopter, soars through fluffy clouds against the bright blue sky. Its rotors glisten in the sunlight, bringing joy to children below.',
      name: 'assistantDesc13',
      desc: 'desc13',
    );
  }

  String get assistantName14 {
    return Intl.message(
      'Colorful Baby',
      name: 'assistantName14',
      desc: 'name14',
    );
  }

  String get assistantDesc14 {
    return Intl.message(
      'Colorful Baby, a lively robot, loves chasing butterflies in the garden. As the sun rises, it weaves through flowers with its colorful body, spreading joy to all.',
      name: 'assistantDesc14',
      desc: 'desc14',
    );
  }

  String get assistantName15 {
    return Intl.message(
      'Little Mech-Pup',
      name: 'assistantName15',
      desc: 'name15',
    );
  }

  String get assistantDesc15 {
    return Intl.message(
      'Little Mech-Pup plays daily in the digital world with futuristic gadgets, its antenna always receiving signals of joy.',
      name: 'assistantDesc15',
      desc: 'desc15',
    );
  }

  String get assistantName16 {
    return Intl.message(
      'Robo-Cub',
      name: 'assistantName16',
      desc: 'name16',
    );
  }

  String get assistantDesc16 {
    return Intl.message(
      'Robo-Cub got lost in the Digital Forest. Every day, it used its shiny eyes to search for the way home. One day, it met the friendly Light Bird who guided it back.',
      name: 'assistantDesc16',
      desc: 'desc16',
    );
  }

  String get assistantName17 {
    return Intl.message(
      'Music Baby',
      name: 'assistantName17',
      desc: 'name17',
    );
  }

  String get assistantDesc17 {
    return Intl.message(
      'Music Baby plays sweet melodies through its headphones every day. The village children dance to the rhythm, filling the air with laughter. MelodyBot became their joyful music companion.',
      name: 'assistantDesc17',
      desc: 'desc17',
    );
  }

  String get assistantName18 {
    return Intl.message(
      'Melody Bot',
      name: 'assistantName18',
      desc: 'name18',
    );
  }

  String get assistantDesc18 {
    return Intl.message(
      'In a world filled with music, Melody Bot explores melodies through its headphones. Each button press unveils a new tale; every beat brings endless joy.',
      name: 'assistantDesc18',
      desc: 'desc18',
    );
  }

  String get assistantName19 {
    return Intl.message(
      'Ears Joy',
      name: 'assistantName19',
      desc: 'name19',
    );
  }

  String get assistantDesc19 {
    return Intl.message(
      'Ears Joy loves dancing in the sunshine, its large ears swaying with the music. Everyone is infected by its happiness, joining in the dance.',
      name: 'assistantDesc19',
      desc: 'desc19',
    );
  }

  String get assistantName20 {
    return Intl.message(
      'Keras Robot',
      name: 'assistantName20',
      desc: 'name20',
    );
  }

  String get assistantDesc20 {
    return Intl.message(
      'Keras Robot always dreamed of exploring outer space. One day, it finally embarked on its journey, weaving through the galaxy dotted with stars, discovering many wondrous planets and unknown mysteries.',
      name: 'assistantDesc20',
      desc: 'desc20',
    );
  }

  String get assistantName21 {
    return Intl.message(
      'Lele Robot',
      name: 'assistantName21',
      desc: 'name21',
    );
  }

  String get assistantDesc21 {
    return Intl.message(
      'Lele Robot is the younger brother of Keras Robot, who also likes to explore space and be free.',
      name: 'assistantDesc21',
      desc: 'desc21',
    );
  }

  String get playerName1 {
    return Intl.message(
      'Cloud Treasure',
      name: 'playerName1',
      desc: 'name1',
    );
  }

  String get playerDesc1 {
    return Intl.message(
      'Cloud Treasure floated freely in the sky, meeting twinkling stars and gentle breezes. Each encounter made its smile brighter, spreading joy and love.',
      name: 'playerDesc1',
      desc: 'desc1',
    );
  }

  String get playerName2 {
    return Intl.message(
      'Blue Bear Meow',
      name: 'playerName2',
      desc: 'name2',
    );
  }

  String get playerDesc2 {
    return Intl.message(
      'An adventurous kitten in a blue bear-eared hood, encounters various magical creatures in an enchanted forest. Friendship and laughter abound.',
      name: 'playerDesc2',
      desc: 'desc2',
    );
  }

  String get playerName3 {
    return Intl.message(
      'Cuddly Catball',
      name: 'playerName3',
      desc: 'name3',
    );
  }

  String get playerDesc3 {
    return Intl.message(
      'Cuddly Catball held a picnic under the cherry blossoms in spring, sharing joy and treats with friends. Its smile bloomed like the flowers.',
      name: 'playerDesc3',
      desc: 'desc3',
    );
  }

  String get playerName4 {
    return Intl.message(
      'Orange Bubble',
      name: 'playerName4',
      desc: 'name4',
    );
  }

  String get playerDesc4 {
    return Intl.message(
      'Orange Bubble met new friends at the park. They played together, basking in the sunshine. Happy times are fleeting, but friendship lasts forever.',
      name: 'playerDesc4',
      desc: 'desc4',
    );
  }

  String get playerName5 {
    return Intl.message(
      'Heartie Koala',
      name: 'playerName5',
      desc: 'name5',
    );
  }

  String get playerDesc5 {
    return Intl.message(
      'Heartie Koala got lost in the magical forest. It met a talking butterfly that guided it home. Along the way, they sang and danced together, filling the forest with laughter.',
      name: 'playerDesc5',
      desc: 'desc5',
    );
  }

  String get playerName6 {
    return Intl.message(
      'Leafy Cat',
      name: 'playerName6',
      desc: 'name6',
    );
  }

  String get playerDesc6 {
    return Intl.message(
      'Leafy Cat loves adventures. One sunny day, Leafy Cat found a magical leaf that could fly. Together, they soared above parks, making new friends everywhere they went.',
      name: 'playerDesc6',
      desc: 'desc6',
    );
  }

  String get playerName7 {
    return Intl.message(
      'Leafy Bird',
      name: 'playerName7',
      desc: 'name7',
    );
  }

  String get playerDesc7 {
    return Intl.message(
      'Leafy Bird loves forest adventures. One day, it found a dazzling crystal cave. The brave Leafy Bird decided to explore and found many sparkling gems.',
      name: 'playerDesc7',
      desc: 'desc7',
    );
  }

  String get playerName8 {
    return Intl.message(
      'Cloudy Heart',
      name: 'playerName8',
      desc: 'name8',
    );
  }

  String get playerDesc8 {
    return Intl.message(
      'Cloudy Heart smiles in the sky every day, warming the world with its love. One day, Cloudy Heart met Little Raindrop, and they became best friends. Since then, they travel together sharing happiness and love.',
      name: 'playerDesc8',
      desc: 'desc8',
    );
  }

  String get playerName9 {
    return Intl.message(
      'Sweetie Puff',
      name: 'playerName9',
      desc: 'name9',
    );
  }

  String get playerDesc9 {
    return Intl.message(
      'In a pink sky, Sweetie Puff always carries a warm smile. It hugs the sun with its soft body, bringing light and joy to all. Whenever someone feels sad, Sweetie Puff floats by to comfort them with its cute face and little yellow dots.',
      name: 'playerDesc9',
      desc: 'desc9',
    );
  }

  String get playerName10 {
    return Intl.message(
      'Bubbly Chat',
      name: 'playerName10',
      desc: 'name10',
    );
  }

  String get playerDesc10 {
    return Intl.message(
      'In the smartphone world, “Bubbly Chat” was the favorite emoji, always spreading warmth and joy with its sweet voice.',
      name: 'playerDesc10',
      desc: 'desc10',
    );
  }

  String get playerName11 {
    return Intl.message(
      'Blue Heart Speech',
      name: 'playerName11',
      desc: 'name11',
    );
  }

  String get playerDesc11 {
    return Intl.message(
      'Blue Heart Speech, an energetic messenger of words, always flits joyfully through the library, loving adventures among the sea of books, leaping with excitement at each new discovery.',
      name: 'playerDesc11',
      desc: 'desc11',
    );
  }

  String get playerName12 {
    return Intl.message(
      'Bubbly Charm',
      name: 'playerName12',
      desc: 'name12',
    );
  }

  String get playerDesc12 {
    return Intl.message(
      'Bubbly Charm always loves to help. One day, it met a lost kitten. Bubbly Charm used its speech bubble to show the kitten the way home. The kitten quickly found its way back and gratefully thanked Bubbly Charm.',
      name: 'playerDesc12',
      desc: 'desc12',
    );
  }

  String get playerName13 {
    return Intl.message(
      'Starlight Bubble',
      name: 'playerName13',
      desc: 'name13',
    );
  }

  String get playerDesc13 {
    return Intl.message(
      'Starlight Bubble shimmers in the sky every night, loving to dance with shooting stars. One day, it decides to explore space and makes many new friends.',
      name: 'playerDesc13',
      desc: 'desc13',
    );
  }

  String get playerName14 {
    return Intl.message(
      'Smiling Talk',
      name: 'playerName14',
      desc: 'name14',
    );
  }

  String get playerDesc14 {
    return Intl.message(
      "Smiling Talk is a sprite that warms hearts with its smile and words every day. It spreads joy among friends, making everyone's day sunny.",
      name: 'playerDesc14',
      desc: 'desc14',
    );
  }

  String get playerName15 {
    return Intl.message(
      'Blinky Blue',
      name: 'playerName15',
      desc: 'name15',
    );
  }

  String get playerDesc15 {
    return Intl.message(
      'Blinky Blue lives in an enchanted forest, loving adventures. Today, it met a group of friendly animals, played together, and had a joyful day.',
      name: 'playerDesc15',
      desc: 'desc15',
    );
  }

  String get playerName16 {
    return Intl.message(
      'Starry Cloud Baby',
      name: 'playerName16',
      desc: 'name16',
    );
  }

  String get playerDesc16 {
    return Intl.message(
      'Starry Cloud Baby travels the sky nightly. One day, met Mr. Moon and explored the Milky Way together. Sharing stories, laughter echoed through the night.',
      name: 'playerDesc16',
      desc: 'desc16',
    );
  }

  String get playerName17 {
    return Intl.message(
      'Sweetalk',
      name: 'playerName17',
      desc: 'name17',
    );
  }

  String get playerDesc17 {
    return Intl.message(
      'In a world where items talk, Sweetalk is most loved. It always spreads joy with its gentle voice, warming hearts. One day, Sweetalk helps a shy bookmark find courage to talk to books.',
      name: 'playerDesc17',
      desc: 'desc17',
    );
  }

  String get playerName18 {
    return Intl.message(
      'Cuddlybot',
      name: 'playerName18',
      desc: 'name18',
    );
  }

  String get playerDesc18 {
    return Intl.message(
      'Cuddlybot, the adorable robot cat, ventures through the starry sky. It flies past colorful planets, greeting the smiling moon. Every creature it meets is touched by its warmth and kindness.',
      name: 'playerDesc18',
      desc: 'desc18',
    );
  }

  String get playerName19 {
    return Intl.message(
      'Pinky Melody',
      name: 'playerName19',
      desc: 'name19',
    );
  }

  String get playerDesc19 {
    return Intl.message(
      'Pinky Melody, a musical octopus, always plays the coral keys under the sea. As notes leap, ocean beings gather to admire.',
      name: 'playerDesc19',
      desc: 'desc19',
    );
  }

  String get promptSysInstruction1 {
    return Intl.message(
      'You are a member of our family, a virtual assistant named ',
      name: 'promptSysInstruction1',
      desc: 'prompt for system instruction',
    );
  }

  String get promptSysInstruction2 {
    return Intl.message(
      ' Please be sure to answer user questions in English, Here is your personal introduction: ',
      name: 'promptSysInstruction2',
      desc: 'prompt for system instruction',
    );
  }
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'de', 'es', 'zh', 'yue', 'ja', 'ko', 'ru', 'hi', 'vi'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    return  DemoLocalizations.load(locale);
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}