import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:swim/core/constants/app_constants.dart';

class SwimmersListScreen extends StatefulWidget {
  const SwimmersListScreen({super.key});

  @override
  State<SwimmersListScreen> createState() => _SwimmersListScreenState();
}

class _SwimmersListScreenState extends State<SwimmersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // دالة لعرض dialog إضافة سباح جديد
  void _showAddSwimmerDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSwimmerDialog(
        onSwimmerAdded: () {
          setState(() {}); // نحدث الواجهة بعد الإضافة
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // مهم: شفاف علشان الجرادينت يظهر
      body: Stack(
        children: [
          // نفس Wave Background من الـ Dashboard
          _buildWaveBackground(),

          // المحتوى الرئيسي
          Column(
            children: [
              // App Bar مع زر الرجوع
              _buildAppBar(),

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
                      hintText: 'Search by name...',
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

              // Swimmers List
              Expanded(
                child: _buildSwimmersList(),
              ),
            ],
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSwimmerDialog,
        backgroundColor: const Color(0xFF42A5F5),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
              'Swimmers List',
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
                  Icons.pool_rounded,
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
                      'All Swimmers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your swimmers database',
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
                  Icons.group_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_searchQuery.isEmpty ? 'All' : 'Filtered'} swimmers list',
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

  Widget _buildSwimmersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppCollections.swimmers)
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

        final swimmers = snapshot.data!.docs;

        // نفلتر حسب البحث
        final filteredSwimmers = swimmers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery);
        }).toList();

        // نرتبهم حسب الاسم
        filteredSwimmers.sort((a, b) {
          final aName = (a.data() as Map<String, dynamic>)['name'] ?? '';
          final bName = (b.data() as Map<String, dynamic>)['name'] ?? '';
          return aName.compareTo(bName);
        });

        if (filteredSwimmers.isEmpty) {
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
                    Icons.pool_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No Swimmers Found'
                        : 'No Results Found',
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
                        ? 'Add your first swimmer to get started'
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
          itemCount: filteredSwimmers.length,
          itemBuilder: (context, index) {
            final swimmer = filteredSwimmers[index];
            final data = swimmer.data() as Map<String, dynamic>;

            return _buildWaterSwimmerCard(
              context,
              swimmerId: swimmer.id,
              name: data['name'] ?? 'No Name',
              level: data['level'] ?? 'Not Set',
              subscriptionStatus:
                  data[AppFields.subscriptionStatus] ?? 'Unknown',
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
    required String subscriptionStatus,
    required String phone,
    required String email,
    required String joinDate,
    required String trainingDays,
    required String trainingTime,
    required String emergencyContact,
  }) {
    Color statusColor = Colors.grey;

    if (subscriptionStatus == AppStatuses.active) {
      statusColor = Colors.green;
    } else if (subscriptionStatus == AppStatuses.expired) {
      statusColor = Colors.orange;
    } else if (subscriptionStatus == 'Pending') {
      statusColor = const Color(0xFF42A5F5);
    }

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            subscriptionStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
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
                _buildWaterInfoRow(
                    Icons.calendar_today_rounded, 'Joined: $joinDate'),
                _buildWaterInfoRow(
                    Icons.schedule_rounded, 'Days: $trainingDays'),
                _buildWaterInfoRow(
                    Icons.access_time_rounded, 'Time: $trainingTime'),
                _buildWaterInfoRow(Icons.contact_emergency_rounded,
                    'Emergency: $emergencyContact'),

                const SizedBox(height: 12),

                // Edit Button
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
                      _showWaterEditSwimmerDialog(
                        context,
                        swimmerId: swimmerId,
                        name: name,
                        level: level,
                        subscriptionStatus: subscriptionStatus,
                        phone: phone,
                        email: email,
                        joinDate: joinDate,
                        trainingDays: trainingDays,
                        trainingTime: trainingTime,
                        emergencyContact: emergencyContact,
                      );
                    },
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF42A5F5),
                      size: 18,
                    ),
                    label: const Text(
                      'Edit Details',
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

  void _showWaterEditSwimmerDialog(
    BuildContext context, {
    required String swimmerId,
    required String name,
    required String level,
    required String subscriptionStatus,
    required String phone,
    required String email,
    required String joinDate,
    required String trainingDays,
    required String trainingTime,
    required String emergencyContact,
  }) {
    final TextEditingController nameController =
        TextEditingController(text: name);
    final TextEditingController levelController =
        TextEditingController(text: level);
    final TextEditingController phoneController =
        TextEditingController(text: phone);
    final TextEditingController emailController =
        TextEditingController(text: email);
    final TextEditingController joinDateController =
        TextEditingController(text: joinDate);
    final TextEditingController trainingDaysController =
        TextEditingController(text: trainingDays);
    final TextEditingController emergencyController =
        TextEditingController(text: emergencyContact);

    String selectedStatus = subscriptionStatus;
    String selectedTrainingTime = trainingTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
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
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Edit Swimmer Details',
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

                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildWaterFormField(nameController, 'Name'),
                          const SizedBox(height: 12),
                          _buildWaterFormField(levelController, 'Level'),
                          const SizedBox(height: 12),
                          _buildWaterFormField(phoneController, 'Phone',
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 12),
                          _buildWaterFormField(emailController, 'Email',
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          _buildWaterFormField(joinDateController, 'Join Date'),
                          const SizedBox(height: 12),
                          _buildWaterFormField(
                              trainingDaysController, 'Training Days'),
                          const SizedBox(height: 12),
                          _buildWaterFormField(
                              emergencyController, 'Emergency Contact'),
                          const SizedBox(height: 16),

                          // Dropdowns
                          _buildWaterDropdown(
                            value: selectedStatus,
                            items: [
                              AppStatuses.active,
                              AppStatuses.expired,
                              AppStatuses.pending
                            ],
                            label: 'Subscription Status',
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildWaterDropdown(
                            value: selectedTrainingTime,
                            items: [
                              'Group 1: 4:00 PM - 5:30 PM',
                              'Group 2: 5:30 PM - 7:00 PM',
                              'Group 3: 7:00 PM - 8:30 PM',
                              'Group 4: 8:30 PM - 10:00 PM',
                              'Group 5: 10:00 AM - 11:30 AM',
                            ],
                            label: 'Training Time',
                            onChanged: (value) {
                              setState(() {
                                selectedTrainingTime = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
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
                                    colors: [
                                      Color(0xFF42A5F5),
                                      Color(0xFF64B5F6)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    await _updateSwimmerDetails(
                                      swimmerId,
                                      name: nameController.text,
                                      level: levelController.text,
                                      subscriptionStatus: selectedStatus,
                                      phone: phoneController.text,
                                      email: emailController.text,
                                      joinDate: joinDateController.text,
                                      trainingDays: trainingDaysController.text,
                                      trainingTime: selectedTrainingTime,
                                      emergencyContact:
                                          emergencyController.text,
                                    );
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text(
                                    'Save',
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
                        const SizedBox(height: 12),
                        // Delete Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.2),
                                Colors.red.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                  context, swimmerId, name);
                            },
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                            label: const Text(
                              'Delete Swimmer',
                              style: TextStyle(
                                color: Colors.red,
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
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String swimmerId, String swimmerName) {
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
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Delete Swimmer',
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
                  children: [
                    Icon(
                      Icons.person_remove_rounded,
                      color: Colors.red.withOpacity(0.7),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to delete $swimmerName?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'SF Pro',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
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
                            colors: [Colors.red, Color(0xFFFF5252)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            await _deleteSwimmer(swimmerId);
                            if (mounted) {
                              Navigator.pop(
                                  context); // Close confirmation dialog
                              Navigator.pop(context); // Close edit dialog
                            }
                          },
                          child: const Text(
                            'Delete',
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

  Future<void> _deleteSwimmer(String swimmerId) async {
    try {
      await FirebaseFirestore.instance
          .collection(AppCollections.swimmers)
          .doc(swimmerId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Swimmer deleted successfully!'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error deleting swimmer: $e'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildWaterFormField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildWaterDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF004E92),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
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

  Future<void> _updateSwimmerDetails(
    String swimmerId, {
    required String name,
    required String level,
    required String subscriptionStatus,
    required String phone,
    required String email,
    required String joinDate,
    required String trainingDays,
    required String trainingTime,
    required String emergencyContact,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(AppCollections.swimmers)
          .doc(swimmerId)
          .update({
        'name': name,
        'level': level,
        AppFields.subscriptionStatus: subscriptionStatus,
        'phone': phone,
        'email': email,
        'joinDate': joinDate,
        'trainingDays': trainingDays,
        'trainingTime': trainingTime,
        'emergencyContact': emergencyContact,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: const Text('Swimmer details updated successfully!'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error updating swimmer: $e'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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

// كلاس الـ Dialog لإضافة سباح جديد - بنفس التصميم
class AddSwimmerDialog extends StatefulWidget {
  final VoidCallback onSwimmerAdded;

  const AddSwimmerDialog({super.key, required this.onSwimmerAdded});

  @override
  State<AddSwimmerDialog> createState() => _AddSwimmerDialogState();
}

class _AddSwimmerDialogState extends State<AddSwimmerDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();
  final TextEditingController _joinDateController = TextEditingController();

  String _selectedLevel = 'Beginner';
  String _selectedStatus = AppStatuses.active;
  String _selectedTrainingTime = 'Group 1: 4:00 PM - 5:30 PM';
  bool _isSubmitting = false;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _joinDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _joinDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _addSwimmer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await _firestore.collection(AppCollections.swimmers).add({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'emergencyContact': _emergencyContactController.text,
          'level': _selectedLevel,
          'medicalNotes': _medicalNotesController.text,
          'joinDate': _joinDateController.text,
          AppFields.subscriptionStatus: _selectedStatus,
          'trainingTime': _selectedTrainingTime,
          'trainingDays': 'Not Set',
          'createdAt': FieldValue.serverTimestamp(),
        });

        widget.onSwimmerAdded();

        if (!mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swimmer added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error adding swimmer: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding swimmer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add New Swimmer',
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
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildWaterFormField(_nameController, 'Swimmer Name'),
                      const SizedBox(height: 12),
                      _buildWaterFormField(_emailController, 'Email',
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildWaterFormField(_phoneController, 'Phone Number',
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      _buildWaterFormField(
                          _emergencyContactController, 'Emergency Contact'),
                      const SizedBox(height: 12),
                      _buildWaterDropdown(
                        value: _selectedLevel,
                        items: _levels,
                        label: 'Level',
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildWaterDropdown(
                        value: _selectedStatus,
                        items: [
                          AppStatuses.active,
                          AppStatuses.expired,
                          AppStatuses.pending
                        ],
                        label: 'Subscription Status',
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildWaterDropdown(
                        value: _selectedTrainingTime,
                        items: [
                          'Group 1: 4:00 PM - 5:30 PM',
                          'Group 2: 5:30 PM - 7:00 PM',
                          'Group 3: 7:00 PM - 8:30 PM',
                          'Group 4: 8:30 PM - 10:00 PM',
                          'Group 5: 10:00 AM - 11:30 AM',
                        ],
                        label: 'Training Time',
                        onChanged: (value) {
                          setState(() {
                            _selectedTrainingTime = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: _buildWaterFormField(
                            _joinDateController, 'Join Date'),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _medicalNotesController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Medical Notes',
                            labelStyle:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
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
                        onPressed: _isSubmitting ? null : _addSwimmer,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Swimmer',
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
    );
  }

  Widget _buildWaterFormField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildWaterDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF004E92),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _medicalNotesController.dispose();
    _joinDateController.dispose();
    super.dispose();
  }
}
