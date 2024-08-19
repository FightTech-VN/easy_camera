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
    final printable = exifData['Image Orientation']?.printable;

    ///
    /// {Image ImageWidth: 1280, Image ImageLength: 720, Image Make: [71, 111, 111, 103, 108, 101], Image Model: [115, 100, 107, 95, 103, 112, 104, 111, 110, 101, 54, 52, 95, 97, 114, 109, 54, 52], Image Orientation: Rotated 90 CCW, Image DateTime: 2024:08:20 02:48:53, Image ExifOffset: 142, EXIF ExposureTime: 23/10000, EXIF FNumber: 173/100, EXIF ISOSpeedRatings: 100, EXIF ExifVersion: 0220, EXIF DateTimeOriginal: 2024:08:20 02:48:53, EXIF DateTimeDigitized: 2024:08:20 02:48:53, EXIF ShutterSpeedValue: 43917/5000, EXIF ApertureValue: 3163/2000, EXIF SubjectDistance: 49/500, EXIF Flash: No flash function, EXIF FocalLength: 219/50, EXIF SubSecTime: 281, EXIF SubSecTimeOriginal: 281, EXIF SubSecTimeDigitized: 281, EXIF ColorSpace: 65534, EXIF ExifImageWidth: 1280, EXIF ExifImageLength: 720, EXIF ExposureMode: Auto Exposure, EXIF WhiteBalance: Auto, EXIF DigitalZoomRatio: 63/20, EXIF FocalLengthIn35mmFilm: 18952, EXIF SubjectDistanceRange: 1}
    ///
    if (kDebugMode) {
      print('[ImageService] Rotating image necessary');
      print('[ImageService] $exifData');
      print('[ImageService] $exifData');
      print('[ImageService] printable: $printable');
    }

    // rotate
    if (printable == 'Rotated 90 CCW') {
      fixedImage = img.copyRotate(originalImage, -90);
    } else if (printable?.contains('Horizontal') == true) {
      fixedImage = img.copyRotate(originalImage, 90);
    } else if (printable?.contains('180') == true) {
      fixedImage = img.copyRotate(originalImage, -90);
    } else if (printable?.contains('CCW') == true) {
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
