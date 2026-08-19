import 'dart:io';

import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

enum UserRole { rider, driver }

class ProfileInfoStep extends StatefulWidget {
  const ProfileInfoStep({
    super.key,
    required this.onSubmit,
    this.initialRole,
    this.initialProfilePhoto,
  });

  final UserRole? initialRole;
  final XFile? initialProfilePhoto;

  final void Function(UserRole role, XFile? profilePhoto) onSubmit;

  @override
  State<ProfileInfoStep> createState() => _ProfileInfoStepState();
}

class _ProfileInfoStepState extends State<ProfileInfoStep> {
  UserRole? _selectedRole;
  XFile? _profilePhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _profilePhoto = widget.initialProfilePhoto;
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (photo == null) {
      return;
    }

    setState(() {
      _profilePhoto = photo;
    });
  }

  void _submit() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your account type')),
      );

      return;
    }

    widget.onSubmit(_selectedRole!, _profilePhoto);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROFILE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Complete your profile',
          style: GoogleFonts.syne(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Choose how you want to use EasyRide and add a profile photo.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.5,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),

        const SizedBox(height: 28),

        // PROFILE PHOTO
        Center(
          child: GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ClipOval(
                    child: _profilePhoto != null
                        ? Image.file(
                            File(_profilePhoto!.path),
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person_outline_rounded,
                            size: 48,
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.35,
                            ),
                          ),
                  ),
                ),

                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      border: Border.all(color: colorScheme.surface, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: TextButton(
            onPressed: _pickPhoto,
            child: Text(
              _profilePhoto == null ? 'Add profile photo' : 'Change photo',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ROLE
        Text(
          'ACCOUNT TYPE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),

        const SizedBox(height: 10),

        _roleOption(
          role: UserRole.rider,
          title: 'Rider',
          description: 'Book rides and travel around town',
          icon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 12),

        _roleOption(
          role: UserRole.driver,
          title: 'Driver',
          description: 'Accept rides and earn money',
          icon: Icons.directions_car_outlined,
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Create Account',
            onPressed: _submit,
            backgroundColor: isDark
                ? colorScheme.primary
                : colorScheme.secondary,
            textColor: isDark ? colorScheme.onPrimary : colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }

  Widget _roleOption({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.1),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
