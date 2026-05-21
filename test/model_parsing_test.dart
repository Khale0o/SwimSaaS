import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/core/utils/firestore_parsers.dart';
import 'package:swim/features/attendance/domain/attendance_record.dart';
import 'package:swim/features/auth/domain/user_profile.dart';
import 'package:swim/features/evaluations/domain/evaluation.dart' as domain;
import 'package:swim/features/subscriptions/domain/subscription_info.dart';
import 'package:swim/features/swimmers/domain/swimmer.dart';

void main() {
  group('FirestoreParsers', () {
    test('parseDateTime supports Timestamp, DateTime, String, and null', () {
      final date = DateTime.utc(2026, 5, 21);

      expect(
        FirestoreParsers.parseDateTime(Timestamp.fromDate(date))?.toUtc(),
        date,
      );
      expect(FirestoreParsers.parseDateTime(date), date);
      expect(FirestoreParsers.parseDateTime('2026-05-21T00:00:00.000Z'), date);
      expect(FirestoreParsers.parseDateTime(null), isNull);
      expect(FirestoreParsers.parseDateTime('not a date'), isNull);
    });

    test('parse primitives are defensive', () {
      expect(FirestoreParsers.parseBool('yes'), isTrue);
      expect(FirestoreParsers.parseBool('0'), isFalse);
      expect(FirestoreParsers.parseInt('7'), 7);
      expect(FirestoreParsers.parseDouble('7.5'), 7.5);
      expect(FirestoreParsers.parseStringList('Sunday, Tuesday'), [
        'Sunday',
        'Tuesday',
      ]);
    });
  });

  group('UserProfile', () {
    test('fromMap handles missing fields with safe defaults', () {
      final profile = UserProfile.fromMap(const {}, id: 'user-1');

      expect(profile.id, 'user-1');
      expect(profile.uid, 'user-1');
      expect(profile.role, AppRoles.parent);
      expect(profile.isActive, isTrue);
      expect(profile.isApproved, isTrue);
      expect(profile.isAdmin, isFalse);
      expect(profile.fullName, isEmpty);
    });

    test('fromMap parses current user fields', () {
      final createdAt = Timestamp.fromDate(DateTime.utc(2026, 5, 21));
      final profile = UserProfile.fromMap({
        AppFields.uid: 'abc',
        AppFields.fullName: 'Coach One',
        AppFields.email: 'coach@example.com',
        AppFields.phone: '123',
        AppFields.role: AppRoles.coach,
        AppFields.isActive: 'true',
        AppFields.isApproved: false,
        AppFields.isAdmin: 1,
        AppFields.createdAt: createdAt,
      });

      expect(profile.uid, 'abc');
      expect(profile.role, AppRoles.coach);
      expect(profile.isActive, isTrue);
      expect(profile.isApproved, isFalse);
      expect(profile.isAdmin, isTrue);
      expect(profile.createdAt?.toUtc(), DateTime.utc(2026, 5, 21));
    });
  });

  group('Swimmer', () {
    test('fromMap handles missing and null fields', () {
      final swimmer = Swimmer.fromMap({
        AppFields.name: null,
        AppFields.attendance: null,
      });

      expect(swimmer.name, isEmpty);
      expect(swimmer.subscription.status, 'Unknown');
      expect(swimmer.attendance.records, isEmpty);
      expect(swimmer.joinDate, isNull);
    });

    test('fromMap parses embedded subscription and attendance maps', () {
      final expiry = Timestamp.fromDate(DateTime.utc(2026, 6, 1));
      final swimmer = Swimmer.fromMap({
        AppFields.name: 'Swimmer One',
        AppFields.email: 'parent@example.com',
        AppFields.subscriptionStatus: AppStatuses.active,
        AppFields.subscriptionExpiry: expiry,
        AppFields.attendance: {
          '2026-05-21': {
            'present': true,
            'time': '04:00 PM',
          },
        },
      });

      expect(swimmer.name, 'Swimmer One');
      expect(swimmer.subscription.status, AppStatuses.active);
      expect(swimmer.subscription.expiry?.toUtc(), DateTime.utc(2026, 6, 1));
      expect(swimmer.attendance.presentCount, 1);
      expect(swimmer.attendance.isPresentOn('2026-05-21'), isTrue);
    });
  });

  group('Evaluation', () {
    test('fromMap supports mixed date types and score strings', () {
      final evaluatedAt = Timestamp.fromDate(DateTime.utc(2026, 5, 22));
      final evaluation = domain.Evaluation.fromMap({
        AppFields.name: 'Swimmer One',
        AppFields.passed: AppStatuses.yes,
        AppFields.score: '8',
        AppFields.date: '2026-05-21T00:00:00.000Z',
        AppFields.evaluatedAt: evaluatedAt,
      });

      expect(evaluation.name, 'Swimmer One');
      expect(evaluation.score, 8);
      expect(evaluation.date, DateTime.utc(2026, 5, 21));
      expect(evaluation.evaluatedAt?.toUtc(), DateTime.utc(2026, 5, 22));
      expect(evaluation.isPassed, isTrue);
    });
  });

  group('Embedded helpers', () {
    test('SubscriptionInfo calculates status helpers from current fields', () {
      final subscription = SubscriptionInfo.fromMap({
        AppFields.subscriptionStatus: AppStatuses.expired,
      });

      expect(subscription.isExpired, isTrue);
      expect(subscription.toMap()[AppFields.subscriptionStatus],
          AppStatuses.expired);
    });

    test('AttendanceRecord keeps raw map compatibility', () {
      final record = AttendanceRecord.fromMap(
        {
          'present': 'true',
          'time': '05:00 PM',
          'coachNote': 'Late',
        },
        dateKey: '2026-05-21',
      );

      expect(record.present, isTrue);
      expect(record.time, '05:00 PM');
      expect(record.toMap()['coachNote'], 'Late');
    });
  });
}
