import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart'; // Thay thế external_path bằng path_provider
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/add_post/post_page.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  List<File> imagesList = [];
  bool isFlashOn = false;
  bool isRealCamera = true;

  Future<File> saveImage(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$fileName');

    try {
      await file.writeAsBytes(await image.readAsBytes());
    } catch (e) {
      print('Error saving image: $e');
    }

    return file;
  }

  Future<void> takePicture() async {
    if (!cameraController.value.isInitialized || cameraController.value.isTakingPicture) {
      return;
    }

    if (isFlashOn) {
      await cameraController.setFlashMode(FlashMode.torch);
    } else {
      await cameraController.setFlashMode(FlashMode.off);
    }

    XFile image = await cameraController.takePicture();

    if (cameraController.value.flashMode == FlashMode.torch) {
      await cameraController.setFlashMode(FlashMode.off);
    }

    final file = await saveImage(image);

    // Chuyển đến PostPage
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostPage(
            imageFile: file,
            cameraAspectRatio: cameraController.value.aspectRatio,
          )),
    );
  }

  void startCamera(int camera) async {
    cameraController = CameraController(
        widget.cameras[camera], ResolutionPreset.high,
        enableAudio: false);
    cameraValue = cameraController.initialize();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      startCamera(0);
    } else {
      // Xử lý lỗi không có camera
      print('No cameras available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "TAKE GREAT PICTURE",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              FutureBuilder(
                  future: cameraValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: AspectRatio(
                              aspectRatio: cameraController.value.aspectRatio,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: CameraPreview(cameraController),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isRealCamera = !isRealCamera;
                        startCamera(isRealCamera ? 0 : 1);
                      });
                    },
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5EFE2),
                          shape: BoxShape.circle,
                        ),
                        child: isRealCamera
                            ? const Icon(Icons.camera_rear,
                            color: Color(0xFF4E7360))
                            : const Icon(Icons.camera_front,
                            color: Color(0xFF4E7360))),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      takePicture();
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4E7360),
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFlashOn = !isFlashOn;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5EFE2),
                        shape: BoxShape.circle,
                      ),
                      child: isFlashOn
                          ? const Icon(
                        Icons.flash_on,
                        color: Color(0xFF4E7360),
                        size: 30,
                      )
                          : const Icon(
                        Icons.flash_off,
                        color: Color(0xFF4E7360),
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
