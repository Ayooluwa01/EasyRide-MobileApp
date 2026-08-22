import 'package:easy_ride/features/auth/screens/steps/contact_info_step.dart';
import 'package:easy_ride/features/auth/screens/steps/personal_info_step.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_ride/features/auth/screens/steps/profile_info_step.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Current form step
  int step = 0;
  UserRole? role;

  XFile? profilePhoto;
  String? fullName;
  String? phone;
  String? email;
  void nextStep() {
    if (step < 2) {
      setState(() {
        step++;
      });
    }
  }

  void prevStep() {
    if (step > 0) {
      setState(() {
        step--;
      });
    }
  }

  void _handlePersonalInfo(String newFullName) {
    setState(() {
      fullName = newFullName;
      step++;
    });
  }

  void _handleContactInfo(String newPhone, String? newEmail) {
    setState(() {
      phone = newPhone;
      email = newEmail;
      step++;
    });
  }

  void _handleProfileInfo(UserRole newRole, XFile? newProfilePhoto) {
    setState(() {
      role = newRole;
      profilePhoto = newProfilePhoto;
    });

    _submitSignup();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    void goBack() {
      if (step > 0) {
        prevStep();
        return;
      }

      if (context.canPop()) {
        context.pop();
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: goBack,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: colorScheme.onSurface,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              SizedBox(
                width: double.infinity,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.syne(
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: 'Welcome to \n',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      TextSpan(
                        text: 'Easy',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      TextSpan(
                        text: 'Ride',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Step indicator
              _buildStepIndicator(context, colorScheme),

              const SizedBox(height: 32),

              // Current step
              _formSteps(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formSteps() {
    switch (step) {
      case 0:
        return PersonalInfoStep(
          initialFullName: fullName,
          onContinue: _handlePersonalInfo,
        );

      case 1:
        return ContactInfoStep(
          initialPhone: phone,
          initialEmail: email,
          onContinue: _handleContactInfo,
        );

      case 2:
        return ProfileInfoStep(
          initialRole: role,
          initialProfilePhoto: profilePhoto,
          onSubmit: _handleProfileInfo,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepIndicator(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        _stepCircle(number: 1, active: step >= 0, colorScheme: colorScheme),
        Expanded(
          child: _stepLine(active: step >= 1, colorScheme: colorScheme),
        ),
        _stepCircle(number: 2, active: step >= 1, colorScheme: colorScheme),
        Expanded(
          child: _stepLine(active: step >= 2, colorScheme: colorScheme),
        ),
        _stepCircle(number: 3, active: step >= 2, colorScheme: colorScheme),
      ],
    );
  }

  Widget _stepCircle({
    required int number,
    required bool active,
    required ColorScheme colorScheme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? colorScheme.primary : colorScheme.surface,
        border: Border.all(
          color: active
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.15),
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _stepLine({required bool active, required ColorScheme colorScheme}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: active
          ? colorScheme.primary
          : colorScheme.onSurface.withValues(alpha: 0.1),
    );
  }

  void _submitSignup() {
    debugPrint('Full name: $fullName');
    debugPrint('Phone: $phone');
    debugPrint('Email: $email');
    debugPrint('Role: $role');
    debugPrint('Profile photo: ${profilePhoto?.path}');
  }
}
