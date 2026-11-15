import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    initCamera(selectedCameraIndex);
  }

  Future<void> initCamera(int index) async {
    if (cameras.isEmpty) return;

    controller = CameraController(
      cameras[index],
      ResolutionPreset.max,
    );

    controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void switchCamera() async {
    if (cameras.length < 2) return;

    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;

    await controller?.dispose();
    setState(() {
      controller = null;
    });

    initCamera(selectedCameraIndex);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Camera Preview'),
        ),
        body: Column(
          children: [
            CameraPreview(controller!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: switchCamera,
              child: const Text('Switch Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
