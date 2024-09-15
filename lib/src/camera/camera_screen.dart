import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../easy_camera_plus.dart';
import '../services/device_service.dart';
import '../widgets/frame_layout.dart';

const double kAspectRatioDefault = 9 / 16;
const double kAspectRatioCircle = 1.0;
const double kAspectRatioRectangle = 1.7;

class CameraScreen extends StatefulWidget {
  final CameraType cameraType;
  final FrameShape? frameShape;
  final double? aspectRatioFrame;
  final bool useCameraBack;

  const CameraScreen({
    Key? key,
    required this.cameraType,
    this.frameShape,
    this.aspectRatioFrame,
    this.useCameraBack = true,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  String? videoPath;
  List<CameraController> controllers = [];
  List<CameraDescription> cameras = [];
  late int selectedCameraIdx;

  bool isDoneInit = false;

  var _openCamera = false;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    CameraService().init().then((value) {
      controllers.addAll(CameraService.info.camerasDesc.map((e) {
        return CameraController(
          e,
          ResolutionPreset.veryHigh,
          enableAudio: false,
        );
      }).toList());

      controller = widget.useCameraBack
          ? controllers.first
          : controllers.firstWhere((element) =>
              element.description.lensDirection == CameraLensDirection.front);

      controller?.initialize().then((value) {
        setState(() {
          isDoneInit = true;
        });

        if (widget.cameraType == CameraType.video) {
          _startVideoRecording();
        }
      });
    });

    super.initState();
  }

  Future<String?> _startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null) {
      return null;
    }

    // Do nothing if a recording is on progress
    if (cameraController.value.isRecordingVideo) {
      return null;
    }

    final filePath = await DeviceService().createPath();

    try {
      await cameraController.startVideoRecording();
      videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<String?> _onTakePhoto() async {
    try {
      if (controller == null) {
        return null;
      }
      if (controller!.value.isTakingPicture) {
        // A capture is already pending, do nothing.
        return null;
      }
      final file = await controller!.takePicture();

      if (Platform.isAndroid) {
        final f = await fixExifRotation(file.path, fileRaw: File(file.path));
        return f.path;
      }

      return file.path;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<MediaData?> _stopVideoRecording() async {
    try {
      if (controller == null || !controller!.value.isRecordingVideo) {
        return null;
      }

      final file = await controller?.stopVideoRecording();
      return MediaData(
        path: file?.path,
        // bytes: await file?.readAsBytes(),
      );
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    final String errorText =
        'Error: ${e.code}\nError Message: ${e.description}';
    log(errorText);

    showMessage('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Widget _cameraPreviewWidget() {
    if (controller == null) {
      return const SizedBox();
    }
    final cameraPreview = AspectRatio(
      aspectRatio: 1 / controller!.value.aspectRatio,
      child: CameraPreview(controller!),
    );

    return Align(
      alignment: Alignment.topCenter,
      child: cameraPreview,
    );
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = controller == null
        ? kAspectRatioDefault
        : (1 / controller!.value.aspectRatio);
    final aspectRatioFrame = widget.aspectRatioFrame ??
        (widget.frameShape == FrameShape.circle
            ? kAspectRatioCircle
            : kAspectRatioRectangle);

    return FrameLayoutWidget(
      frameShape: widget.frameShape,
      cameraType: widget.cameraType,
      aspectRatio: aspectRatio,
      aspectRatioFrame: aspectRatioFrame,
      onTakePhoto: (Size sizeFramePixel) {
        switch (widget.cameraType) {
          case CameraType.photo:
            _onTakePhoto().then((value) {
              if (value != null) {
                ImageService.cropSquare(value, value, sizeFramePixel)
                    .then((img) {
                  if (context.mounted) {
                    Navigator.of(context).pop(img);
                  }
                });
              }
            });
            break;
          case CameraType.video:
            if (!_openCamera) {
              _startVideoRecording();
            } else {
              _stopVideoRecording().then((value) {
                if (context.mounted) {
                  Navigator.of(context).pop(value);
                }
              });
            }
            break;
        }
        _openCamera = true;
      },
      onTapChangeFontBack: () {},
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _cameraPreviewWidget(),
      ),
    );
  }
}
