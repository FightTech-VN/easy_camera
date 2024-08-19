import 'dart:async';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageService {
  static Future<String?> cropSquare(
    String srcFilePath,
    String destFilePath,
    Size sizeFrame,
  ) async {
    final bytes = await File(srcFilePath).readAsBytes();
    final img.Image? src = img.decodeImage(bytes);

    if (src != null) {
      final dxCrop = src.width / 2 - sizeFrame.width / 2;
      final dyCrop = src.height / 2 - sizeFrame.height / 2;

      final destImage = img.copyCrop(
        src,
        dxCrop.toInt(),
        dyCrop.toInt(),
        sizeFrame.width.toInt(),
        sizeFrame.height.toInt(),
      );

      final jpg = img.encodeJpg(destImage);
      await File(destFilePath).writeAsBytes(jpg);

      return destFilePath;
    }

    return null;
  }
}

Future<File> fixExifRotation(String imagePath, {File? fileRaw}) async {
  final originalFile = File(imagePath);
  final List<int> imageBytes = await (fileRaw ?? originalFile).readAsBytes();

  final originalImage = img.decodeImage(imageBytes);

  final height = originalImage!.height;
  final width = originalImage.width;

  // Let's check for the image size
  // This will be true also for upside-down photos but it's ok for me
  if (height >= width) {
    // I'm interested in portrait photos so
    // I'll just return here
    return originalFile;
  }

  // We'll use the exif package to read exif data
  // This is map of several exif properties
  // Let's check 'Image Orientation'
  final exifData = await readExifFromBytes(imageBytes);

  img.Image fixedImage;

  if (height < width) {
    final s = exifData['Image Orientation'];

    if (kDebugMode) {
      print('[CameraScteen] Rotating image necessary');
      print('[CameraScteen] $exifData');
      print('[CameraScteen] $exifData');
      print('[CameraScteen] printable: $s');
    }
    // rotate

    if (s?.printable == 'Rotated 90 CCW') {
      fixedImage = img.copyRotate(originalImage, -90);
    } else if (exifData['Image Orientation']
            ?.printable
            .contains('Horizontal') ==
        true) {
      fixedImage = img.copyRotate(originalImage, 90);
    } else if (exifData['Image Orientation']?.printable.contains('180') ==
        true) {
      fixedImage = img.copyRotate(originalImage, -90);
    } else if (exifData['Image Orientation']?.printable.contains('CCW') ==
        true) {
      fixedImage = img.copyRotate(originalImage, 180);
    } else {
      fixedImage = img.copyRotate(originalImage, 0);
    }

    // if(!(height >= width)) {
    //   fixedImage = img.copyRotate(originalImage, -90);
    // }

    // or jpg with some compression
    // I choose jpg with 100% quality
    final fixedFile =
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    return fixedFile;
  }

  return originalFile;
  // Here you can select whether you'd like to save it as png
}
