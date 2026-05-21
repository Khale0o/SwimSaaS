import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/core/utils/firestore_parsers.dart';
import 'package:swim/features/attendance/domain/attendance_record.dart';
import 'package:swim/features/subscriptions/domain/subscription_info.dart';

class Swimmer {
  const Swimmer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.emergencyContact,
    required this.medicalNotes,
    required this.level,
    required this.joinDateText,
    required this.trainingDays,
    required this.trainingTime,
    required this.subscription,
    required this.attendance,
    this.joinDate,
    this.createdAt,
    this.updatedAt,
    this.rawJoinDate,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String emergencyContact;
  final String medicalNotes;
  final String level;
  final String joinDateText;
  final String trainingDays;
  final String trainingTime;
  final SubscriptionInfo subscription;
  final AttendanceSnapshot attendance;
  final DateTime? joinDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Object? rawJoinDate;

  factory Swimmer.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Swimmer.fromMap(doc.data() ?? const {}, id: doc.id);
  }

  factory Swimmer.fromMap(
    Map<String, dynamic> map, {
    String id = '',
  }) {
    final rawJoinDate = map[AppFields.joinDate];

    return Swimmer(
      id: id,
      name: FirestoreParsers.parseString(map[AppFields.name]),
      email: FirestoreParsers.parseString(map[AppFields.email]),
      phone: FirestoreParsers.parseString(map[AppFields.phone]),
      emergencyContact:
          FirestoreParsers.parseString(map[AppFields.emergencyContact]),
      medicalNotes: FirestoreParsers.parseString(map[AppFields.medicalNotes]),
      level: FirestoreParsers.parseString(map[AppFields.level]),
      joinDateText: FirestoreParsers.parseString(rawJoinDate),
      trainingDays: FirestoreParsers.parseString(map[AppFields.trainingDays]),
      trainingTime: FirestoreParsers.parseString(map[AppFields.trainingTime]),
      subscription: SubscriptionInfo.fromMap(map),
      attendance: AttendanceSnapshot.fromMap(map[AppFields.attendance]),
      joinDate: FirestoreParsers.parseDateTime(rawJoinDate),
      createdAt: FirestoreParsers.parseDateTime(map[AppFields.createdAt]),
      updatedAt: FirestoreParsers.parseDateTime(map[AppFields.updatedAt]),
      rawJoinDate: rawJoinDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppFields.name: name,
      AppFields.email: email,
      AppFields.phone: phone,
      AppFields.emergencyContact: emergencyContact,
      AppFields.medicalNotes: medicalNotes,
      AppFields.level: level,
      AppFields.joinDate: rawJoinDate ?? joinDateText,
      AppFields.trainingDays: trainingDays,
      AppFields.trainingTime: trainingTime,
      ...subscription.toMap(),
      AppFields.attendance: attendance.toMap(),
      AppFields.createdAt: createdAt,
      AppFields.updatedAt: updatedAt,
    };
  }

  Swimmer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? emergencyContact,
    String? medicalNotes,
    String? level,
    String? joinDateText,
    String? trainingDays,
    String? trainingTime,
    SubscriptionInfo? subscription,
    AttendanceSnapshot? attendance,
    DateTime? joinDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? rawJoinDate,
  }) {
    return Swimmer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      level: level ?? this.level,
      joinDateText: joinDateText ?? this.joinDateText,
      trainingDays: trainingDays ?? this.trainingDays,
      trainingTime: trainingTime ?? this.trainingTime,
      subscription: subscription ?? this.subscription,
      attendance: attendance ?? this.attendance,
      joinDate: joinDate ?? this.joinDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawJoinDate: rawJoinDate ?? this.rawJoinDate,
    );
  }
}
