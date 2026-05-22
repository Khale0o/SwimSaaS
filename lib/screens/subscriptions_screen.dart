import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:swim/core/constants/app_constants.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  late final Stream<QuerySnapshot> _swimmersStream;
  String _searchQuery = '';
  int _currentTabIndex = 0; // 0: All, 1: Active, 2: Expiring Soon, 3: Expired

  @override
  void initState() {
    super.initState();
    _swimmersStream =
        _firestore.collection(AppCollections.swimmers).snapshots();
  }

  // Function to get subscription status from data
  String _getSubscriptionStatus(Map<String, dynamic> data) {
    final subscriptionStatus =
        data[AppFields.subscriptionStatus]?.toString().toLowerCase();
    final expiry = data['subscriptionExpiry'];

    // Priority for subscriptionStatus field
    if (subscriptionStatus != null) {
      if (subscriptionStatus == AppStatuses.active.toLowerCase()) {
        return AppStatuses.active;
      } else if (subscriptionStatus == AppStatuses.expired.toLowerCase()) {
        return AppStatuses.expired;
      }
    }

    // If no status, use expiry date
    if (expiry != null) {
      final expiryDate = (expiry as Timestamp).toDate();
      final now = DateTime.now();

      if (expiryDate.isBefore(now)) {
        return "Expired";
      }

      final daysUntilExpiry = expiryDate.difference(now).inDays;
      if (daysUntilExpiry <= 7) {
        return "Expiring Soon";
      }

      return AppStatuses.active;
    }

    // If no status and no expiry, consider expired
    return "Expired";
  }

  // Function to get expiry date
  DateTime? _getExpiryDate(Map<String, dynamic> data) {
    final expiry = data['subscriptionExpiry'];
    if (expiry != null) {
      return (expiry as Timestamp).toDate();
    }
    return null;
  }

  // Function to filter swimmers based on current tab and search
  List<QueryDocumentSnapshot> _filterSwimmers(
      List<QueryDocumentSnapshot> allSwimmers) {
    // First filter by search query
    var filtered = allSwimmers.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();

    // Then filter by tab selection
    if (_currentTabIndex == 0) {
      return filtered; // All
    } else if (_currentTabIndex == 1) {
      return filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _getSubscriptionStatus(data) == AppStatuses.active;
      }).toList();
    } else if (_currentTabIndex == 2) {
      return filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _getSubscriptionStatus(data) == "Expiring Soon";
      }).toList();
    } else if (_currentTabIndex == 3) {
      return filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _getSubscriptionStatus(data) == AppStatuses.expired;
      }).toList();
    }

    return filtered;
  }

  // Function to get counts for each category
  Map<String, int> _getCategoryCounts(List<QueryDocumentSnapshot> allSwimmers) {
    int active = 0;
    int expiringSoon = 0;
    int expired = 0;

    for (final doc in allSwimmers) {
      final data = doc.data() as Map<String, dynamic>;
      final status = _getSubscriptionStatus(data);

      switch (status) {
        case AppStatuses.active:
          active++;
          break;
        case "Expiring Soon":
          expiringSoon++;
          break;
        case "Expired":
          expired++;
          break;
      }
    }

    return {
      'active': active,
      'expiringSoon': expiringSoon,
      'expired': expired,
      'total': allSwimmers.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // نفس Wave Background من الـ Dashboard
          _buildWaveBackground(),

          // SingleChildScrollView علشان الصفحة كلها تعمل سكرول
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 60), // مساحة للـ Safe Area

                // Header Section بنفس تصميم الـ Dashboard
                _buildWaterWelcomeSection(),

                const SizedBox(height: 24),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search swimmers by name...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.white.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.white.withOpacity(0.7)),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Shared swimmers listener for stats and list rendering.
                StreamBuilder<QuerySnapshot>(
                  stream: _swimmersStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildLoadingWidget(),
                          ),
                          const SizedBox(height: 24),
                          _buildTabsSection(),
                          const SizedBox(height: 16),
                          _buildLoadingWidget(),
                        ],
                      );
                    }

                    final allSwimmers = snapshot.data!.docs;
                    final counts = _getCategoryCounts(allSwimmers);
                    final filteredSwimmers = _filterSwimmers(allSwimmers);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildStatsGrid(
                            counts['active']!,
                            counts['expiringSoon']!,
                            counts['expired']!,
                            counts['total']!,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTabsSection(),
                        const SizedBox(height: 16),
                        if (filteredSwimmers.isEmpty)
                          _buildEmptyState()
                        else
                          Column(
                            children: [
                              ...filteredSwimmers.map((swimmer) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: _buildWaterSubscriptionCard(swimmer),
                                  )),
                              const SizedBox(height: 20),
                            ],
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 100), // مساحة للنافجيشن بار
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button for Bulk Renewal
      floatingActionButton: FloatingActionButton(
        onPressed: _showBulkRenewalDialog,
        backgroundColor: const Color(0xFF42A5F5),
        child: const Icon(Icons.autorenew, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildTab('All', 0, Icons.all_inclusive_rounded),
              _buildTab('Active', 1, Icons.check_circle_rounded),
              _buildTab('Expiring', 2, Icons.warning_rounded),
              _buildTab('Expired', 3, Icons.error_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index, IconData icon) {
    bool isSelected = _currentTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                size: 18,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF004E92), Color(0xFF000428)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF42A5F5).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF64B5F6).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF004E92), Color(0xFF000428)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004E92).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF42A5F5).withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscriptions Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage all swimmer subscriptions',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.autorenew_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Track subscription status',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int active, int expiring, int expired, int total) {
    return Row(
      children: [
        Expanded(
          child: _buildWaterStatCard(
              "Total",
              total.toString(),
              Icons.people_rounded,
              const [Color(0xFF42A5F5), Color(0xFF64B5F6)]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildWaterStatCard(
              "Active",
              active.toString(),
              Icons.check_circle_rounded,
              const [Colors.green, Color(0xFF66BB6A)]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildWaterStatCard("Expiring", expiring.toString(),
              Icons.warning_rounded, const [Colors.orange, Color(0xFFFFB74D)]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildWaterStatCard("Expired", expired.toString(),
              Icons.error_rounded, const [Colors.red, Color(0xFFEF5350)]),
        ),
      ],
    );
  }

  Widget _buildWaterStatCard(
      String title, String value, IconData icon, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    gradientColors[0].withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterSubscriptionCard(QueryDocumentSnapshot swimmerDoc) {
    final data = swimmerDoc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final phone = data['phone'] ?? 'No Phone';
    final level = data['level'] ?? 'Not Set';
    final trainingTime = data['trainingTime'] ?? 'Not Set';
    final expiryDate = _getExpiryDate(data);
    final status = _getSubscriptionStatus(data);

    Color statusColor;
    switch (status) {
      case AppStatuses.active:
        statusColor = const Color(0xFF4CAF50);
        break;
      case "Expiring Soon":
        statusColor = const Color(0xFFFF9800);
        break;
      case "Expired":
        statusColor = const Color(0xFFF44336);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    statusColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info Rows
                _buildWaterInfoRow(Icons.pool_rounded, 'Level: $level'),
                _buildWaterInfoRow(Icons.phone_rounded, 'Phone: $phone'),
                _buildWaterInfoRow(
                    Icons.schedule_rounded, 'Training: $trainingTime'),

                if (expiryDate != null)
                  _buildWaterInfoRow(Icons.calendar_today_rounded,
                      'Expires: ${DateFormat('dd MMM yyyy').format(expiryDate)}'),

                if (expiryDate != null && status != "Expired")
                  _buildWaterInfoRow(Icons.timer_rounded,
                      '${expiryDate.difference(DateTime.now()).inDays} days left'),

                const SizedBox(height: 12),

                // Renew Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF42A5F5).withOpacity(0.2),
                        const Color(0xFF64B5F6).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF42A5F5).withOpacity(0.3),
                    ),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      _showRenewDialog(swimmerDoc);
                    },
                    icon: const Icon(
                      Icons.autorenew_rounded,
                      color: Color(0xFF42A5F5),
                      size: 18,
                    ),
                    label: const Text(
                      'Renew Subscription',
                      style: TextStyle(
                        color: Color(0xFF42A5F5),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'SF Pro',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'SF Pro',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage = '';
    String emptySubMessage = '';

    switch (_currentTabIndex) {
      case 0: // All
        emptyMessage = _searchQuery.isEmpty
            ? 'No Subscriptions Found'
            : 'No Results Found';
        emptySubMessage = _searchQuery.isEmpty
            ? 'Add swimmers to see their subscriptions'
            : 'Try a different search term';
        break;
      case 1: // Active
        emptyMessage = 'No Active Subscriptions';
        emptySubMessage = 'All subscriptions are expired or expiring soon';
        break;
      case 2: // Expiring Soon
        emptyMessage = 'No Expiring Subscriptions';
        emptySubMessage = 'Great! No subscriptions are expiring soon';
        break;
      case 3: // Expired
        emptyMessage = 'No Expired Subscriptions';
        emptySubMessage = 'Excellent! All subscriptions are active';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.credit_card_off_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emptySubMessage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'SF Pro',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // باقي الدوال (Dialog functions) تبقى كما هي...
  void _showRenewDialog(QueryDocumentSnapshot swimmerDoc) {
    final data = swimmerDoc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';

    final List<String> plans = ["Monthly", "Quarterly", "Yearly"];
    String selectedPlan = "Monthly";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF004E92), Color(0xFF000428)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.autorenew_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Renew $name\'s Subscription',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPlan,
                            dropdownColor: const Color(0xFF004E92),
                            style: const TextStyle(color: Colors.white),
                            isExpanded: true,
                            items: plans
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(p),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedPlan = value!),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "New expiry date: ${_calculateNewExpiryDate(selectedPlan)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () {
                            _renewSubscription(swimmerDoc, selectedPlan);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Confirm Renewal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkRenewalDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF004E92), Color(0xFF000428)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.autorenew_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Bulk Renewal',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Renew subscriptions for multiple swimmers at once',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'SF Pro',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All expired and expiring soon subscriptions will be renewed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'SF Pro',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () {
                            _showBulkSelectionDialog();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Select Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBulkSelectionDialog() {
    String selectedPlan = "Monthly";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF004E92), Color(0xFF000428)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Bulk Renewal - Select Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Select subscription plan for all swimmers:',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: selectedPlan,
                            dropdownColor: const Color(0xFF004E92),
                            style: const TextStyle(color: Colors.white),
                            isExpanded: true,
                            items: ["Monthly", "Quarterly", "Yearly"]
                                .map((plan) => DropdownMenuItem(
                                      value: plan,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(plan),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedPlan = value!),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "New expiry date: ${_calculateNewExpiryDate(selectedPlan)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () {
                            _renewAllExpiringSubscriptions(selectedPlan);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Renew All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateNewExpiryDate(String plan) {
    final now = DateTime.now();
    DateTime newExpiry;

    switch (plan) {
      case "Monthly":
        newExpiry = now.add(const Duration(days: 30));
        break;
      case "Quarterly":
        newExpiry = now.add(const Duration(days: 90));
        break;
      case "Yearly":
        newExpiry = now.add(const Duration(days: 365));
        break;
      default:
        newExpiry = now.add(const Duration(days: 30));
    }

    return DateFormat('dd MMM yyyy').format(newExpiry);
  }

  Future<void> _renewSubscription(
      QueryDocumentSnapshot swimmerDoc, String plan) async {
    try {
      final newExpiry = _calculateNewExpiryDate(plan);
      final expiryDate = DateFormat('dd MMM yyyy').parse(newExpiry);

      await swimmerDoc.reference.update({
        AppFields.subscriptionStatus: AppStatuses.active,
        AppFields.subscriptionExpiry: Timestamp.fromDate(expiryDate),
        AppFields.lastRenewalDate: Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Subscription renewed successfully!"),
          backgroundColor: Colors.green[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error renewing subscription: $e"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _renewAllExpiringSubscriptions(String plan) async {
    try {
      final swimmers =
          await _firestore.collection(AppCollections.swimmers).get();
      final newExpiry = _calculateNewExpiryDate(plan);
      final expiryDate = DateFormat('dd MMM yyyy').parse(newExpiry);

      int renewedCount = 0;

      for (final swimmer in swimmers.docs) {
        final data = swimmer.data();
        final status = _getSubscriptionStatus(data);

        // Renew all expired or expiring soon subscriptions
        if (status == "Expired" || status == "Expiring Soon") {
          await swimmer.reference.update({
            AppFields.subscriptionStatus: AppStatuses.active,
            AppFields.subscriptionExpiry: Timestamp.fromDate(expiryDate),
            AppFields.lastRenewalDate: Timestamp.now(),
          });
          renewedCount++;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully renewed $renewedCount subscriptions!"),
          backgroundColor: Colors.green[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error in bulk renewal: $e"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
