import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/features/subscriptions/domain/subscription_info.dart';
import 'package:swim/features/swimmers/domain/swimmer.dart';

class SubscriptionRepository {
  SubscriptionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _swimmers =>
      _firestore.collection(AppCollections.swimmers);

  SubscriptionInfo readSubscriptionInfo(Swimmer swimmer) {
    return swimmer.subscription;
  }

  Future<void> renewSubscription({
    required String swimmerId,
    required DateTime expiryDate,
  }) {
    return _swimmers.doc(swimmerId).update({
      AppFields.subscriptionStatus: AppStatuses.active,
      AppFields.subscriptionExpiry: Timestamp.fromDate(expiryDate),
      AppFields.lastRenewalDate: Timestamp.now(),
    });
  }

  Future<int> bulkRenewSubscriptions({
    required DateTime expiryDate,
    required bool Function(Map<String, dynamic> swimmerData) shouldRenew,
  }) async {
    final swimmers = await _swimmers.get();
    var renewedCount = 0;

    for (final swimmer in swimmers.docs) {
      if (shouldRenew(swimmer.data())) {
        await swimmer.reference.update({
          AppFields.subscriptionStatus: AppStatuses.active,
          AppFields.subscriptionExpiry: Timestamp.fromDate(expiryDate),
          AppFields.lastRenewalDate: Timestamp.now(),
        });
        renewedCount++;
      }
    }

    return renewedCount;
  }
}
