import 'dart:io';
import 'dart:typed_data';

import 'package:easy_camera_plus/easy_camera_plus.dart';
import 'package:flutter/material.dart';

import 'video_widget.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Easy Plus Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Camera Easy Plus Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? text;
  String? imagePath;
  String? imagePath2;
  Uint8List? videoFile;

  Widget _buildImage() {
    if (imagePath?.contains('/data/user/') == true) {
      return Image.file(
        File(imagePath!),
      );
    }
    return imagePath?.contains('http') == true
        ? Image.network(
            imagePath!,
          )
        : Image.asset(
            imagePath!,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: () {
              context
                  .startCamera(
                cameraType: CameraType.photo,
              )
                  .then((value) {
                setState(() {
                  imagePath = value;
                });
              });
            },
            icon: const Icon(Icons.photo_album),
            label: const Text('Take Photo'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              context
                  .startCamera(
                cameraType: CameraType.photo,
                frameShape: FrameShape.circle,
              )
                  .then((value) {
                setState(() {
                  imagePath = value;
                  text = value;
                });
              });
            },
            icon: const Icon(Icons.photo_album),
            label: const Text('Take Photo Frame Circle'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                    builder: (context) => const CameraScreen(
                          cameraType: CameraType.photo,
                          frameShape: FrameShape.rectangle,
                        )),
              )
                  .then((value) {
                setState(() {
                  imagePath = value;
                });
              });
            },
            icon: const Icon(Icons.photo_album),
            label: const Text('Take Photo Frame rectangle'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              context
                  .startCamera(
                cameraType: CameraType.video,
                frameShape: FrameShape.circle,
                useCameraBack: false,
              )
                  .then((value) {
                final info = value as MediaData;

                setState(() {
                  videoFile = info.bytes;
                  text = info.path;
                });
              });
            },
            icon: const Icon(Icons.video_camera_back_rounded),
            label: const Text('Record Video'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(child: Text(text ?? '-')),
            if (imagePath != null) _buildImage(),
            if (text?.isNotEmpty ?? false) VideoApp(path: text!)
          ],
        ),
      ),
    );
  }
}
