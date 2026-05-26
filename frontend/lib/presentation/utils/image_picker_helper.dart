import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/di/injection.dart';
import '../widgets/common/app_snackbars.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image slightly for better performance
      );

      if (image != null) {
        return File(image.path);
      }
    } catch (e, st) {
      getIt<Talker>().handle(e, st, 'Error picking image from gallery');

      if (context.mounted) {
        AppSnackbars.showError(context, 'Failed to pick image');
      }
    }
    return null;
  }
}