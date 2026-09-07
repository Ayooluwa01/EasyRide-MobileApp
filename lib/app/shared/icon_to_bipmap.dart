import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> iconToBitmapDescriptor(
  IconData iconData, {
  double size = 100,
  Color color = Colors.blue,
}) async {
  // 1. Account for high-density phone screens (retina/4k) so icons stay sharp
  // If you aren't inside a widget context, you can safely remove the multiplier
  final double pixelRatio =
      ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  final double scaledSize = size * pixelRatio;

  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);

  final textPainter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: scaledSize, // Use scaled size here
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  // Centering math works beautifully here
  textPainter.paint(
    canvas,
    Offset(
      (scaledSize - textPainter.width) / 2,
      (scaledSize - textPainter.height) / 2,
    ),
  );

  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(scaledSize.toInt(), scaledSize.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  // 2. FIXED: Changed .bytes() to .fromBytes() for modern google_maps_flutter compatibility
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
