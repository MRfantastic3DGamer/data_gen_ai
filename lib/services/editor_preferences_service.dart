import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show EdgeInsets;
import 'package:shared_preferences/shared_preferences.dart';

/// Global editor layout preferences (field padding, spacing).
class EditorPreferencesService extends ChangeNotifier {
  EditorPreferencesService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const String _fieldPaddingKey = 'editor_field_padding';
  static const String _fieldGapKey = 'editor_field_gap';

  static const double defaultFieldPadding = 14;
  static const double defaultFieldGap = 12;
  static const double minFieldPadding = 8;
  static const double maxFieldPadding = 24;
  static const double minFieldGap = 4;
  static const double maxFieldGap = 24;

  double _fieldPadding = defaultFieldPadding;
  double _fieldGap = defaultFieldGap;

  double get fieldPadding => _fieldPadding;
  double get fieldGap => _fieldGap;

  EdgeInsets get fieldBoxPadding => EdgeInsets.symmetric(
    horizontal: _fieldPadding,
    vertical: _fieldPadding * 0.85,
  );

  EdgeInsets get formPadding => EdgeInsets.all(_fieldPadding);

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    _fieldPadding =
        _prefs!.getDouble(_fieldPaddingKey) ?? defaultFieldPadding;
    _fieldGap = _prefs!.getDouble(_fieldGapKey) ?? defaultFieldGap;
    notifyListeners();
  }

  Future<void> setFieldPadding(double value) async {
    _prefs ??= await SharedPreferences.getInstance();
    _fieldPadding = value.clamp(minFieldPadding, maxFieldPadding);
    await _prefs!.setDouble(_fieldPaddingKey, _fieldPadding);
    notifyListeners();
  }

  Future<void> setFieldGap(double value) async {
    _prefs ??= await SharedPreferences.getInstance();
    _fieldGap = value.clamp(minFieldGap, maxFieldGap);
    await _prefs!.setDouble(_fieldGapKey, _fieldGap);
    notifyListeners();
  }
}
