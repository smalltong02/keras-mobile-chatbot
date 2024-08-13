import 'package:flutter/material.dart';
import 'l10n/localization_intl.dart';
import 'package:provider/provider.dart';
import 'package:keras_mobile_chatbot/utils.dart';

typedef CharacterCallback = void Function(String characterPath);

class DetailPage extends StatefulWidget {
  final Character character;
  final bool checkMark;
  final CharacterCallback characterCallback;

  const DetailPage({
    super.key,
    required this.character,
    required this.checkMark,
    required this.characterCallback,
  });

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool checkMark = false;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    checkMark = widget.checkMark;
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() {
      checkMark = true;
      widget.characterCallback(widget.character.avatar ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    Color btnColor = const Color.fromARGB(128, 255, 255, 255);
    return Stack(
      children: [
        RepaintBoundary(
          child: Hero(
            tag: "background_${widget.character.title}",
            child: Container(
              color: Color(widget.character.color!),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Color(widget.character.color!),
            elevation: 0,
            title: Text(widget.character.title!),
            leading: const CloseButton(),
            actions: [
              if (checkMark) ...{
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Icon(
                    Icons.person_pin_circle_sharp,
                    color: Colors.white70,
                  ),
                ),
              },
            ],
          ),
          body: GestureDetector(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        tag: "image_${widget.character.title}",
                        child: Image.asset(
                          widget.character.avatar!,
                          height: MediaQuery.of(context).size.height / 2,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, widget) => Transform.translate(
                          transformHitTests: false,
                          offset: Offset.lerp(
                              const Offset(0.0, 200.0), Offset.zero, _controller.value)!,
                          child: widget,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            widget.character.description!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: _onDoubleTap,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                        backgroundColor: btnColor,
                        minimumSize: const Size(220, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: Text(DemoLocalizations.of(context).selectBtn),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class CharactersListPage extends StatefulWidget {
  final List<Character> charactersList;
  final String characterIconPath;
  final CharacterCallback characterCallback;
  const CharactersListPage({super.key, required this.charactersList, required this.characterIconPath, required this.characterCallback});

  @override
  CharactersListState createState() => CharactersListState();
}

class CharactersListState extends State<CharactersListPage> {
  PageController? _controller;
  List<Character> curCharactersList = [];
  String selectedCharacterPath = "";
  double _currentPage = 0.0;

  void _goToDetail(Character character) {
    bool checkMark = false;
    String characterPath = character.avatar ?? "";
    String curRolePath = Provider.of<SettingProvider>(context, listen: false).roleIconPath;
    String curPlayerPath = Provider.of<SettingProvider>(context, listen: false).playerIconPath;
    if (characterPath == curRolePath || characterPath == curPlayerPath) {
      checkMark = true;
    }
    final page = DetailPage(character: character, characterCallback: widget.characterCallback, checkMark: checkMark);
    Navigator.of(context).push(
      PageRouteBuilder<Null>(
        pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: animation.value,
                  child: page,
                );
              }
            );
          },
          transitionDuration: const Duration(milliseconds: 400)
        ),
    );
  }

  void _pageListener() {
    setState(() {
      _currentPage = _controller?.page ?? 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    curCharactersList = widget.charactersList;
    selectedCharacterPath = widget.characterIconPath;
    _controller = PageController(viewportFraction: 0.6);
    _controller!.addListener(_pageListener);
  }

  @override
  void dispose() {
    _controller!.removeListener(_pageListener);
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).titleCharacterCards),
        backgroundColor: Colors.black54,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(getWallpaperTbPath('bk-4')),
            fit: BoxFit.cover,
          ),
        ),
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _controller,
          itemCount: curCharactersList.length,
          itemBuilder: (context, index) {
            final double resizeFactor = (1 - (((_currentPage - index).abs() * 0.3).clamp(0.0, 1.0)));
            final currentCharacter = curCharactersList[index];

            return ListItem(
              character: currentCharacter,
              resizeFactor: resizeFactor,
              characterCallback: widget.characterCallback,
              onTap: () => _goToDetail(currentCharacter),
            );
          },
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final Character character;
  final double resizeFactor;
  final CharacterCallback characterCallback;
  final VoidCallback onTap;

  const ListItem({
    super.key,
    required this.character,
    required this.resizeFactor,
    required this.characterCallback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
      builder: (context, settingProvider, _) {
        String curRolePath = settingProvider.roleIconPath;
        String curPlayerPath = settingProvider.playerIconPath;
        double height = MediaQuery.of(context).size.height * 0.4;
        double width = MediaQuery.of(context).size.width * 0.85;
        bool bSelected = false;
        if (character.avatar! == curRolePath || character.avatar! == curPlayerPath) {
          bSelected = true;
        }

        return InkWell(
          onTap: onTap,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width * resizeFactor,
              height: height * resizeFactor,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: height / 4,
                    bottom: 0,
                    child: Hero(
                      tag: "background_${character.title}",
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(character.color!),
                                Colors.white,
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            margin: const EdgeInsets.only(
                              left: 20,
                              bottom: 10,
                            ),
                            child: Text(
                              character.title!,
                              style: TextStyle(
                                fontSize: 24 * resizeFactor,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (bSelected)
                    Positioned(
                      top: 115,
                      left: 15,
                      child: Icon(
                        Icons.person_pin_circle_sharp,
                        size: width / 15,
                      ),
                    ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Hero(
                      tag: "image_${character.title}",
                      child: Image.asset(
                        character.avatar!,
                        width: width / 2,
                        height: height,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}