import 'package:easy_ride/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactInfoStep extends StatefulWidget {
  const ContactInfoStep({
    super.key,
    required this.onContinue,
    this.initialPhone,
    this.initialEmail,
  });

  final String? initialPhone;
  final String? initialEmail;
  final void Function(String phone, String? email) onContinue;

  @override
  State<ContactInfoStep> createState() => _ContactInfoStepState();
}

class _ContactInfoStepState extends State<ContactInfoStep> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _numberController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.initialPhone ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _numberController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _numberController.text.trim();
    final email = _emailController.text.trim();

    widget.onContinue(phone, email.isEmpty ? null : email);
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
          // PHONE NUMBER
          Text(
            'PHONE NUMBER',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _numberController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: _inputDecoration(context, hintText: '800 000 0000'),
            validator: (value) {
              final phone = value?.trim() ?? '';

              if (phone.isEmpty) {
                return 'Please enter your phone number';
              }

              // Nigerian phone validation example.
              // final phoneRegex = RegExp(r'^(?:0|\+234)?[789]\d{9}$');

              // final normalizedPhone = phone.replaceAll(RegExp(r'[\s-]'), '');

              // if (!phoneRegex.hasMatch(normalizedPhone)) {
              //   return 'Please enter a valid phone number';
              // }

              return null;
            },
          ),

          const SizedBox(height: 20),

          // EMAIL
          Text(
            'EMAIL ADDRESS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: _inputDecoration(
              context,
              hintText: 'yourEmail@gmail.com',
            ),
            validator: (value) {
              final email = value?.trim() ?? '';

              // Email is optional according to your Prisma model.
              if (email.isEmpty) {
                return null;
              }

              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

              if (!emailRegex.hasMatch(email)) {
                return 'Please enter a valid email address';
              }

              return null;
            },
          ),

          const SizedBox(height: 28),

          // CONTINUE
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
