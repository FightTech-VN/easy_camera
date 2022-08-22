import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../mixin/timer_mixin.dart';
import '../models/camera_info.dart';
import 'camera_video_button.dart';
import 'capture_camera_button.dart';
import 'dot_decoration.dart';

class FrameLayoutWidget extends StatefulWidget {
  final Color? colorFrame;
  final Widget child;
  final Function onTakePhoto;
  final CameraType cameraType;
  final FrameShape? frameShape;

  const FrameLayoutWidget({
    Key? key,
    required this.child,
    required this.onTakePhoto,
    required this.cameraType,
    this.frameShape,
    this.colorFrame,
  }) : super(key: key);

  @override
  State<FrameLayoutWidget> createState() => _FrameLayoutWidgetState();
}

class _FrameLayoutWidgetState extends State<FrameLayoutWidget> with TimerMixin {
  /// Display a row of toggle to select the camera
  ///  (or a message if no camera is available).
  // Widget _cameraTogglesRowWidget() {

  //   final selectedCamera = cameras[selectedCameraIdx];
  //   final lensDirection = selectedCamera.lensDirection;

  //   return TextButton.icon(
  //     onPressed: _onSwitchCamera,
  //     icon: Icon(_getCameraLensIcon(lensDirection)),
  //     label: Text(
  //       lensDirection
  //           .toString()
  //           .substring(lensDirection.toString().indexOf('.') + 1),
  //     ),
  //   );
  // }

  // /// Display the control bar with buttons to record videos.
  // Widget _captureControlRowWidget() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     mainAxisSize: MainAxisSize.max,
  //     children: <Widget>[
  //       IconButton(
  //         icon: const Icon(Icons.videocam),
  //         color: Colors.blue,
  //         onPressed: controller!.value.isInitialized &&
  //                 !controller!.value.isRecordingVideo
  //             ? _onRecordButtonPressed
  //             : null,
  //       ),
  //       IconButton(
  //         icon: const Icon(Icons.stop),
  //         color: Colors.red,
  //         onPressed: controller!.value.isInitialized &&
  //                 controller!.value.isRecordingVideo
  //             ? _onStopButtonPressed
  //             : null,
  //       )
  //     ],
  //   );
  // }
  late CameraType cameraType;
  bool isRecording = false;

  void _onTapTake() {
    widget.onTakePhoto();
  }

  @override
  void initState() {
    cameraType = widget.cameraType;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          widget.child,
          if (widget.frameShape != null)
            LayoutBuilder(builder: (context, contraint) {
              final wid = MediaQuery.of(context).size.width * 0.8 > 400
                  ? 400.0
                  : MediaQuery.of(context).size.width * 0.8;
              return Align(
                alignment: Alignment.center,
                child: widget.frameShape == FrameShape.rectangle
                    ? Container(
                        width: wid,
                        height: wid / 1.7,
                        decoration: const DottedDecoration(
                            color: Colors.black,
                            shape: Shape.box,
                            strokeWidth: 3.0),
                      )
                    : Container(
                        width: wid,
                        height: wid,
                        decoration: const DottedDecoration(
                            shape: Shape.circle, strokeWidth: 2.0),
                      ),
              );
            }),
          if (cameraType == CameraType.video && isRecording)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SafeArea(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 90),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.red,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 12),
                        child: ValueListenableBuilder<int>(
                          valueListenable: timeCtr,
                          builder: (context, value, child) {
                            return Text(
                              '${value ~/ 3600}:${value ~/ 60}:${value % 60}',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.caption?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        letterSpacing: -0.3,
                                      ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: widget.colorFrame ??
                      Theme.of(context).colorScheme.secondary,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: 25, top: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: CameraType.values
                              .map((e) => GestureDetector(
                                    onPanUpdate: (details) {},
                                    onTap: () {
                                      setState(() {
                                        cameraType = e;
                                      });
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 88, minHeight: 33),
                                      decoration: cameraType != e
                                          ? null
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                  color: Colors.white)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        e.name.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontSize: 13,
                                              letterSpacing: -0.3,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(
                              width: 70,
                              child: GestureDetector(
                                onTap: Navigator.of(context).pop,
                                child: Text(
                                  'Cancel',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.copyWith(
                                          color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              firstChild: CaptureCameraButton(
                                isDisabled: false,
                                onTap: _onTapTake,
                              ),
                              secondChild: CameraVideoButton(
                                onChangeRecording: (r) {
                                  setState(() {
                                    isRecording = r;
                                  });
                                  if (isRecording) {
                                    startTimer();
                                  }
                                },
                              ),
                              crossFadeState: cameraType == CameraType.photo
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                            ),
                            SizedBox(
                              width: 70,
                              child: GestureDetector(
                                onTap: Navigator.of(context).pop,
                                child: const Icon(
                                  CupertinoIcons.camera_rotate,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(
          //     top: MediaQuery.of(context).padding.top + 24,
          //   ),
          //   child: GestureDetector(
          //     onTap: Navigator.of(context).pop,
          //     child: Container(
          //       width: 32,
          //       height: 32,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(16),
          //         border: Border.all(color: Colors.white),
          //       ),
          //       child: const Icon(
          //         Icons.close,
          //         color: Colors.white,
          //         size: 26,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  bool get isCountDown => true;

  @override
  void onCompleteTimer() {
    log('---HieuLog done recoding');
  }

  @override
  int get timeInputLimit => 15;
}
