import 'package:flutter/material.dart';
import 'l10n/localization_intl.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:keras_mobile_chatbot/utils.dart';

typedef ToolBoxCallback = void Function(ToolBoxesSetting setting);

class ToolBoxScreen extends StatefulWidget {
  final ToolBoxesSetting toolBoxesSetting;
  final ToolBoxCallback toolBoxesCallback;

  const ToolBoxScreen({super.key, required this.toolBoxesSetting, required this.toolBoxesCallback});

  @override
  ToolBoxScreenState createState() => ToolBoxScreenState();
}

class ToolBoxScreenState extends State<ToolBoxScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ToolBoxesSetting curSetting = widget.toolBoxesSetting;
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).titleToolBox),
        backgroundColor: Colors.pink.shade200,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: SettingsList(
            sections: [
              SettingsSection(
                title: Text(
                  DemoLocalizations.of(context).settingToolBox,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    initialValue: curSetting.bCurrentTime,
                    title: Text(DemoLocalizations.of(context).timeToolBox),
                    leading: const Icon(Icons.more_time_sharp),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bCurrentTime = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bCurrentLocation,
                    title: Text(DemoLocalizations.of(context).localToolBox),
                    leading: const Icon(Icons.place_sharp),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bCurrentLocation = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bSearch,
                    title: Text(DemoLocalizations.of(context).searchToolBox),
                    leading: const Icon(Icons.search_sharp),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bSearch = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bMaps,
                    title: Text(DemoLocalizations.of(context).mapToolBox),
                    leading: const Icon(Icons.map_sharp),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bMaps = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bVideos,
                    title: Text(DemoLocalizations.of(context).videoToolBox),
                    leading: const Icon(Icons.video_library),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bVideos = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bEmails,
                    title: Text(DemoLocalizations.of(context).emailToolBox),
                    leading: const Icon(Icons.email_sharp),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bEmails = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bDrives,
                    title: Text(DemoLocalizations.of(context).cloudToolBox),
                    leading: const Icon(Icons.cloud_download_sharp),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bDrives = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bCalendar,
                    title: Text(DemoLocalizations.of(context).calendarToolBox),
                    leading: const Icon(Icons.calendar_month_sharp),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bCalendar = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                  SettingsTile.switchTile(
                    initialValue: curSetting.bPhotos,
                    title: Text(DemoLocalizations.of(context).photoToolBox),
                    leading: const Icon(Icons.photo_rounded),
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    onToggle: (value) {
                      setState(() {
                        curSetting.bPhotos = value;
                        widget.toolBoxesCallback(curSetting);
                      });
                    },
                  ),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}