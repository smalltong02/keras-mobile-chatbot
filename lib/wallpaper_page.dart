import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

typedef WallpaperCallback = void Function(String homepageWallpaperPath, String chatpageWallpaperPath);

class WallpaperPage extends StatefulWidget {
  final String homepageWallpaperPath;
  final String chatpageWallpaperPath;
  final WallpaperCallback wallpaperCallback;
  WallpaperPage({Key? key, required this.homepageWallpaperPath, required this.chatpageWallpaperPath, required this.wallpaperCallback,}) : super(key: key);

  @override
  _WallpaperPageState createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage> {
  final List<String> wallpaperPaths = [
    'assets/backgrounds/1.jpg',
    'assets/backgrounds/2.jpg',
    'assets/backgrounds/3.jpg',
    'assets/backgrounds/4.jpg',
    'assets/backgrounds/5.jpg',
    'assets/backgrounds/6.jpg',
    'assets/backgrounds/7.jpg',
    'assets/backgrounds/8.jpg',
    'assets/backgrounds/9.jpg',
    'assets/backgrounds/10.jpg',
    'assets/backgrounds/11.jpg',
    'assets/backgrounds/12.jpg',
    'assets/backgrounds/13.jpg',
    'assets/backgrounds/14.jpg',
    'assets/backgrounds/15.jpg',
    'assets/backgrounds/16.jpg',
    'assets/backgrounds/17.jpg',
    'assets/backgrounds/18.jpg',
    'assets/backgrounds/19.jpg',
    'assets/backgrounds/20.jpg',
    'assets/backgrounds/21.jpg',
    'assets/backgrounds/22.jpg',
    'assets/backgrounds/23.jpg',
    'assets/backgrounds/24.jpg',
    'assets/backgrounds/25.jpg',
    'assets/backgrounds/26.jpg',
    'assets/backgrounds/27.jpg',
    'assets/backgrounds/28.jpg',
    'assets/backgrounds/29.jpg',
    'assets/backgrounds/30.jpg',
    'assets/backgrounds/31.jpg',
    'assets/backgrounds/32.jpg',
    'assets/backgrounds/33.jpg',
    'assets/backgrounds/34.jpg',
    'assets/backgrounds/35.jpg',
    'assets/backgrounds/36.jpg',
    'assets/backgrounds/37.jpg',
    'assets/backgrounds/38.jpg',
    'assets/backgrounds/39.jpg',
    'assets/backgrounds/40.jpg',
    'assets/backgrounds/41.jpg',
    'assets/backgrounds/42.jpg',
    'assets/backgrounds/43.jpg',
    'assets/backgrounds/44.jpg',
    'assets/backgrounds/45.jpg',
    'assets/backgrounds/46.jpg',
    'assets/backgrounds/47.jpg',
    'assets/backgrounds/48.jpg',
    'assets/backgrounds/49.jpg',
    'assets/backgrounds/50.jpg',
    'assets/backgrounds/51.jpg',
    'assets/backgrounds/52.jpg',
    'assets/backgrounds/53.jpg',
    'assets/backgrounds/54.jpg',
    'assets/backgrounds/55.jpg',
    'assets/backgrounds/56.jpg',
    'assets/backgrounds/57.jpg',
    'assets/backgrounds/58.jpg',
    'assets/backgrounds/59.jpg',
    'assets/backgrounds/60.jpg',
    'assets/backgrounds/61.jpg',
    'assets/backgrounds/62.jpg',
    'assets/backgrounds/63.jpg',
    'assets/backgrounds/64.jpg',
    'assets/backgrounds/65.jpg',
    'assets/backgrounds/66.jpg',
    'assets/backgrounds/67.jpg',
    'assets/backgrounds/68.jpg',
    'assets/backgrounds/69.jpg',
    'assets/backgrounds/70.jpg',
    'assets/backgrounds/71.jpg',
    'assets/backgrounds/72.jpg',
    'assets/backgrounds/73.jpg',
    'assets/backgrounds/74.jpg',
    'assets/backgrounds/75.jpg',
    'assets/backgrounds/76.jpg',
    'assets/backgrounds/77.jpg',
    'assets/backgrounds/78.jpg',
  ];
  String curHomepageWallpaperPath = "";
  String curChatpageWallpaperPath = "";
  bool isHomeWallpaper = true;

  @override
  void initState() {
    super.initState();
    curHomepageWallpaperPath = widget.homepageWallpaperPath;
    curChatpageWallpaperPath = widget.chatpageWallpaperPath;
  }

  void _onImageTap(String imagePath) {
    setState(() {
      if (isHomeWallpaper) {
        curHomepageWallpaperPath = imagePath;
      } else {
        curChatpageWallpaperPath = imagePath;
      }
      widget.wallpaperCallback(curHomepageWallpaperPath, curChatpageWallpaperPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isHomeWallpaper = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 10,
                      backgroundColor: isHomeWallpaper ? Colors.blueAccent.withOpacity(0.6) : Colors.white.withOpacity(0.6), // Change the color based on focus
                    ),
                    child: const Text('Home Wallpaper'),
                  ),
                ),
                const SizedBox(width: 16.0),
                SizedBox(
                  width: 200.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isHomeWallpaper = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 10,
                      backgroundColor: !isHomeWallpaper ? Colors.purpleAccent.withOpacity(0.6) : Colors.white.withOpacity(0.6), // Change the color based on focus
                    ),
                    child: const Text('Chat Wallpaper'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: wallpaperPaths.length,
                itemBuilder: (context, index) {
                  String imagePath = wallpaperPaths[index];
                  bool isSelected = imagePath == (isHomeWallpaper ? curHomepageWallpaperPath : curChatpageWallpaperPath);
                  return SelectableImage(
                    imagePath: imagePath,
                    isSelected: isSelected,
                    selectedColor: isHomeWallpaper ? Colors.blueAccent.withOpacity(0.6) : Colors.purpleAccent.withOpacity(0.6),
                    onTap: () {
                      if (isSelected) {
                        imagePath = "";
                      }
                      _onImageTap(imagePath);
                    }
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectableImage extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const SelectableImage({
    Key? key,
    required this.imagePath,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (isSelected)
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Icon(
                Icons.check_circle,
                color: selectedColor,
                size: 24.0,
              ),
            ),
        ],
      ),
    );
  }
}