import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> initializeControllerFuture;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  List<String> imagePathList = [];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.veryHigh,
    );

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      _controller.getMinZoomLevel().then((minZoom) {
        setState(() {
          _minAvailableZoom = minZoom;
        });
      });

      _controller.getMaxZoomLevel().then((maxZoom) {
        setState(() {
          _maxAvailableZoom = maxZoom;
        });
      });
    });
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
  // Calculate the new zoom level based on the scale update
    double scale = details.scale.clamp(_minAvailableZoom, _maxAvailableZoom); // Clamp scale to a reasonable range
    double newZoomLevel = _currentZoomLevel * scale;

    // Calculate a very small incremental change in zoom level for very slow scaling
    double zoomIncrement = (newZoomLevel - _currentZoomLevel) / 500.0; // Adjust divisor for very slow speed

    // Update zoom level gradually
    Future<void> updateZoom() async {
      while ((_currentZoomLevel - newZoomLevel).abs() > 0.01) { // Adjust tolerance for smoothness
        _currentZoomLevel += zoomIncrement;
        _currentZoomLevel = _currentZoomLevel.clamp(_minAvailableZoom, _maxAvailableZoom);

        setState(() {
          _currentZoomLevel = _currentZoomLevel;
        });

        await Future.delayed(Duration(milliseconds: 50)); // Increase delay duration for very slow zooming
      }

      // Ensure final zoom level is set correctly
      _currentZoomLevel = newZoomLevel.clamp(_minAvailableZoom, _maxAvailableZoom);
      _controller.setZoomLevel(_currentZoomLevel);
    }

    updateZoom();
  }

  @override
  void dispose() {
    _controller.dispose();
    // Return the imagePathList to the previous screen
    Navigator.of(context).pop(imagePathList);
    super.dispose();
  }

  void addImage(String path) {
    setState(() {
      imagePathList.add(path);
    });
  }

  void removeImage(String path) {
    setState(() {
      imagePathList.remove(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(imagePathList);
          },
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onScaleUpdate: handleScaleUpdate,
            child: Stack(
              children: <Widget>[
                CameraPreview(_controller),
                Center(
                  child: Text(
                    'Zoom: ${_currentZoomLevel.toStringAsFixed(1)}x',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
                if (imagePathList.isNotEmpty) ...{
                  Positioned(
                    bottom: 8.0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: imagePathList.map((filePath) {
                          return Stack(
                            children: [
                              Image.file(
                                io.File(filePath),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 16,
                                  ),
                                  onPressed: () => removeImage(filePath),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                },
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );

            if (result == true) {
              addImage(image.path);
            }
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(child: Image.file(io.File(imagePath))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 10,
                      backgroundColor: Colors.pinkAccent.withOpacity(0.6),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      io.File(imagePath).deleteSync();
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 10,
                      backgroundColor: Colors.amberAccent.withOpacity(0.6),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}