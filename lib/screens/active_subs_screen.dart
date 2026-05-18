import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveSubsScreen extends StatefulWidget {
  const ActiveSubsScreen({super.key});

  @override
  State<ActiveSubsScreen> createState() => _ActiveSubsScreenState();
}

class _ActiveSubsScreenState extends State<ActiveSubsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // نفس Wave Background
          _buildWaveBackground(),
          
          // المحتوى الرئيسي
          Column(
            children: [
              // App Bar مع زر الرجوع
              _buildAppBar(),
              
              // Header Section
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
                      hintText: 'Search active swimmers...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
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
              
              // Active Swimmers List
              Expanded(
                child: _buildActiveSwimmersList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // App Bar مع زر الرجوع
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          // زر الرجوع
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Active Subscriptions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF Pro',
              ),
            ),
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
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
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
                      'Active Subscriptions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Swimmers with active subscriptions',
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
                  Icons.check_circle_rounded,
                  color: Colors.green.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_searchQuery.isEmpty ? 'All' : 'Filtered'} active swimmers',
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

  Widget _buildActiveSwimmersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swimmers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
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

        // نفلتر البيانات يدوياً
        final allSwimmers = snapshot.data!.docs;
        final activeSwimmers = allSwimmers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          final isActive = data['subscriptionStatus'] == 'Active';
          return isActive && name.contains(_searchQuery);
        }).toList();

        // نرتبهم حسب الاسم
        activeSwimmers.sort((a, b) {
          final aName = (a.data() as Map<String, dynamic>)['name'] ?? '';
          final bName = (b.data() as Map<String, dynamic>)['name'] ?? '';
          return aName.compareTo(bName);
        });

        if (activeSwimmers.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? 'No Active Subscriptions' : 'No Results Found',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty 
                        ? 'All subscriptions are expired or pending'
                        : 'Try a different search term',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeSwimmers.length,
          itemBuilder: (context, index) {
            final swimmer = activeSwimmers[index];
            final data = swimmer.data() as Map<String, dynamic>;
            
            return _buildWaterSwimmerCard(
              context,
              swimmerId: swimmer.id,
              name: data['name'] ?? 'No Name',
              level: data['level'] ?? 'Not Set',
              phone: data['phone'] ?? 'No Phone',
              email: data['email'] ?? 'No Email',
              joinDate: data['joinDate'] ?? 'Unknown',
              trainingDays: data['trainingDays'] ?? 'Not Set',
              trainingTime: data['trainingTime'] ?? 'Not Scheduled',
              emergencyContact: data['emergencyContact'] ?? 'Not Provided',
            );
          },
        );
      },
    );
  }

  Widget _buildWaterSwimmerCard(
    BuildContext context, {
    required String swimmerId,
    required String name,
    required String level,
    required String phone,
    required String email,
    required String joinDate,
    required String trainingDays,
    required String trainingTime,
    required String emergencyContact,
  }) {
    Color groupColor = _getGroupColor(trainingTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                    groupColor.withOpacity(0.1),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: groupColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: groupColor),
                          ),
                          child: Text(
                            _getGroupShortName(trainingTime),
                            style: TextStyle(
                              color: groupColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Info Rows
                _buildWaterInfoRow(Icons.pool_rounded, 'Level: $level'),
                _buildWaterInfoRow(Icons.phone_rounded, 'Phone: $phone'),
                _buildWaterInfoRow(Icons.email_rounded, 'Email: $email'),
                _buildWaterInfoRow(Icons.calendar_today_rounded, 'Joined: $joinDate'),
                _buildWaterInfoRow(Icons.schedule_rounded, 'Days: $trainingDays'),
                _buildWaterInfoRow(Icons.access_time_rounded, 'Time: $trainingTime'),
                _buildWaterInfoRow(Icons.contact_emergency_rounded, 'Emergency: $emergencyContact'),
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

  Color _getGroupColor(String trainingTime) {
    if (trainingTime.contains('Group 1')) return const Color(0xFF42A5F5);
    if (trainingTime.contains('Group 2')) return const Color(0xFF4CAF50);
    if (trainingTime.contains('Group 3')) return const Color(0xFFFF9800);
    if (trainingTime.contains('Group 4')) return const Color(0xFF9C27B0);
    if (trainingTime.contains('Group 5')) return const Color(0xFFF44336);
    return Colors.grey;
  }

  String _getGroupShortName(String trainingTime) {
    if (trainingTime.contains('Group 1')) return 'G1';
    if (trainingTime.contains('Group 2')) return 'G2';
    if (trainingTime.contains('Group 3')) return 'G3';
    if (trainingTime.contains('Group 4')) return 'G4';
    if (trainingTime.contains('Group 5')) return 'G5';
    return 'NS';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}