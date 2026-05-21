import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/features/attendance/domain/attendance_record.dart';
import 'package:swim/features/swimmers/domain/swimmer.dart';

class AttendanceRepository {
  AttendanceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _swimmers =>
      _firestore.collection(AppCollections.swimmers);

  AttendanceSnapshot readAttendance(Swimmer swimmer) {
    return swimmer.attendance;
  }

  Future<void> markAttendance({
    required String swimmerId,
    required String dateKey,
    required String time,
    required bool present,
  }) {
    return _swimmers.doc(swimmerId).update({
      '${AppFields.attendance}.$dateKey': {
        'time': time,
        'present': present,
      },
    });
  }
}
