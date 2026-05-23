import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/screens/login_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ModernSwimDashboardState();
}

class _ModernSwimDashboardState extends State<ParentDashboardScreen> {
  int _currentIndex = 0;
  bool _headerVisible = true;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    _ParentKeepAlivePage(
      key: PageStorageKey<String>('parent_attendance'),
      child: ModernAttendancePage(),
    ),
    _ParentKeepAlivePage(
      key: PageStorageKey<String>('parent_evaluations'),
      child: ModernEvaluationsPage(),
    ),
    _ParentKeepAlivePage(
      key: PageStorageKey<String>('parent_subscription'),
      child: ModernSubscriptionPage(),
    ),
    _ParentKeepAlivePage(
      key: PageStorageKey<String>('parent_profile'),
      child: ModernProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000428),
      body: Stack(
        children: [
          // Wave Background
          _buildWaveBackground(),

          // Main Content
          Column(
            children: [
              // Modern Header with Menu
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: _headerVisible
                    ? _buildModernHeader()
                    : const SizedBox.shrink(),
              ),

              // Page Content
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: PageView(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(), // لمنع الكراشات
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    children: _pages,
                  ),
                ),
              ),
            ],
          ),

          // Floating Navigation Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
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

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final shouldShowHeader = notification.metrics.pixels <= 8;
    if (_headerVisible != shouldShowHeader) {
      setState(() => _headerVisible = shouldShowHeader);
    }

    return false;
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Swim Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your swimming journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context);
                  } else if (value == 'change_password') {
                    _showChangePasswordDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'change_password',
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 20, color: Color(0xFF42A5F5)),
                        SizedBox(width: 8),
                        Text('Change Password'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? const Color(0xFF42A5F5)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.calendar_today, 'Attendance', 0),
          _buildNavItem(Icons.star, 'Evaluations', 1),
          _buildNavItem(Icons.credit_card, 'Subscription', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                    )
                  : null,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF42A5F5).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? const Color(0xFF42A5F5)
                  : Colors.white.withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E2A3A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          await _simpleLogout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _simpleLogout(BuildContext context) async {
    try {
      print('🔄 Starting logout...');

      // 1. Firebase logout
      await FirebaseAuth.instance.signOut();
      print('✅ Firebase signed out');

      // 2. أبسط طريقة - أعمل create لشاشة اللوجين مباشرة
      _goToLoginScreen(context);
    } catch (e) {
      print('❌ Logout error: $e');
      // حتى لو في error روح للوجين
      _goToLoginScreen(context);
    }
  }

  void _goToLoginScreen(BuildContext context) {
    // إعمل import لشاشة اللوجين بتاعتك هنا
    // import 'login_screen.dart';

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              const LoginScreen()), // غير LoginScreen لاسم شاشة اللوجين بتاعتك
      (route) => false,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E2A3A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 50, color: Color(0xFF42A5F5)),
                const SizedBox(height: 16),
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _changePassword(
                            context,
                            currentController.text,
                            newController.text,
                            confirmController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Change'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 6 characters'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Password change failed';
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password change failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _ParentKeepAlivePage extends StatefulWidget {
  const _ParentKeepAlivePage({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<_ParentKeepAlivePage> createState() => _ParentKeepAlivePageState();
}

class _ParentKeepAlivePageState extends State<_ParentKeepAlivePage>
    with AutomaticKeepAliveClientMixin<_ParentKeepAlivePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// صفحة الحضور
class ModernAttendancePage extends StatefulWidget {
  const ModernAttendancePage({super.key});

  @override
  State<ModernAttendancePage> createState() => _ModernAttendancePageState();
}

class _ModernAttendancePageState extends State<ModernAttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _swimmerData;
  Map<String, dynamic> _attendanceData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final swimmerQuery = await _firestore
            .collection(AppCollections.swimmers)
            .where(AppFields.email, isEqualTo: user.email)
            .limit(1)
            .get();

        if (swimmerQuery.docs.isNotEmpty) {
          final swimmerDoc = swimmerQuery.docs.first;
          _swimmerData = swimmerDoc.data();
          _attendanceData = _swimmerData!['attendance'] ?? {};
        }
      }
    } catch (e) {
      print('Error fetching attendance: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getAttendanceRecords() {
    List<Map<String, dynamic>> records = [];
    _attendanceData.forEach((date, data) {
      if (data is Map<String, dynamic>) {
        records.add({
          'date': date,
          'present': data['present'] ?? false,
          'time': data['time'] ?? 'Not set',
        });
      }
    });
    records.sort((a, b) => b['date'].compareTo(a['date']));
    return records;
  }

  @override
  Widget build(BuildContext context) {
    final attendanceRecords = _getAttendanceRecords();

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Overview
                _buildStatsOverview(attendanceRecords),
                const SizedBox(height: 20),

                // Recent Sessions
                Expanded(
                  child: _buildAttendanceList(attendanceRecords),
                ),
              ],
            ),
          );
  }

  Widget _buildStatsOverview(List<Map<String, dynamic>> records) {
    final presentCount = records.where((r) => r['present']).length;
    final totalCount = records.length;
    final attendanceRate =
        totalCount > 0 ? (presentCount / totalCount * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              '${records.length}', 'Total Sessions', Icons.calendar_today),
          _buildStatItem('$presentCount', 'Present', Icons.check_circle),
          _buildStatItem('${attendanceRate.toStringAsFixed(0)}%', 'Rate',
              Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF42A5F5), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceList(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today,
                size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No attendance records',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildAttendanceCard(record);
      },
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final isPresent = record['present'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPresent
                  ? const Color(0xFF4CAF50).withOpacity(0.2)
                  : const Color(0xFFF44336).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPresent ? Icons.check : Icons.close,
              color:
                  isPresent ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record['date']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time: ${record['time']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPresent
                  ? const Color(0xFF4CAF50).withOpacity(0.2)
                  : const Color(0xFFF44336).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPresent
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
              ),
            ),
            child: Text(
              isPresent ? 'PRESENT' : 'ABSENT',
              style: TextStyle(
                color: isPresent
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('EEE, MMM d').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}

// صفحة التقييمات
class ModernEvaluationsPage extends StatefulWidget {
  const ModernEvaluationsPage({super.key});

  @override
  State<ModernEvaluationsPage> createState() => _ModernEvaluationsPageState();
}

class _ModernEvaluationsPageState extends State<ModernEvaluationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _evaluations = [];
  Map<String, dynamic>? _swimmerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvaluationData();
  }

  Future<void> _fetchEvaluationData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final swimmerQuery = await _firestore
            .collection(AppCollections.swimmers)
            .where(AppFields.email, isEqualTo: user.email)
            .limit(1)
            .get();

        if (swimmerQuery.docs.isNotEmpty) {
          _swimmerData = swimmerQuery.docs.first.data();
          final swimmerName = _swimmerData!['name'];

          final querySnapshot = await _firestore
              .collection(AppCollections.evaluations)
              .where(AppFields.name, isEqualTo: swimmerName)
              .orderBy('date', descending: true)
              .get();

          List<Map<String, dynamic>> evaluations = [];
          for (var doc in querySnapshot.docs) {
            evaluations.add(doc.data());
          }

          if (mounted) {
            setState(() {
              _evaluations = evaluations;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      print('Error fetching evaluations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return const Color(0xFF4CAF50);
    if (score >= 5) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Performance Overview
                _buildPerformanceOverview(),
                const SizedBox(height: 20),

                // Evaluations List
                Expanded(
                  child: _buildEvaluationsList(),
                ),
              ],
            ),
          );
  }

  Widget _buildPerformanceOverview() {
    final averageScore = _evaluations.isNotEmpty
        ? _evaluations
                .map((e) => (e['score'] as int? ?? 0))
                .reduce((a, b) => a + b) /
            _evaluations.length
        : 0;
    final passedCount = _evaluations.where((e) => e['passed'] == 'Yes').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPerformanceItem(
              '${_evaluations.length}', 'Total Tests', Icons.assessment),
          _buildPerformanceItem(
              averageScore.toStringAsFixed(1), 'Avg Score', Icons.star),
          _buildPerformanceItem('$passedCount', 'Passed', Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF42A5F5), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationsList() {
    if (_evaluations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment,
                size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No evaluations yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _evaluations.length,
      itemBuilder: (context, index) {
        final evaluation = _evaluations[index];
        return _buildEvaluationCard(evaluation);
      },
    );
  }

  Widget _buildEvaluationCard(Map<String, dynamic> evaluation) {
    final score = evaluation['score'] as int? ?? 0;
    final passed = evaluation['passed'] == 'Yes';
    final level = evaluation['level'] ?? 'Beginner';
    final date = evaluation['date'] is Timestamp
        ? (evaluation['date'] as Timestamp).toDate()
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                      : const Color(0xFFF44336).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: passed
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                  ),
                ),
                child: Text(
                  passed ? 'PASSED' : 'FAILED',
                  style: TextStyle(
                    color: passed
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Score Circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getScoreColor(score),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _getScoreColor(score),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evaluation['notes'] ?? 'No notes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// صفحة الاشتراكات
class ModernSubscriptionPage extends StatefulWidget {
  const ModernSubscriptionPage({super.key});

  @override
  State<ModernSubscriptionPage> createState() => _ModernSubscriptionPageState();
}

class _ModernSubscriptionPageState extends State<ModernSubscriptionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _swimmerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionData();
  }

  Future<void> _fetchSubscriptionData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection(AppCollections.swimmers)
            .where(AppFields.email, isEqualTo: user.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              _swimmerData = querySnapshot.docs.first.data();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    } catch (e) {
      print('Error fetching subscription: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getPlanType(int totalDays) {
    if (totalDays <= 30) return 'Monthly';
    if (totalDays <= 90) return 'Quarterly';
    if (totalDays <= 180) return 'Half Yearly';
    return 'Yearly';
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Subscription Card
                _buildSubscriptionCard(),
                const SizedBox(height: 20),

                // Progress Card
                _buildProgressCard(),
                const SizedBox(height: 20),

                // Training Info
                _buildTrainingInfoCard(),
                const SizedBox(height: 20),

                // Subscription Details
                _buildSubscriptionDetailsCard(),
              ],
            ),
          );
  }

  Widget _buildSubscriptionCard() {
    final status = _swimmerData![AppFields.subscriptionStatus] ?? 'Unknown';
    final totalDays = _calculateTotalDays();
    final planType = _getPlanType(totalDays);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42A5F5).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planType,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_calculateTotalDays()} days plan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _calculateProgress();
    final remainingDays = _calculateRemainingDays();
    final usedDays = _calculateUsedDays();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: MediaQuery.of(context).size.width * 0.7 * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% completed',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '$remainingDays days remaining',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$usedDays days used • ${_calculateTotalDays()} total days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Level', _swimmerData!['level'] ?? 'Not set'),
          _buildInfoRow(
              'Training Days', _swimmerData!['trainingDays'] ?? 'Not set'),
          _buildInfoRow(
              'Training Time', _swimmerData!['trainingTime'] ?? 'Not set'),
          _buildInfoRow('Join Date', _formatDate(_swimmerData!['joinDate'])),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Plan Type', _getPlanType(_calculateTotalDays())),
          _buildDetailRow(
              'Start Date', _formatDate(_swimmerData!['lastRenewalDate'])),
          _buildDetailRow(
              'Expiry Date', _formatDate(_swimmerData!['subscriptionExpiry'])),
          _buildDetailRow('Total Duration', '${_calculateTotalDays()} days'),
          _buildDetailRow('Days Used', '${_calculateUsedDays()} days'),
          _buildDetailRow(
              'Days Remaining', '${_calculateRemainingDays()} days'),
          _buildDetailRow('Status',
              _swimmerData![AppFields.subscriptionStatus] ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'expired':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  double _calculateProgress() {
    final start = _swimmerData!['lastRenewalDate'];
    final expiry = _swimmerData!['subscriptionExpiry'];

    if (start is Timestamp && expiry is Timestamp) {
      final totalDays = expiry.toDate().difference(start.toDate()).inDays;
      final passedDays = DateTime.now().difference(start.toDate()).inDays;
      if (totalDays > 0 && passedDays >= 0) {
        return passedDays / totalDays;
      }
    }
    return 0.0;
  }

  int _calculateTotalDays() {
    final start = _swimmerData!['lastRenewalDate'];
    final expiry = _swimmerData!['subscriptionExpiry'];

    if (start is Timestamp && expiry is Timestamp) {
      return expiry.toDate().difference(start.toDate()).inDays;
    }
    return 0;
  }

  int _calculateUsedDays() {
    final start = _swimmerData!['lastRenewalDate'];
    if (start is Timestamp) {
      final passedDays = DateTime.now().difference(start.toDate()).inDays;
      return passedDays > 0 ? passedDays : 0;
    }
    return 0;
  }

  int _calculateRemainingDays() {
    final expiry = _swimmerData!['subscriptionExpiry'];
    if (expiry is Timestamp) {
      final remaining = expiry.toDate().difference(DateTime.now()).inDays;
      return remaining > 0 ? remaining : 0;
    }
    return 0;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not set';
    if (date is Timestamp) {
      return DateFormat('MMM d, yyyy').format(date.toDate());
    }
    return date.toString();
  }
}

// صفحة البروفايل
class ModernProfilePage extends StatefulWidget {
  const ModernProfilePage({super.key});

  @override
  State<ModernProfilePage> createState() => _ModernProfilePageState();
}

class _ModernProfilePageState extends State<ModernProfilePage> {
  late final Future<QuerySnapshot> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = FirebaseFirestore.instance
        .collection(AppCollections.swimmers)
        .where(
          AppFields.email,
          isEqualTo: FirebaseAuth.instance.currentUser?.email,
        )
        .limit(1)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No swimmer data found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          );
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Profile Header
              _buildProfileHeader(data),
              const SizedBox(height: 20),

              // Personal Information
              _buildInfoCard('Personal Information', [
                _buildInfoItem(
                    Icons.email, 'Email', data['email'] ?? 'Not set'),
                _buildInfoItem(
                    Icons.phone, 'Phone', data['phone'] ?? 'Not set'),
                _buildInfoItem(Icons.calendar_today, 'Join Date',
                    _formatDate(data['joinDate'])),
              ]),
              const SizedBox(height: 16),

              // Swimming Details
              _buildInfoCard('Swimming Details', [
                _buildInfoItem(Icons.pool, 'Level', data['level'] ?? 'Not set'),
                _buildInfoItem(Icons.schedule, 'Training Days',
                    data['trainingDays'] ?? 'Not set'),
                _buildInfoItem(Icons.access_time, 'Training Time',
                    data['trainingTime'] ?? 'Not set'),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF42A5F5).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Swimmer Name',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['email'] ?? 'Email not set',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF42A5F5)),
                  ),
                  child: Text(
                    data['level'] ?? 'Beginner',
                    style: const TextStyle(
                      color: Color(0xFF42A5F5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF42A5F5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not set';
    if (date is Timestamp) {
      return DateFormat('MMM d, yyyy').format(date.toDate());
    }
    return date.toString();
  }
}
