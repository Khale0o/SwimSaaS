import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:swim/core/constants/app_constants.dart';

class ParentLinkingService {
  ParentLinkingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _parentEmailFields = [
    'parentEmail',
    'parent_email',
    'guardianEmail',
    'guardian_email',
    AppFields.email,
  ];

  Future<int> linkCurrentParentToSwimmers({
    required String parentUid,
    required String parentEmail,
  }) async {
    final normalizedEmail = normalizeParentEmail(parentEmail);
    if (parentUid.trim().isEmpty || normalizedEmail == null) return 0;
    final emailCandidates = {
      normalizedEmail,
      parentEmail.trim(),
    };

    final swimmersById =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (final field in _parentEmailFields) {
      for (final email in emailCandidates) {
        try {
          final query = await _firestore
              .collection(AppCollections.swimmers)
              .where(field, isEqualTo: email)
              .get();

          for (final doc in query.docs) {
            swimmersById[doc.id] = doc;
          }
        } catch (error) {
          debugPrint('Parent swimmer link query skipped for $field: $error');
        }
      }
    }

    var linkedCount = 0;
    for (final doc in swimmersById.values) {
      final data = doc.data();
      final existingParentUid = _readString(data[AppFields.parentUid]);

      if (existingParentUid == parentUid) continue;
      if (existingParentUid != null && existingParentUid.isNotEmpty) continue;

      await doc.reference.update({
        AppFields.parentUid: parentUid,
        AppFields.updatedAt: FieldValue.serverTimestamp(),
      });
      linkedCount++;
    }

    return linkedCount;
  }

  @visibleForTesting
  static String? normalizeParentEmail(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  static String? _readString(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}
