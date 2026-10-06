import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/api/endpoints.dart';
import 'package:easy_ride/app/router/route_names.dart';
import 'package:easy_ride/app/shared/app_toast.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoDatePicker, CupertinoDatePickerMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteInformationScreen extends ConsumerStatefulWidget {
  const CompleteInformationScreen({super.key});

  @override
  ConsumerState<CompleteInformationScreen> createState() =>
      _CompleteInformationScreenState();
}

class _CompleteInformationScreenState
    extends ConsumerState<CompleteInformationScreen> {
  final stepTitles = ['Personal', 'Vehicle', 'Documents', 'Bank'];
  final vehicleTypes = ['ECONOMY', 'COMFORT', 'PREMIUM', 'SUV'];
  final picker = ImagePicker();

  bool loading = true;
  bool saving = false;
  int step = 0;

  // set when the driver has already submitted
  String? verificationStatus;
  String? rejectionReason;

  // true when a rejected driver is editing their application
  bool isCorrecting = false;

  // step 0: personal
  File? profilePhoto;
  DateTime? dob;

  // step 1: vehicle
  final make = TextEditingController();
  final model = TextEditingController();
  final year = TextEditingController();
  final plate = TextEditingController();
  final color = TextEditingController();
  String vehicleType = 'ECONOMY';
  bool hasAC = false;
  List<File> vehiclePhotos = [];

  // step 2: documents
  File? licenseFront;
  File? licenseBack;
  File? vehicleRegistration;
  File? insurance; // optional
  File? driverPhoto; // optional

  // step 3: bank
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final accountName = TextEditingController();

  // what the server already has (shown as network images)
  String? existingProfilePhotoUrl;
  List<String> existingVehiclePhotoUrls = [];
  String? existingLicenseFront;
  String? existingLicenseBack;
  String? existingVehicleRegistration;
  String? existingInsurance;
  String? existingDriverPhoto;

  @override
  void initState() {
    super.initState();
    loadStatus();
  }

  @override
  void dispose() {
    make.dispose();
    model.dispose();
    year.dispose();
    plate.dispose();
    color.dispose();
    bankName.dispose();
    accountNumber.dispose();
    accountName.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // API calls
  // ------------------------------------------------------------

  Future<void> loadStatus() async {
    try {
      final res = await ref
          .read(apiClientProvider)
          .get(Endpoints.driverProfileStatus);

      final data = res.data['data'];
      final onboardingStep = data['onboardingStep'];

      fillFromApplication(data['application']);

      if (onboardingStep == 'SUBMITTED') {
        isCorrecting = false;
        verificationStatus = data['verificationStatus'];
        rejectionReason = data['rejectionReason'];
      } else {
        verificationStatus = null;
        if (onboardingStep == 'PERSONAL_INFO') step = 0;
        if (onboardingStep == 'VEHICLE_INFO') step = 1;
        if (onboardingStep == 'DOCUMENTS') step = 2;
        if (onboardingStep == 'BANK_DETAILS') step = 3;
      }
    } catch (e) {
      showError('Could not load your profile status');
    }

    if (mounted) setState(() => loading = false);
  }

  // Fills the form with what the driver already submitted
  void fillFromApplication(dynamic app) {
    if (app == null) return;

    existingProfilePhotoUrl = app['profilePhotoUrl'];

    if (app['dateOfBirth'] != null) {
      final parsed = DateTime.parse(app['dateOfBirth']);
      // keep only the date so time zones can't shift the day
      dob = DateTime(parsed.year, parsed.month, parsed.day);
    }

    final vehicle = app['vehicle'];
    if (vehicle != null) {
      make.text = vehicle['make'];
      model.text = vehicle['model'];
      year.text = vehicle['year'].toString();
      plate.text = vehicle['plateNumber'];
      color.text = vehicle['color'];
      vehicleType = vehicle['type'];
      hasAC = vehicle['hasAC'];
      existingVehiclePhotoUrls = List<String>.from(vehicle['photoUrls']);
    }

    final docs = app['documents'];
    existingLicenseFront = docs['licenseFront'];
    existingLicenseBack = docs['licenseBack'];
    existingVehicleRegistration = docs['vehicleRegistration'];
    existingInsurance = docs['insurance'];
    existingDriverPhoto = docs['driverPhoto'];

    final bank = app['bank'];
    bankName.text = bank['bankName'] ?? '';
    accountNumber.text = bank['accountNumber'] ?? '';
    accountName.text = bank['accountName'] ?? '';
  }

  // Uploads a file straight to S3 using a short-lived link from our backend.
  // "kind" tells the backend where to store it, for example 'LICENSE_FRONT'.
  Future<String> uploadFile(File file, String kind) async {
    final contentType = contentTypeFor(file.path);
    developer.log("CONTENT TYPE $contentType");

    // 1. ask our backend for a signed upload link
    final res = await ref
        .read(apiClientProvider)
        .post(
          Endpoints.upload,
          data: {'kind': kind, 'contentType': contentType},
        );
    final uploadUrl = res.data['data']['uploadUrl'];
    final fileUrl = res.data['data']['fileUrl'];
    developer.log('FILE URL $fileUrl');

    try {
      // 2. Upload directly to S3
      final upload = await Dio().put(
        uploadUrl,
        data: file.openRead(), // Stream from disk
        options: Options(
          responseType: ResponseType
              .plain, // 👈 Fix 1: Stop Dio from parsing empty body as JSON
          headers: {
            'Content-Length': await file.length(),
            'Content-Type':
                contentType, // 👈 Fix 2: Match case exactly with NestJS signature
          },
        ),
      );

      developer.log("[S3 UPLOAD RESPONSE SUCCESS] ${upload.statusCode}");
      return fileUrl;
    } on DioException catch (e) {
      // If S3 still rejects it, this will print the exact reason (e.g. signature mismatch)
      developer.log("[S3 UPLOAD ERROR] Status: ${e.response?.statusCode}");
      developer.log("[S3 UPLOAD ERROR] AWS Message: ${e.response?.data}");
      rethrow;
    }
  }

  String contentTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<String?> urlFor(
    File? newFile,
    String? existingUrl,
    String kind,
  ) async {
    if (newFile != null) return await uploadFile(newFile, kind);
    return existingUrl;
  }

  // Runs an action with a loading state and shows any error as a toast
  Future<void> runWithLoading(Future<void> Function() action) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await action();
    } catch (e) {
      showError(errorMessage(e));
    }
    if (mounted) setState(() => saving = false);
  }

  String errorMessage(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final message = e.response!.data['message'];
      if (message is List) return message.join('\n');
      if (message != null) return message.toString();
    }
    return 'Something went wrong';
  }

  void showError(String message) {
    if (!mounted) return;
    AppToast.show(context, message);
  }

  Future<void> savePersonal() async {
    if (dob == null) {
      showError('Select your date of birth');
      return;
    }

    await runWithLoading(() async {
      final body = <String, dynamic>{'dateOfBirth': formatDate(dob!)};

      // only send a photo if a new one was picked
      String? newPhotoUrl;
      if (profilePhoto != null) {
        newPhotoUrl = await uploadFile(profilePhoto!, 'PROFILE_PHOTO');
        body['profilePhotoUrl'] = newPhotoUrl;
      }

      await ref
          .read(apiClientProvider)
          .patch(Endpoints.driverPersonalInfo, data: body);

      if (newPhotoUrl != null) {
        existingProfilePhotoUrl = newPhotoUrl;
        profilePhoto = null;
      }
      setState(() => step = 1);
    });
  }

  Future<void> saveVehicle() async {
    final yearNumber = int.tryParse(year.text.trim());
    final photoCount = existingVehiclePhotoUrls.length + vehiclePhotos.length;

    if (make.text.trim().isEmpty ||
        model.text.trim().isEmpty ||
        plate.text.trim().isEmpty ||
        color.text.trim().isEmpty) {
      showError('Fill in all vehicle details');
      return;
    }
    if (yearNumber == null ||
        yearNumber < 1900 ||
        yearNumber > DateTime.now().year + 1) {
      showError('Enter a valid year');
      return;
    }
    if (photoCount == 0) {
      showError('Add at least one car photo');
      return;
    }

    await runWithLoading(() async {
      // old photos that were kept + newly picked ones
      final photoUrls = <String>[...existingVehiclePhotoUrls];
      for (final photo in vehiclePhotos) {
        photoUrls.add(await uploadFile(photo, 'VEHICLE_PHOTO'));
      }

      await ref
          .read(apiClientProvider)
          .patch(
            Endpoints.driverVehicleInfo,
            data: {
              'make': make.text.trim(),
              'model': model.text.trim(),
              'year': yearNumber,
              'plateNumber': plate.text.trim(),
              'color': color.text.trim(),
              'type': vehicleType,
              'hasAC': hasAC,
              'photoUrls': photoUrls,
            },
          );

      // the new photos are saved now, so treat them as existing
      existingVehiclePhotoUrls = photoUrls;
      vehiclePhotos = [];
      setState(() => step = 2);
    });
  }

  Future<void> saveDocuments() async {
    final hasFront = licenseFront != null || existingLicenseFront != null;
    final hasBack = licenseBack != null || existingLicenseBack != null;
    final hasRegistration =
        vehicleRegistration != null || existingVehicleRegistration != null;

    if (!hasFront || !hasBack || !hasRegistration) {
      showError('Upload your licence (both sides) and vehicle registration');
      return;
    }

    await runWithLoading(() async {
      final front = await urlFor(
        licenseFront,
        existingLicenseFront,
        'LICENSE_FRONT',
      );
      final back = await urlFor(
        licenseBack,
        existingLicenseBack,
        'LICENSE_BACK',
      );
      final registration = await urlFor(
        vehicleRegistration,
        existingVehicleRegistration,
        'VEHICLE_REGISTRATION',
      );
      final insuranceUrl = await urlFor(
        insurance,
        existingInsurance,
        'INSURANCE',
      );
      final driverPhotoUrl = await urlFor(
        driverPhoto,
        existingDriverPhoto,
        'DRIVER_PHOTO',
      );

      final body = <String, dynamic>{
        'licenseFront': front,
        'licenseBack': back,
        'vehicleRegistration': registration,
      };
      if (insuranceUrl != null) body['insurance'] = insuranceUrl;
      if (driverPhotoUrl != null) body['driverPhoto'] = driverPhotoUrl;

      await ref
          .read(apiClientProvider)
          .patch(Endpoints.driverDocuments, data: body);

      // saved, so the uploaded files become the "existing" ones
      existingLicenseFront = front;
      existingLicenseBack = back;
      existingVehicleRegistration = registration;
      existingInsurance = insuranceUrl;
      existingDriverPhoto = driverPhotoUrl;
      licenseFront = null;
      licenseBack = null;
      vehicleRegistration = null;
      insurance = null;
      driverPhoto = null;

      setState(() => step = 3);
    });
  }

  Future<void> saveBankAndSubmit() async {
    final isTenDigits = RegExp(r'^\d{10}$').hasMatch(accountNumber.text.trim());

    if (bankName.text.trim().isEmpty || accountName.text.trim().isEmpty) {
      showError('Fill in all bank details');
      return;
    }
    if (!isTenDigits) {
      showError('Account number must be 10 digits');
      return;
    }

    await runWithLoading(() async {
      final api = ref.read(apiClientProvider);

      await api.patch(
        Endpoints.driverBankDetails,
        data: {
          'bankName': bankName.text.trim(),
          'accountNumber': accountNumber.text.trim(),
          'accountName': accountName.text.trim(),
        },
      );
      await api.post(Endpoints.driverSubmit);

      // reload so the screen shows the "under review" state
      await loadStatus();
    });
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------

  String formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }

  // ECONOMY -> Economy
  String prettyType(String type) {
    return type[0] + type.substring(1).toLowerCase();
  }

  Future<File?> pickImage({bool crop = false}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 70,
    );
    if (picked == null) return null;
    if (!crop) return File(picked.path);

    final colors = Theme.of(context).colorScheme;
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: colors.primary,
          toolbarWidgetColor: colors.onPrimary,
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }

  Future<void> pickDob() async {
    final now = DateTime.now();
    final colors = Theme.of(context).colorScheme;
    final mutedColor = colors.onSurface.withValues(alpha: 0.5);

    // drivers must be at least 18 years old
    final oldest = DateTime(now.year - 80, now.month, now.day);
    final youngest = DateTime(now.year - 18, now.month, now.day);

    // the picker crashes if the start date is outside the allowed range
    DateTime start = dob ?? DateTime(now.year - 25, now.month, now.day);
    if (start.isAfter(youngest)) start = youngest;
    if (start.isBefore(oldest)) start = oldest;

    DateTime tempPicked = start;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: colors.surface,
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
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: mutedColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(tempPicked),
                      child: Text(
                        'DONE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: colors.onSurface.withValues(alpha: 0.08),
              ),
              SizedBox(
                height: 220,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: start,
                  minimumDate: oldest,
                  maximumDate: youngest,
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
      // keep only the date part
      setState(() => dob = DateTime(picked.year, picked.month, picked.day));
    }
  }

  void goToStep(int target) {
    if (saving) return;
    // normal flow: only go back. While correcting: jump to any step.
    if (!isCorrecting && target >= step) return;
    setState(() => step = target);
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTitle(colors),
                    const SizedBox(height: 24),
                    if (verificationStatus != null)
                      buildStatusView(colors)
                    else ...[
                      if (isCorrecting) buildRejectionBanner(),
                      buildStepIndicator(colors),
                      const SizedBox(height: 32),
                      buildCurrentStep(colors),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildTitle(ColorScheme colors) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.syne(
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: 'Complete Your\n',
            style: TextStyle(color: colors.onSurface),
          ),
          TextSpan(
            text: 'Driver Profile',
            style: TextStyle(color: colors.primary),
          ),
        ],
      ),
    );
  }

  Widget buildRejectionBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your application was rejected: '
              '${rejectionReason ?? 'please review your details.'}',
              style: TextStyle(color: Colors.red.shade900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentStep(ColorScheme colors) {
    if (step == 0) return buildPersonalStep(colors);
    if (step == 1) return buildVehicleStep(colors);
    if (step == 2) return buildDocumentsStep(colors);
    return buildBankStep(colors);
  }

  // ------------------------------------------------------------
  // Step indicator
  // ------------------------------------------------------------

  Widget buildStepIndicator(ColorScheme colors) {
    final items = <Widget>[];

    for (int i = 0; i < stepTitles.length; i++) {
      items.add(buildStepCircle(i, colors));

      // a line between circles, but not after the last one
      if (i < stepTitles.length - 1) {
        items.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: step > i
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.1),
              ),
            ),
          ),
        );
      }
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }

  Widget buildStepCircle(int index, ColorScheme colors) {
    final isActive = step >= index;
    final isDone = step > index;

    return GestureDetector(
      onTap: () => goToStep(index),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? colors.primary : colors.surface,
              border: Border.all(
                color: isActive
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.15),
              ),
            ),
            child: Center(
              child: isDone
                  ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? colors.onPrimary
                            : colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stepTitles[index],
            style: TextStyle(
              fontSize: 11,
              fontWeight: step == index ? FontWeight.w700 : FontWeight.w500,
              color: step == index
                  ? colors.onSurface
                  : colors.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Steps
  // ------------------------------------------------------------

  Widget buildPersonalStep(ColorScheme colors) {
    final hasPhoto = profilePhoto != null || existingProfilePhotoUrl != null;

    ImageProvider? photoImage;
    if (profilePhoto != null) {
      photoImage = FileImage(profilePhoto!);
    } else if (existingProfilePhotoUrl != null) {
      photoImage = NetworkImage(existingProfilePhotoUrl!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStepHeader(
          'Personal details',
          'Add a photo and your date of birth',
          colors,
        ),
        Center(
          child: GestureDetector(
            onTap: () async {
              final file = await pickImage(crop: true);
              if (file != null) setState(() => profilePhoto = file);
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: colors.onSurface.withValues(alpha: 0.06),
                  backgroundImage: photoImage,
                  onBackgroundImageError: photoImage != null
                      ? (error, stack) {}
                      : null,
                  child: !hasPhoto
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 48,
                          color: colors.onSurface.withValues(alpha: 0.35),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: colors.primary,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('Profile photo (optional)', style: hintStyle(colors)),
        ),
        const SizedBox(height: 28),
        buildLabel('DATE OF BIRTH', colors),
        InkWell(
          onTap: pickDob,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: boxDecoration(colors),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dob == null ? 'Select date' : formatDate(dob!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: dob == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: dob == null
                          ? colors.onSurface.withValues(alpha: 0.35)
                          : colors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colors.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('You must be at least 18 years old', style: hintStyle(colors)),
        const SizedBox(height: 32),
        buildButton('Continue', savePersonal),
      ],
    );
  }

  Widget buildVehicleStep(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStepHeader(
          'Vehicle details',
          'Tell us about the car you will drive',
          colors,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildTextField(make, 'MAKE', hint: 'Toyota')),
            const SizedBox(width: 12),
            Expanded(child: buildTextField(model, 'MODEL', hint: 'Corolla')),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: buildTextField(
                year,
                'YEAR',
                hint: '2022',
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: buildTextField(color, 'COLOUR', hint: 'Black')),
          ],
        ),
        buildTextField(
          plate,
          'PLATE NUMBER',
          hint: 'KJA-123-AB',
          capitalization: TextCapitalization.characters,
        ),
        buildLabel('VEHICLE TYPE', colors),
        buildVehicleTypeChips(colors),
        const SizedBox(height: 20),
        Container(
          decoration: boxDecoration(colors),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.ac_unit_rounded, size: 20, color: colors.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Air conditioning',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Switch(
                value: hasAC,
                onChanged: (value) => setState(() => hasAC = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        buildLabel('CAR PHOTOS (1 TO 6)', colors),
        buildVehiclePhotos(colors),
        const SizedBox(height: 32),
        buildButton('Continue', saveVehicle),
        buildBackLink(),
      ],
    );
  }

  Widget buildVehicleTypeChips(ColorScheme colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: vehicleTypes.map((type) {
        final selected = vehicleType == type;

        return ChoiceChip(
          label: Text(prettyType(type)),
          selected: selected,
          showCheckmark: false,
          selectedColor: colors.primary,
          backgroundColor: colors.surface,
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? colors.onPrimary : colors.onSurface,
          ),
          side: BorderSide(
            color: selected
                ? colors.primary
                : colors.onSurface.withValues(alpha: 0.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          onSelected: (_) => setState(() => vehicleType = type),
        );
      }).toList(),
    );
  }

  Widget buildVehiclePhotos(ColorScheme colors) {
    final tiles = <Widget>[];

    // photos already saved on the server
    for (int i = 0; i < existingVehiclePhotoUrls.length; i++) {
      tiles.add(
        buildPhotoTile(
          buildNetworkImage(existingVehiclePhotoUrls[i], 100, colors),
          () => setState(() => existingVehiclePhotoUrls.removeAt(i)),
        ),
      );
    }

    // photos picked just now
    for (int i = 0; i < vehiclePhotos.length; i++) {
      tiles.add(
        buildPhotoTile(
          Image.file(
            vehiclePhotos[i],
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          () => setState(() => vehiclePhotos.removeAt(i)),
        ),
      );
    }

    final total = existingVehiclePhotoUrls.length + vehiclePhotos.length;
    if (total < 6) {
      tiles.add(
        GestureDetector(
          onTap: () async {
            final file = await pickImage();
            if (file != null) setState(() => vehiclePhotos.add(file));
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: colors.primary),
                const SizedBox(height: 6),
                Text(
                  'Add photo',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(spacing: 10, runSpacing: 10, children: tiles);
  }

  Widget buildPhotoTile(Widget image, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(14), child: image),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Network image that shows a placeholder instead of an error message
  Widget buildNetworkImage(String url, double size, ColorScheme colors) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return Container(
          width: size,
          height: size,
          color: colors.onSurface.withValues(alpha: 0.06),
          child: Icon(
            Icons.broken_image_outlined,
            color: colors.onSurface.withValues(alpha: 0.35),
          ),
        );
      },
    );
  }

  Widget buildDocumentsStep(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStepHeader(
          'Documents',
          'Upload clear photos of your documents',
          colors,
        ),
        buildDocTile(
          colors,
          label: "Driver's licence (front)",
          file: licenseFront,
          existingUrl: existingLicenseFront,
          onPicked: (file) => licenseFront = file,
        ),
        buildDocTile(
          colors,
          label: "Driver's licence (back)",
          file: licenseBack,
          existingUrl: existingLicenseBack,
          onPicked: (file) => licenseBack = file,
        ),
        buildDocTile(
          colors,
          label: 'Vehicle registration',
          file: vehicleRegistration,
          existingUrl: existingVehicleRegistration,
          onPicked: (file) => vehicleRegistration = file,
        ),
        buildDocTile(
          colors,
          label: 'Insurance',
          file: insurance,
          existingUrl: existingInsurance,
          onPicked: (file) => insurance = file,
          optional: true,
        ),
        buildDocTile(
          colors,
          label: 'Driver photo',
          file: driverPhoto,
          existingUrl: existingDriverPhoto,
          onPicked: (file) => driverPhoto = file,
          optional: true,
        ),
        const SizedBox(height: 20),
        buildButton('Continue', saveDocuments),
        buildBackLink(),
      ],
    );
  }

  Widget buildBankStep(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStepHeader(
          'Bank details',
          'Where we will send your earnings',
          colors,
        ),
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 22),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colors.onSurface),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Your earnings will be paid into this account.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        buildTextField(bankName, 'BANK NAME', hint: 'e.g. GTBank'),
        buildTextField(
          accountNumber,
          'ACCOUNT NUMBER',
          hint: '10 digits',
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        buildTextField(
          accountName,
          'ACCOUNT NAME',
          hint: 'Name on the account',
        ),
        const SizedBox(height: 14),
        buildButton('Submit for review', saveBankAndSubmit),
        buildBackLink(),
      ],
    );
  }

  // ------------------------------------------------------------
  // Review status (shown after the driver has submitted)
  // ------------------------------------------------------------

  Widget buildStatusView(ColorScheme colors) {
    IconData icon = Icons.hourglass_top_rounded;
    Color accent = Colors.amber.shade700;
    String title = 'Under review';
    String message =
        'We are reviewing your application. We will notify you once it is done.';

    if (verificationStatus == 'APPROVED') {
      icon = Icons.verified_outlined;
      accent = Colors.green.shade600;
      title = 'You are approved';
      message = 'You can now go online and start accepting rides.';
    } else if (verificationStatus == 'REJECTED') {
      icon = Icons.error_outline;
      accent = Colors.red.shade600;
      title = 'Application rejected';
      message = rejectionReason ?? 'Please review your details and resubmit.';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 56, color: accent),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.syne(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: hintStyle(colors).copyWith(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 32),
            if (verificationStatus == 'REJECTED')
              buildButton('Review and fix', () async {
                setState(() {
                  isCorrecting = true;
                  verificationStatus = null;
                  step = 0;
                });
              }),
            // pending and approved drivers can go back to the home screen
            if (verificationStatus != 'REJECTED')
              buildButton('Go to home', () async {
                context.go(RouteNames.driverhomescreen);
              }),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Small reusable widgets
  // ------------------------------------------------------------

  TextStyle hintStyle(ColorScheme colors) {
    return TextStyle(
      fontSize: 13,
      color: colors.onSurface.withValues(alpha: 0.6),
    );
  }

  // white rounded box with a soft shadow, used for fields and cards
  BoxDecoration boxDecoration(ColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget buildStepHeader(String title, String subtitle, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: hintStyle(colors)),
        ],
      ),
    );
  }

  Widget buildLabel(String text, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: colors.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    TextCapitalization capitalization = TextCapitalization.words,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(label, colors),
          Container(
            decoration: boxDecoration(colors),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              textCapitalization: capitalization,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: colors.onSurface.withValues(alpha: 0.3),
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String label, Future<void> Function() onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: saving ? null : onTap,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  // "Back" link under the main button (not shown on the first step)
  Widget buildBackLink() {
    if (step == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: TextButton(
          onPressed: saving ? null : () => goToStep(step - 1),
          child: const Text('Back'),
        ),
      ),
    );
  }

  Widget buildDocTile(
    ColorScheme colors, {
    required String label,
    required File? file,
    required String? existingUrl,
    required Function(File) onPicked,
    bool optional = false,
  }) {
    final hasDocument = file != null || existingUrl != null;

    String statusText = optional ? 'Optional' : 'Required';
    Color statusColor = colors.onSurface.withValues(alpha: 0.5);
    if (existingUrl != null) {
      statusText = 'Submitted. Tap to replace';
      statusColor = Colors.green.shade700;
    }
    if (file != null) {
      statusText = 'New file selected';
      statusColor = Colors.green.shade700;
    }

    // thumbnail: new file first, then the saved image, then a placeholder
    Widget thumbnail = Container(
      width: 56,
      height: 56,
      color: colors.primary.withValues(alpha: 0.1),
      child: Icon(Icons.upload_file_outlined, color: colors.primary),
    );
    if (file != null) {
      thumbnail = Image.file(file, width: 56, height: 56, fit: BoxFit.cover);
    } else if (existingUrl != null) {
      thumbnail = buildNetworkImage(existingUrl, 56, colors);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await pickImage();
          if (picked != null) setState(() => onPicked(picked));
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: boxDecoration(colors),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: thumbnail,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                  ],
                ),
              ),
              Icon(
                hasDocument ? Icons.check_circle : Icons.add_circle_outline,
                color: hasDocument
                    ? Colors.green.shade600
                    : colors.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
