import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/features/evaluations/domain/evaluation.dart';

class EvaluationRepository {
  EvaluationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _evaluations =>
      _firestore.collection(AppCollections.evaluations);

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEvaluationSnapshots() {
    return _evaluations.snapshots();
  }

  Stream<List<Evaluation>> streamEvaluations() {
    return _evaluations
        .orderBy(AppFields.date, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Evaluation.fromFirestore(doc))
              .toList(),
        );
  }

  Future<DocumentReference<Map<String, dynamic>>> addEvaluation(
    Map<String, dynamic> data,
  ) {
    return _evaluations.add(data);
  }

  Future<void> updateEvaluation(String id, Map<String, dynamic> data) {
    return _evaluations.doc(id).update(data);
  }

  Future<void> deleteEvaluation(String id) {
    return _evaluations.doc(id).delete();
  }
}
