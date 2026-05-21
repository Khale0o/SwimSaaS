import 'package:swim/core/utils/firestore_parsers.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.dateKey,
    required this.present,
    required this.time,
    required this.rawData,
  });

  final String dateKey;
  final bool present;
  final String time;
  final Map<String, dynamic> rawData;

  factory AttendanceRecord.fromMap(
    Map<String, dynamic> map, {
    String dateKey = '',
  }) {
    return AttendanceRecord(
      dateKey: dateKey,
      present: FirestoreParsers.parseBool(map['present']),
      time: FirestoreParsers.parseString(
        map['time'],
        defaultValue: 'Not set',
      ),
      rawData: Map<String, dynamic>.from(map),
    );
  }

  static Map<String, AttendanceRecord> recordsFromAttendanceMap(
    Object? attendance,
  ) {
    final attendanceMap = FirestoreParsers.parseMap(attendance);
    return attendanceMap.map((dateKey, value) {
      return MapEntry(
        dateKey,
        AttendanceRecord.fromMap(
          FirestoreParsers.parseMap(value),
          dateKey: dateKey,
        ),
      );
    });
  }

  Map<String, dynamic> toMap() {
    return {
      ...rawData,
      'present': present,
      'time': time,
    };
  }

  AttendanceRecord copyWith({
    String? dateKey,
    bool? present,
    String? time,
    Map<String, dynamic>? rawData,
  }) {
    return AttendanceRecord(
      dateKey: dateKey ?? this.dateKey,
      present: present ?? this.present,
      time: time ?? this.time,
      rawData: rawData ?? this.rawData,
    );
  }
}

class AttendanceSnapshot {
  const AttendanceSnapshot({
    required this.rawAttendance,
    required this.records,
  });

  final Map<String, dynamic> rawAttendance;
  final Map<String, AttendanceRecord> records;

  factory AttendanceSnapshot.fromMap(Object? attendance) {
    return AttendanceSnapshot(
      rawAttendance: FirestoreParsers.parseMap(attendance),
      records: AttendanceRecord.recordsFromAttendanceMap(attendance),
    );
  }

  Map<String, dynamic> toMap() {
    return rawAttendance.map((key, value) {
      final record = records[key];
      return MapEntry(key, record?.toMap() ?? value);
    });
  }

  int get presentCount =>
      records.values.where((record) => record.present).length;

  bool isPresentOn(String dateKey) => records[dateKey]?.present ?? false;
}
