import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ProfileImageService {
  ProfileImageService._();
  static final instance = ProfileImageService._();

  // Notifier to broadcast changes to the saved profile image
  final ValueNotifier<File?> imageNotifier = ValueNotifier<File?>(null);

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/profile_image.png");
  }

  Future<File?> getImage() async {
    final file = await _getFile();
    if (await file.exists()) {
      imageNotifier.value = file;
      return file;
    }
    imageNotifier.value = null;
    return null;
  }

  Future<void> saveImage(File img) async {
    final file = await _getFile();
    await file.writeAsBytes(await img.readAsBytes());
    imageNotifier.value = file;
  }

  Future<void> deleteImage() async {
    final file = await _getFile();
    if (await file.exists()) await file.delete();
    imageNotifier.value = null;
  }
}
