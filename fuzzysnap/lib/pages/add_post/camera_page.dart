import 'dart:io';
// import 'dart:js_interop';
import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/add_post/post_page.dart';
import 'package:path_provider/path_provider.dart';

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
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory!.path}/$fileName');

    try {
      await file.writeAsBytes(await image.readAsBytes());
    } catch (e) {
      print("Error saving image: $e");
    }

    return file;
  }

  void takePicture() async {
    XFile? image;
    if (cameraController.value.isTakingPicture ||
        !cameraController.value.isInitialized) {
      return;
    }
    if (isFlashOn == false) {
      await cameraController.setFlashMode(FlashMode.off);
    } else {
      await cameraController.setFlashMode(FlashMode.torch);
    }
    image = await cameraController.takePicture();
    if (cameraController.value.flashMode == FlashMode.torch) {
      setState(() {
        cameraController.setFlashMode(FlashMode.off);
      });
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

  void startCamera(int camera) {
    cameraController = CameraController(
        widget.cameras[camera], ResolutionPreset.high,
        enableAudio: false);
    cameraValue = cameraController.initialize();
  }

  @override
  void initState() {
    startCamera(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: const FloatingActionButton(
      //   backgroundColor: Color.fromRGBO(255, 255, 255, 7),
      //   onPressed: null,
      //   shape: CircleBorder(),
      //   child: Icon(Icons.camera_alt_rounded, size: 40,),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
              const SizedBox(
                height: 25,
              ),
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
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
              const SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // change camera
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isRealCamera = !isRealCamera;
                      });
                      isRealCamera ? startCamera(0) : startCamera(1);
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
                  // take photo
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
                  //flash mode
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
}
