/// Helpers for Unity YAML → JSON exports where unset strings appear as `{}`.
abstract final class UnityJsonFields {
  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is Map) return fallback;
    if (value is num || value is bool) return value.toString();
    return fallback;
  }

  static String asBytesField(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) return '';
    return '';
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }
}
