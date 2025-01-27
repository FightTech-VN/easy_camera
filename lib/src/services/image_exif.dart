import 'dart:developer';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;

Future<File> fixExifRotation(String imagePath) async {
  final originalFile = File(imagePath);
  final imageBytes = await originalFile.readAsBytes();

  final originalImage = img.decodeImage(imageBytes);

  final height = originalImage!.height;
  final width = originalImage.width;

  // Let's check for the image size
  if (height >= width) {
    // I'm interested in portrait photos so
    // I'll just return here
    return originalFile;
  }

  // We'll use the exif package to read exif data
  // This is map of several exif properties
  // Let's check 'Image Orientation'
  final exifData = await readExifFromBytes(imageBytes);

  img.Image? fixedImage;

  if (height < width) {
    log('Rotating image necessary');
    // rotate
    if (exifData['Image Orientation']?.printable.contains('Horizontal') ==
        true) {
      fixedImage = img.copyRotate(originalImage, angle: 90);
    } else if (exifData['Image Orientation']?.printable.contains('180') ==
        true) {
      fixedImage = img.copyRotate(originalImage, angle: -90);
    } else {
      fixedImage = img.copyRotate(originalImage, angle: 0);
    }
  }

  // Here you can select whether you'd like to save it as png
  // or jpg with some compression
  // I choose jpg with 100% quality
  final fixedFile = await originalFile.writeAsBytes(img.encodeJpg(fixedImage!));

  return fixedFile;
}
