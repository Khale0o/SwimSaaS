import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/core/utils/firestore_parsers.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.isApproved,
    required this.isAdmin,
    required this.needsApproval,
    required this.profileCompleted,
    this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.approvedBy,
  });

  final String id;
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final bool isApproved;
  final bool isAdmin;
  final bool needsApproval;
  final bool profileCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return UserProfile.fromMap(doc.data() ?? const {}, id: doc.id);
  }

  factory UserProfile.fromMap(
    Map<String, dynamic> map, {
    String id = '',
  }) {
    final uid =
        FirestoreParsers.parseString(map[AppFields.uid], defaultValue: id);

    return UserProfile(
      id: id,
      uid: uid,
      fullName: FirestoreParsers.parseString(map[AppFields.fullName]),
      email: FirestoreParsers.parseString(map[AppFields.email]),
      phone: FirestoreParsers.parseString(map[AppFields.phone]),
      role: FirestoreParsers.parseString(
        map[AppFields.role],
        defaultValue: AppRoles.parent,
      ),
      isActive: FirestoreParsers.parseBool(
        map[AppFields.isActive],
        defaultValue: true,
      ),
      isApproved: FirestoreParsers.parseBool(
        map[AppFields.isApproved],
        defaultValue: true,
      ),
      isAdmin: FirestoreParsers.parseBool(map[AppFields.isAdmin]),
      needsApproval: FirestoreParsers.parseBool(map[AppFields.needsApproval]),
      profileCompleted:
          FirestoreParsers.parseBool(map[AppFields.profileCompleted]),
      createdAt: FirestoreParsers.parseDateTime(map[AppFields.createdAt]),
      updatedAt: FirestoreParsers.parseDateTime(map[AppFields.updatedAt]),
      approvedAt: FirestoreParsers.parseDateTime(map[AppFields.approvedAt]),
      approvedBy: map[AppFields.approvedBy] == null
          ? null
          : FirestoreParsers.parseString(map[AppFields.approvedBy]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppFields.uid: uid,
      AppFields.fullName: fullName,
      AppFields.email: email,
      AppFields.phone: phone,
      AppFields.role: role,
      AppFields.isActive: isActive,
      AppFields.isApproved: isApproved,
      AppFields.isAdmin: isAdmin,
      AppFields.needsApproval: needsApproval,
      AppFields.profileCompleted: profileCompleted,
      AppFields.createdAt: createdAt,
      AppFields.updatedAt: updatedAt,
      AppFields.approvedAt: approvedAt,
      AppFields.approvedBy: approvedBy,
    };
  }

  UserProfile copyWith({
    String? id,
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    bool? isApproved,
    bool? isAdmin,
    bool? needsApproval,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return UserProfile(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      isAdmin: isAdmin ?? this.isAdmin,
      needsApproval: needsApproval ?? this.needsApproval,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}
