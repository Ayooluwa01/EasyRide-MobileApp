import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({
    super.key,
    required this.onContinue,
    this.initialFullName,
  });

  final String? initialFullName;
  final void Function(String fullName) onContinue;

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(
      text: widget.initialFullName ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _fullNameController.text.trim();

    widget.onContinue(fullName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERSONAL INFORMATION',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tell us your name',
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Enter your full name as it should appear on your account.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'FULL NAME',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _fullNameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: _inputDecoration(context, hintText: 'John Doe'),
            validator: (value) {
              final fullName = value?.trim() ?? '';

              if (fullName.isEmpty) {
                return 'Please enter your full name';
              }

              if (fullName.length < 3) {
                return 'Full name must be at least 3 characters';
              }

              final parts = fullName
                  .split(RegExp(r'\s+'))
                  .where((part) => part.isNotEmpty)
                  .toList();

              if (parts.length < 2) {
                return 'Please enter your first and last name';
              }

              return null;
            },
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Continue',
              onPressed: _continue,
              backgroundColor: isDark
                  ? colorScheme.primary
                  : colorScheme.secondary,
              textColor: isDark
                  ? colorScheme.onPrimary
                  : colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hintText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3)),
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
    );
  }
}
