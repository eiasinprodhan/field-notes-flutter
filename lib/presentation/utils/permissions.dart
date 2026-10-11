import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static final ImagePicker _picker = ImagePicker();

static Future<String?> getCurrentLocationString() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        var status = await Permission.location.status;
        if (!status.isGranted) {
          status = await Permission.location.request();
          if (!status.isGranted) return null;
        }
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (_) {
      return null;
    }
  }

static Future<File?> pickFromCamera() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return null;
      }
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (picked != null) {
        return File(picked.path);
      }
    } catch (_) {}
    return null;
  }

static Future<File?> pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        return File(picked.path);
      }
    } catch (_) {}
    return null;
  }
}
