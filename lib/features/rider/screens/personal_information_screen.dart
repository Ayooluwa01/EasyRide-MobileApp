import 'package:easy_ride/app/shared/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderPersonalInformationScreen extends StatefulWidget {
  const RiderPersonalInformationScreen({super.key});

  @override
  State<RiderPersonalInformationScreen> createState() =>
      _RiderPersonalInformationScreenState();
}

class _RiderPersonalInformationScreenState
    extends State<RiderPersonalInformationScreen>
    with ProfileImagePicker {
  final _fullNameController = TextEditingController(text: "Amaka Obi");
  final _emailController = TextEditingController(text: "amaka.obi@email.com");
  final _phoneController = TextEditingController(text: "+234 812 345 6789");

  DateTime? _dateOfBirth = DateTime(1995, 8, 15);
  String? _gender = "Female";

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    DateTime tempPicked = _dateOfBirth ?? DateTime(2000, 1, 1);
    final colorScheme = Theme.of(context).colorScheme;
    final mutedTextColor = colorScheme.onSurface.withValues(alpha: 0.5);

    final picked = await showModalBottomSheet<DateTime>(
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 19,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: mutedTextColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(tempPicked),
                      child: Text(
                        "DONE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              // Wheel picker
              SizedBox(
                height: 220,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempPicked,
                  minimumDate: DateTime(1920),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (value) => tempPicked = value,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  String get _formattedDateOfBirth {
    if (_dateOfBirth == null) return '';
    final d = _dateOfBirth!;
    return '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final syneBaseStyle = GoogleFonts.syne(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );

    final InterBaseStyle = GoogleFonts.inter();

    final mutedTextColor = colorScheme.onSurface.withValues(alpha: 0.5);
    final disabledTextColor = colorScheme.onSurface.withValues(alpha: 0.4);
    final placeholderIconColor = colorScheme.onSurface.withValues(alpha: 0.3);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurface,
                      size: 18,
                    ),
                  ),

                  SizedBox(width: 10),
                  Center(
                    child: Text(
                      "Personal Info",
                      textAlign: TextAlign.center,
                      style: syneBaseStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                      child: Text(
                        textAlign: TextAlign.end,
                        "SAVE",
                        style: syneBaseStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),

              const SizedBox(height: 24),

              // profile picture
              Align(
                alignment: AlignmentGeometry.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(22),
                            image: DecorationImage(
                              image: pickedImageFile != null
                                  ? FileImage(pickedImageFile!)
                                  : const NetworkImage(
                                      'https://i.pravatar.cc/150?img=32',
                                    ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 1.5,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => pickProfileImage(context),
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'CHANGE PROFILE PHOTO',
                      style: InterBaseStyle.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: mutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // form
              _FormField(
                label: "FULL NAME",
                child: _RoundedTextField(controller: _fullNameController),
              ),
              const SizedBox(height: 20),

              _FormField(
                label: "EMAIL ADDRESS",
                child: _RoundedTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 20),

              _FormField(
                label: "PHONE NUMBER",
                child: _RoundedTextField(
                  controller: _phoneController,
                  enabled: false,
                  trailing: Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: placeholderIconColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _FormField(
                label: "DATE OF BIRTH",
                child: _RoundedTapField(
                  value: _formattedDateOfBirth,
                  onTap: _pickDateOfBirth,
                  trailing: Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: placeholderIconColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _FormField(
                label: "GENDER",
                child: _RoundedDropdownField(
                  value: _gender,
                  options: const ["Female", "Male", "Prefer not to say"],
                  onChanged: (value) => setState(() => _gender = value),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

BoxDecoration _fieldDecoration(ColorScheme colorScheme, bool isDark) {
  return BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: isDark
            ? Colors.transparent
            : Colors.black.withValues(alpha: 0.02),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? trailing;

  const _RoundedTextField({
    required this.controller,
    this.enabled = true,
    this.keyboardType,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: _fieldDecoration(colorScheme, isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _RoundedTapField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  const _RoundedTapField({
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: _fieldDecoration(colorScheme, isDark),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedDropdownField extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _RoundedDropdownField({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: _fieldDecoration(colorScheme, isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: colorScheme.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
