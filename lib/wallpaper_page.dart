import 'package:flutter/material.dart';
import 'package:keras_mobile_chatbot/utils.dart';

typedef WallpaperCallback = void Function(String homepageWallpaperPath, String chatpageWallpaperPath);

class WallpaperPage extends StatefulWidget {
  final String homepageWallpaperPath;
  final String chatpageWallpaperPath;
  final WallpaperCallback wallpaperCallback;
  const WallpaperPage({super.key, required this.homepageWallpaperPath, required this.chatpageWallpaperPath, required this.wallpaperCallback,});

  @override
  _WallpaperPageState createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage> {
  final List<String> wallpaperPaths = wallpaperSettingPaths;
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
    super.key,
    required this.imagePath,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

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