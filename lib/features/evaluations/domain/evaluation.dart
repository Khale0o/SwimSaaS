import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/core/utils/firestore_parsers.dart';

class Evaluation {
  const Evaluation({
    required this.id,
    required this.name,
    required this.level,
    required this.passed,
    required this.subscriptionStatus,
    required this.trainingDays,
    required this.score,
    required this.notes,
    this.date,
    this.evaluatedAt,
    this.rawDate,
    this.rawEvaluatedAt,
  });

  final String id;
  final String name;
  final String level;
  final String passed;
  final String subscriptionStatus;
  final String trainingDays;
  final int score;
  final String notes;
  final DateTime? date;
  final DateTime? evaluatedAt;
  final Object? rawDate;
  final Object? rawEvaluatedAt;

  bool get isPassed => passed == AppStatuses.yes;

  bool get isPending => passed == AppStatuses.no || passed.isEmpty;

  factory Evaluation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Evaluation.fromMap(doc.data() ?? const {}, id: doc.id);
  }

  factory Evaluation.fromMap(
    Map<String, dynamic> map, {
    String id = '',
  }) {
    final rawDate = map[AppFields.date];
    final rawEvaluatedAt = map[AppFields.evaluatedAt];

    return Evaluation(
      id: id,
      name: FirestoreParsers.parseString(map[AppFields.name]),
      level: FirestoreParsers.parseString(map[AppFields.level]),
      passed: FirestoreParsers.parseString(map[AppFields.passed]),
      subscriptionStatus:
          FirestoreParsers.parseString(map[AppFields.subscriptionStatus]),
      trainingDays: FirestoreParsers.parseString(map[AppFields.trainingDays]),
      score: FirestoreParsers.parseInt(map[AppFields.score]),
      notes: FirestoreParsers.parseString(map[AppFields.notes]),
      date: FirestoreParsers.parseDateTime(rawDate),
      evaluatedAt: FirestoreParsers.parseDateTime(rawEvaluatedAt),
      rawDate: rawDate,
      rawEvaluatedAt: rawEvaluatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppFields.name: name,
      AppFields.level: level,
      AppFields.passed: passed,
      AppFields.subscriptionStatus: subscriptionStatus,
      AppFields.trainingDays: trainingDays,
      AppFields.score: score,
      AppFields.notes: notes,
      AppFields.date: rawDate ?? date,
      AppFields.evaluatedAt: rawEvaluatedAt ?? evaluatedAt,
    };
  }

  Evaluation copyWith({
    String? id,
    String? name,
    String? level,
    String? passed,
    String? subscriptionStatus,
    String? trainingDays,
    int? score,
    String? notes,
    DateTime? date,
    DateTime? evaluatedAt,
    Object? rawDate,
    Object? rawEvaluatedAt,
  }) {
    return Evaluation(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      passed: passed ?? this.passed,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      trainingDays: trainingDays ?? this.trainingDays,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
      rawDate: rawDate ?? this.rawDate,
      rawEvaluatedAt: rawEvaluatedAt ?? this.rawEvaluatedAt,
    );
  }
}
