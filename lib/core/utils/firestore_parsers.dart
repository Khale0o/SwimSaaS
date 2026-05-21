import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreParsers {
  const FirestoreParsers._();

  static String parseString(
    Object? value, {
    String defaultValue = '',
  }) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  static bool parseBool(
    Object? value, {
    bool defaultValue = false,
  }) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }
    return defaultValue;
  }

  static int parseInt(
    Object? value, {
    int defaultValue = 0,
  }) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? defaultValue;
    return defaultValue;
  }

  static double parseDouble(
    Object? value, {
    double defaultValue = 0,
  }) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? parseDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return DateTime.tryParse(trimmed);
    }
    return null;
  }

  static List<String> parseStringList(Object? value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList(growable: false);
    }
    if (value is String) {
      if (value.trim().isEmpty) return const [];
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  static Map<String, dynamic> parseMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    return const {};
  }
}
