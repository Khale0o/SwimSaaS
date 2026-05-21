import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/features/swimmers/domain/swimmer.dart';

class SwimmerRepository {
  SwimmerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _swimmers =>
      _firestore.collection(AppCollections.swimmers);

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSwimmerSnapshots() {
    return _swimmers.snapshots();
  }

  Stream<List<Swimmer>> streamSwimmers() {
    return _swimmers.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Swimmer.fromFirestore(doc)).toList(),
        );
  }

  Future<Swimmer?> getSwimmerById(String id) async {
    final doc = await _swimmers.doc(id).get();
    if (!doc.exists) return null;
    return Swimmer.fromFirestore(doc);
  }

  Future<DocumentReference<Map<String, dynamic>>> addSwimmer(
    Map<String, dynamic> data,
  ) {
    return _swimmers.add(data);
  }

  Future<void> updateSwimmer(String id, Map<String, dynamic> data) {
    return _swimmers.doc(id).update(data);
  }

  Future<void> deleteSwimmer(String id) {
    return _swimmers.doc(id).delete();
  }
}
