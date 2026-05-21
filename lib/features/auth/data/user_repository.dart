import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/features/auth/domain/user_profile.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppCollections.users);

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Future<UserProfile?> getUserProfileWithTimeout(
    String uid, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final doc = await _users.doc(uid).get().timeout(timeout);
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  Stream<UserProfile?> streamUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  Future<void> createUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return _users.doc(uid).set(data);
  }

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return _users.doc(uid).update(data);
  }

  Future<void> approveCoach({
    required String coachId,
    required String? approvedBy,
  }) {
    return _users.doc(coachId).update({
      AppFields.isApproved: true,
      AppFields.isActive: true,
      AppFields.needsApproval: false,
      AppFields.approvedAt: Timestamp.now(),
      AppFields.approvedBy: approvedBy,
    });
  }

  Future<void> rejectCoach(String coachId) {
    return _users.doc(coachId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPendingCoaches() {
    return _users
        .where(AppFields.role, isEqualTo: AppRoles.coach)
        .where(AppFields.isApproved, isEqualTo: false)
        .snapshots();
  }
}
