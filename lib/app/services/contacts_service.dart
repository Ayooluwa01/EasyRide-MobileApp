import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService(ref);
});

class ContactService {
  final Ref ref;
  ContactService(this.ref);
  ApiClient get _apiClient => ref.read(apiClientProvider);
  Future<PermissionStatus> getPermission() async {
    return await FlutterContacts.permissions.request(PermissionType.readWrite);
  }

  Future<bool> ensurePermissionIsGranted(BuildContext context) async {
    PermissionStatus status = await FlutterContacts.permissions.check(
      PermissionType.readWrite,
    );
    if (!context.mounted) return false;

    if (status != PermissionStatus.granted &&
        status != PermissionStatus.limited) {
      status = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );
    }

    if (!context.mounted) return false;

    if (status == PermissionStatus.permanentlyDenied) {
      final shouldOpenSettings = await _showPermissionDialog(context);

      if (!context.mounted) return false;

      if (shouldOpenSettings == true) {
        await ph.openAppSettings();
      }

      return false;
    }

    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  Future<bool?> _showPermissionDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contacts Permission Needed'),
          content: Text(
            'Easy Ride requires contact access to support emergency alerts during rides. Please go to settings to enable permissions.',
            style: GoogleFonts.inter(fontSize: 10, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Contact>> getAllContacts(BuildContext context) async {
    final isGranted = await ensurePermissionIsGranted(context);

    if (!context.mounted) return [];

    if (!isGranted) return [];

    return await FlutterContacts.getAll(
      properties: {
        ContactProperty.name,
        ContactProperty.phone,
        ContactProperty.email,
      },
    );
  }

  Future<List<Contact>> searchContacts(
    String query,
    BuildContext context,
  ) async {
    final isGranted = await ensurePermissionIsGranted(context);

    if (!context.mounted) return [];

    if (!isGranted) return [];

    return await FlutterContacts.getAll(
      properties: {ContactProperty.name, ContactProperty.phone},
      filter: ContactFilter.name(query),
    );
  }

  Future<void> saveContact({
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.post(
        '/user/me/contacts',
        data: {'name': name, 'phone': phone},
      );
      developer.log("save contact response $response");
      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('Contact saved successfully: $name - $phone');
        return;
      }

      throw Exception(
        'Failed to save contact. Status code: ${response.statusCode}',
      );
    } catch (e) {
      developer.log('Failed to save contact: $name - $phone', error: e);
      rethrow;
    }
  }
}
