import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

class DeviceService {
  Future<String> createPath([bool isVideo = true]) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory =
        '${appDirectory.path}/${isVideo ? 'Videos' : 'Image'}';

    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

    return '$videoDirectory/$currentTime.${isVideo ? 'mp4' : 'jpg'}';
  }

  FutureOr<File?> cropSquare(
      String srcFilePath, String destFilePath, bool flip) async {
    final bytes = await File(srcFilePath).readAsBytes();
    final src = decodeImage(bytes);

    if (src == null) {
      return null;
    }

    final cropSize = min(src.width, src.height);
    final offsetX = (src.width - min(src.width, src.height)) ~/ 2;
    final offsetY = (src.height - min(src.width, src.height)) ~/ 2;

    Image destImage = copyCrop(
      src,
      x: offsetX,
      y: offsetY,
      width: cropSize,
      height: cropSize,
    );

    if (flip) {
      destImage = flipVertical(destImage);
    }

    final jpg = encodeJpg(destImage);
    return await File(destFilePath).writeAsBytes(jpg);
  }
}
