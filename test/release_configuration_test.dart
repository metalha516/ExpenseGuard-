import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Release Configuration & Permissions Audit', () {
    test('Android manifest contains required camera and photo permissions', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue,
          reason: 'AndroidManifest.xml must exist');

      final content = manifestFile.readAsStringSync();

      // Permissions
      expect(content, contains('android.permission.CAMERA'),
          reason: 'Must declare CAMERA permission for receipt capture');
      expect(content, contains('android.permission.READ_EXTERNAL_STORAGE'),
          reason: 'Must declare READ_EXTERNAL_STORAGE for photo library access');
      expect(content, contains('android.permission.READ_MEDIA_IMAGES'),
          reason: 'Must declare READ_MEDIA_IMAGES for Android 13+ gallery access');

      // Hardware features
      expect(content, contains('android.hardware.camera'),
          reason: 'Must declare camera hardware feature');
      expect(content, contains('android:label="ExpenseGuard"'),
          reason: 'App label must be ExpenseGuard');
    });

    test('iOS Info.plist contains required usage descriptions', () {
      final plistFile = File('ios/Runner/Info.plist');
      expect(plistFile.existsSync(), isTrue,
          reason: 'Info.plist must exist');

      final content = plistFile.readAsStringSync();

      // Privacy usage descriptions
      expect(content, contains('NSCameraUsageDescription'),
          reason: 'iOS must define NSCameraUsageDescription');
      expect(content, contains('NSPhotoLibraryUsageDescription'),
          reason: 'iOS must define NSPhotoLibraryUsageDescription');
      expect(content, contains('NSMicrophoneUsageDescription'),
          reason: 'iOS must define NSMicrophoneUsageDescription');
      expect(content, contains('<string>ExpenseGuard</string>'),
          reason: 'CFBundleDisplayName must be ExpenseGuard');
    });

    test('pubspec.yaml defines ExpenseGuard project metadata correctly', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);

      final content = pubspecFile.readAsStringSync();
      expect(content, contains('name: expense_guard'));
      expect(content, contains('flutter_riverpod:'));
      expect(content, contains('go_router:'));
      expect(content, contains('camera:'));
      expect(content, contains('fl_chart:'));
      expect(content, contains('shimmer:'));
    });
  });
}
