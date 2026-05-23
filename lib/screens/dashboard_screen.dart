import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/core/responsive/responsive_layout.dart';
import 'swimmers_list_screen.dart';
import 'active_subs_screen.dart';
import 'expired_subs_screen.dart';
import 'pending_evals_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final Stream<QuerySnapshot> _swimmersStream;
  late final Stream<QuerySnapshot> _evaluationsStream;

  @override
  void initState() {
    super.initState();
    _swimmersStream =
        _firestore.collection(AppCollections.swimmers).snapshots();
    _evaluationsStream =
        _firestore.collection(AppCollections.evaluations).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: _swimmersStream,
        builder: (context, swimmersSnapshot) {
          if (!swimmersSnapshot.hasData) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                ),
              ),
            );
          }

          final swimmers = swimmersSnapshot.data!.docs;
          final counts = _getSubscriptionCounts(swimmers);
          final totalSwimmers = counts.total;
          final activeSubs = counts.active;
          final expiredSubs = counts.expired;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ResponsiveMaxWidth(
              maxWidth: ResponsiveMaxWidths.dashboard,
              desktopPadding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWaterWelcomeSection(),

                  const SizedBox(height: 24),

                  // Quick Stats Grid
                  _buildResponsiveStatsGrid(
                    context,
                    totalSwimmers: totalSwimmers,
                    activeSubs: activeSubs,
                    expiredSubs: expiredSubs,
                  ),

                  const SizedBox(height: 24),

                  // Today's Schedule Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Today's Schedule",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Today's Groups Schedule
                  _buildWaterTodaysGroupsSchedule(context, swimmers),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _SubscriptionCounts _getSubscriptionCounts(
      List<QueryDocumentSnapshot> swimmers) {
    var active = 0;
    var expired = 0;

    for (final doc in swimmers) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data[AppFields.subscriptionStatus];
      if (status == AppStatuses.active) {
        active++;
      } else if (status == AppStatuses.expired) {
        expired++;
      }
    }

    return _SubscriptionCounts(
      total: swimmers.length,
      active: active,
      expired: expired,
    );
  }

  int _getPendingEvaluationCount(List<QueryDocumentSnapshot> evaluations) {
    var pending = 0;

    for (final doc in evaluations) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['passed'] == 'No' || data['passed'] == null) {
        pending++;
      }
    }

    return pending;
  }

  Widget _buildResponsiveStatsGrid(
    BuildContext context, {
    required int totalSwimmers,
    required int activeSubs,
    required int expiredSubs,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = context.isMobile
            ? 2
            : responsiveGridColumnCount(
                width,
                mobileColumns: 2,
                tabletColumns: 2,
                desktopColumns: 4,
                largeDesktopColumns: 4,
              );
        final childAspectRatio = context.isMobile
            ? 1.0
            : context.isTablet
                ? 1.35
                : 1.65;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildWaterStatCard(
              "Total Swimmers",
              totalSwimmers.toString(),
              Icons.pool_rounded,
              const [Color(0xFF42A5F5), Color(0xFF64B5F6)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SwimmersListScreen(),
                  ),
                );
              },
            ),
            _buildWaterStatCard(
              "Active Subs",
              activeSubs.toString(),
              Icons.credit_card_rounded,
              const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActiveSubsScreen(),
                  ),
                );
              },
            ),
            _buildWaterStatCard(
              "Expired Subs",
              expiredSubs.toString(),
              Icons.warning_amber_rounded,
              const [Color(0xFFFF9800), Color(0xFFFFB74D)],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpiredSubsScreen(),
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _evaluationsStream,
              builder: (context, evalSnapshot) {
                final pendingEvals = evalSnapshot.hasData
                    ? _getPendingEvaluationCount(evalSnapshot.data!.docs)
                    : 0;

                return _buildWaterStatCard(
                  "Pending Evals",
                  pendingEvals.toString(),
                  Icons.assignment_rounded,
                  const [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingEvalsScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWaterWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
                  Icons.waves_rounded,
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
                      'Welcome Coach! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
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
                  Icons.water_drop_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ready for today\'s sessions',
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

  Widget _buildWaterStatCard(
      String title, String value, IconData icon, List<Color> gradientColors,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
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
                      fontSize: 12,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTodaysGroupsSchedule(
      BuildContext context, List<QueryDocumentSnapshot> swimmers) {
    String today = _getToday();

    List<String> groups = [
      'Group 1: 4:00 PM - 5:30 PM',
      'Group 2: 5:30 PM - 7:00 PM',
      'Group 3: 7:00 PM - 8:30 PM',
      'Group 4: 8:30 PM - 10:00 PM',
      'Group 5: 10:00 AM - 11:30 AM'
    ];

    return Column(
      children: groups.map((group) {
        final groupSwimmers = swimmers.where((swimmer) {
          final data = swimmer.data() as Map<String, dynamic>;
          final trainingTime = data['trainingTime'] ?? '';
          final trainingDays =
              data['trainingDays']?.toString().toLowerCase() ?? '';

          return trainingTime.contains(group.split(':')[0]) &&
              trainingDays.contains(today.toLowerCase());
        }).toList();

        return _buildWaterGroupScheduleItem(
          context,
          group,
          groupSwimmers.length,
          groupSwimmers,
        );
      }).toList(),
    );
  }

  Widget _buildWaterGroupScheduleItem(BuildContext context, String group,
      int swimmerCount, List<QueryDocumentSnapshot> swimmers) {
    Color groupColor = _getGroupColor(group);
    String groupName = group.split(':')[0];
    String time = group.split(':')[1].trim();

    return GestureDetector(
      onTap: () {
        _showWaterGroupDetails(context, groupName, time, swimmers);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
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
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  groupColor.withOpacity(0.3),
                  groupColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: groupColor.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                groupName.replaceAll('Group ', 'G'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ),
          title: Text(
            groupName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'SF Pro',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'SF Pro',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$swimmerCount swimmers',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  groupColor.withOpacity(0.3),
                  groupColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: groupColor.withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showWaterGroupDetails(BuildContext context, String groupName,
      String time, List<QueryDocumentSnapshot> swimmers) {
    final firestore = FirebaseFirestore.instance;
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String currentTime = DateFormat('hh:mm a').format(DateTime.now());

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
                        Icons.group_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$groupName - $time',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Attendance Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: swimmers.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pool_rounded,
                              color: Colors.white.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No swimmers in this group today',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: swimmers.length,
                        itemBuilder: (context, index) {
                          final swimmer = swimmers[index];
                          final data = swimmer.data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'No Name';
                          final level = data['level'] ?? 'Not Set';

                          final attendanceMap = data['attendance'] ?? {};
                          const totalSessions = 8;
                          final attendedCount = attendanceMap.values
                              .where((v) => v['present'] == true)
                              .length;

                          final attendanceData = data['attendance']?[todayDate];
                          final bool isPresent =
                              attendanceData?['present'] == true;

                          return StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _getGroupColor('$groupName: $time')
                                            .withOpacity(0.3),
                                    child: Text(
                                      name[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$level • $attendedCount/$totalSessions sessions',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.7),
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () async {
                                      try {
                                        await firestore
                                            .collection(AppCollections.swimmers)
                                            .doc(swimmer.id)
                                            .update({
                                          'attendance.$todayDate': {
                                            'time': currentTime,
                                            'present': !isPresent,
                                          }
                                        });
                                        if (!context.mounted) return;
                                        setStateDialog(() {});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: !isPresent
                                                ? Colors.green
                                                : Colors.orange,
                                            content: Text(!isPresent
                                                ? '✅ $name marked present'
                                                : '❌ $name marked absent'),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text('Error: $e'),
                                          ),
                                        );
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isPresent
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isPresent
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                      child: Icon(
                                        isPresent
                                            ? Icons.check_rounded
                                            : Icons.close_rounded,
                                        color: isPresent
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
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
      ),
    );
  }

  // ✅ Added missing methods
  String _getToday() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  Color _getGroupColor(String group) {
    if (group.contains('Group 1')) return const Color(0xFF42A5F5);
    if (group.contains('Group 2')) return const Color(0xFF4CAF50);
    if (group.contains('Group 3')) return const Color(0xFFFF9800);
    if (group.contains('Group 4')) return const Color(0xFF9C27B0);
    if (group.contains('Group 5')) return const Color(0xFFF44336);
    return Colors.grey;
  }
}

class _SubscriptionCounts {
  const _SubscriptionCounts({
    required this.total,
    required this.active,
    required this.expired,
  });

  final int total;
  final int active;
  final int expired;
}
