import 'package:flutter/foundation.dart';

/// True on Android native builds (not Flutter web).
bool get isAndroidDevice =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Local RAW folder I/O via dart:io is only available on native platforms.
bool get supportsLocalRawFileIo => !kIsWeb;
