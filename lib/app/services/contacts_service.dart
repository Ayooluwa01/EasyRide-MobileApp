import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class ContactService {
  Future<PermissionStatus> getPermission() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.readWrite,
    );
    return status;
  }

  Future<bool> ensurePermissionIsGranted(BuildContext context) async {
    PermissionStatus status = await FlutterContacts.permissions.check(
      PermissionType.readWrite,
    );

    // Guard against async gap
    if (!context.mounted) return false;

    if (status != PermissionStatus.granted &&
        status != PermissionStatus.limited) {
      status = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );
    }

    // Guard against async gap after requesting permission
    if (!context.mounted) return false;

    // Handle permanently denied status with a dialog
    if (status == PermissionStatus.permanentlyDenied) {
      final bool? shouldOpenSettings = await _showPermissionDialog(context);

      // Guard against async gap after the dialog closes
      if (!context.mounted) return false;

      if (shouldOpenSettings == true) {
        await ph.openAppSettings();
      }
      return false;
    }

    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  // Helper to show the explanation dialog
  Future<bool?> _showPermissionDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contacts Permission Needed"),
          content: Text(
            "Easy Ride requires contact access to support emergency alerts during rides. Please go to settings to enable permissions.",
            style: GoogleFonts.inter(fontSize: 10, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  Future<List<Contact>> getAllContacts(BuildContext context) async {
    final isGranted = await ensurePermissionIsGranted(context);

    if (!context.mounted) return [];

    if (isGranted) {
      return await FlutterContacts.getAll(
        properties: {
          ContactProperty.name,
          ContactProperty.phone,
          ContactProperty.email,
        },
      );
    }
    return [];
  }

  Future<List<Contact>> searchContacts(
    String query,
    BuildContext context,
  ) async {
    final isGranted = await ensurePermissionIsGranted(context);

    if (!context.mounted) return [];

    if (isGranted) {
      List<Contact> contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone},
        filter: ContactFilter.name(query),
      );
      return contacts;
    }
    return [];
  }
}
