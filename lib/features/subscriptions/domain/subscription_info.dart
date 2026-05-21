import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/core/utils/firestore_parsers.dart';

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.status,
    this.expiry,
    this.lastRenewalDate,
    this.rawExpiry,
    this.rawLastRenewalDate,
  });

  final String status;
  final DateTime? expiry;
  final DateTime? lastRenewalDate;
  final Object? rawExpiry;
  final Object? rawLastRenewalDate;

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      status: FirestoreParsers.parseString(
        map[AppFields.subscriptionStatus],
        defaultValue: 'Unknown',
      ),
      expiry: FirestoreParsers.parseDateTime(map[AppFields.subscriptionExpiry]),
      lastRenewalDate:
          FirestoreParsers.parseDateTime(map[AppFields.lastRenewalDate]),
      rawExpiry: map[AppFields.subscriptionExpiry],
      rawLastRenewalDate: map[AppFields.lastRenewalDate],
    );
  }

  bool get isActive => status == AppStatuses.active;

  bool get isExpired {
    if (status == AppStatuses.expired) return true;
    if (expiry == null) return false;
    return expiry!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiry == null) return false;
    final daysLeft = expiry!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 7;
  }

  int? get remainingDays {
    if (expiry == null) return null;
    return expiry!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      AppFields.subscriptionStatus: status,
      AppFields.subscriptionExpiry: rawExpiry ?? expiry,
      AppFields.lastRenewalDate: rawLastRenewalDate ?? lastRenewalDate,
    };
  }

  SubscriptionInfo copyWith({
    String? status,
    DateTime? expiry,
    DateTime? lastRenewalDate,
    Object? rawExpiry,
    Object? rawLastRenewalDate,
  }) {
    return SubscriptionInfo(
      status: status ?? this.status,
      expiry: expiry ?? this.expiry,
      lastRenewalDate: lastRenewalDate ?? this.lastRenewalDate,
      rawExpiry: rawExpiry ?? this.rawExpiry,
      rawLastRenewalDate: rawLastRenewalDate ?? this.rawLastRenewalDate,
    );
  }
}
