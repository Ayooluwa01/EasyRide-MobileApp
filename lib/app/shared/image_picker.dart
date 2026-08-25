import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

mixin ProfileImagePicker<T extends StatefulWidget> on State<T> {
  final ImagePicker _picker = ImagePicker();
  File? pickedImageFile;

  Future<void> pickProfileImage(BuildContext context) async {
    final source = await _showSourceSheet(context);
    if (source == null) return;

    final granted = await _ensurePermission(source);
    if (!granted) {
      if (context.mounted) {
        _showPermissionDeniedSnackbar(context, source);
      }
      return;
    }

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 720,
    );

    if (picked == null) return;

    setState(() {
      pickedImageFile = File(picked.path);
    });
  }

  Future<ImageSource?> _showSourceSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text("Take a photo"),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from gallery"),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.status;
    if (status.isGranted || status.isLimited) return true;

    final result = await permission.request();
    return result.isGranted || result.isLimited;
  }

  void _showPermissionDeniedSnackbar(BuildContext context, ImageSource source) {
    final label = source == ImageSource.camera ? "camera" : "photo library";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Please allow $label access in Settings to continue."),
        action: SnackBarAction(label: "SETTINGS", onPressed: openAppSettings),
      ),
    );
  }
}
