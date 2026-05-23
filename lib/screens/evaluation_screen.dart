import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/core/responsive/responsive_layout.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationListPageState();
}

class _EvaluationListPageState extends State<EvaluationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  late final Stream<QuerySnapshot> _swimmersStream;
  late final Stream<QuerySnapshot> _evaluationsStream;
  String _searchQuery = '';
  bool _showEvaluatedSwimmers = false;

  @override
  void initState() {
    super.initState();
    _swimmersStream =
        _firestore.collection(AppCollections.swimmers).snapshots();
    _evaluationsStream = _firestore
        .collection(AppCollections.evaluations)
        .orderBy('date', descending: true)
        .snapshots();
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
            key: const PageStorageKey<String>('evaluation_scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            child: ResponsiveMaxWidth(
              maxWidth: ResponsiveMaxWidths.content,
              desktopPadding: EdgeInsets.zero,
              child: Column(
                children: [
                  const SizedBox(height: 60), // مساحة للـ Safe Area

                  // Header Section بنفس تصميم الـ Dashboard
                  _buildWaterWelcomeSection(),

                  const SizedBox(height: 24),

                  // Switch بين السباحين
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _showEvaluatedSwimmers
                                ? 'Evaluated Swimmers'
                                : 'Swimmers Without Evaluation',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Switch(
                                value: _showEvaluatedSwimmers,
                                onChanged: (value) {
                                  setState(() {
                                    _showEvaluatedSwimmers = value;
                                  });
                                },
                                activeColor: Colors.white,
                                activeTrackColor: const Color(0xFF4CAF50),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor:
                                    Colors.grey.withOpacity(0.5),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                          hintText: _showEvaluatedSwimmers
                              ? 'Search evaluated swimmers...'
                              : 'Search swimmers without evaluation...',
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

                  // Swimmers List - بدون ListView.builder علشان مايحصلش double scroll
                  _showEvaluatedSwimmers
                      ? _buildEvaluatedSwimmersList()
                      : _buildNonEvaluatedSwimmersList(),

                  SizedBox(height: floatingNavSafeBottomPadding(context)),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEvaluationDialog(context);
        },
        backgroundColor: const Color(0xFF42A5F5),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                  Icons.assignment_rounded,
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
                      'Swimmers Evaluation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage all swimmer evaluations',
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
                  Icons.track_changes_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Track swimmer progress',
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

  Widget _buildNonEvaluatedSwimmersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _evaluationsStream,
      builder: (context, evaluationsSnapshot) {
        if (evaluationsSnapshot.hasError) {
          return _buildErrorWidget('❌ Error loading data');
        }

        if (evaluationsSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _swimmersStream,
          builder: (context, swimmersSnapshot) {
            if (swimmersSnapshot.hasError) {
              return _buildErrorWidget('❌ Error loading data');
            }

            if (swimmersSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            }

            final swimmers = _getSwimmersWithoutEvaluation(
              swimmersSnapshot.data!.docs,
              evaluationsSnapshot.data!.docs,
            );

            final filteredSwimmers = _filterByName(swimmers);

            if (filteredSwimmers.isEmpty) {
              return _buildEmptyState(
                icon: Icons.people_outline,
                message: _searchQuery.isEmpty
                    ? 'All swimmers have evaluations!'
                    : 'No swimmers found for "$_searchQuery"',
              );
            }

            // استخدام Column بدل ListView.builder علشان مايحصلش double scroll
            return Column(
              children: [
                ...filteredSwimmers.map((swimmer) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: _buildWaterSwimmerCard(context, swimmer),
                    )),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEvaluatedSwimmersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _evaluationsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('❌ Error loading data');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        final filteredEvaluations = _filterByName(snapshot.data!.docs);

        if (filteredEvaluations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off,
            message: _searchQuery.isEmpty
                ? 'No evaluations found'
                : 'No results for "$_searchQuery"',
          );
        }

        // استخدام Column بدل ListView.builder علشان مايحصلش double scroll
        return Column(
          children: [
            ...filteredEvaluations.map((evaluation) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildWaterEvaluationCard(context, evaluation),
                )),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _getSwimmersWithoutEvaluation(
    List<QueryDocumentSnapshot> swimmers,
    List<QueryDocumentSnapshot> evaluations,
  ) {
    final evaluatedSwimmerNames = evaluations
        .map((doc) => doc['name']?.toString().toLowerCase() ?? '')
        .toSet();

    return swimmers.where((swimmer) {
      final swimmerName = swimmer['name']?.toString().toLowerCase() ?? '';
      return !evaluatedSwimmerNames.contains(swimmerName);
    }).toList();
  }

  List<QueryDocumentSnapshot> _filterByName(
      List<QueryDocumentSnapshot> documents) {
    return documents.where((doc) {
      final name = doc['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();
  }

  Widget _buildWaterSwimmerCard(
      BuildContext context, QueryDocumentSnapshot swimmer) {
    final name = swimmer['name'] ?? 'Unknown';
    final level = swimmer['level'] ?? 'N/A';
    final joinDate = swimmer['joinDate'] ?? '';
    final medicalNotes = swimmer['medicalNotes'] ?? '';

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
                    const Color(0xFFFF9800).withOpacity(0.1),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          _showAddEvaluationForSwimmer(context, swimmer);
                        },
                        tooltip: 'Add Evaluation',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info Rows
                _buildWaterInfoRow(Icons.pool_rounded, 'Level: $level'),
                _buildWaterInfoRow(Icons.calendar_today_rounded,
                    'Join Date: ${_formatDate(joinDate)}'),
                if (medicalNotes.isNotEmpty)
                  _buildWaterInfoRow(Icons.medical_services_rounded,
                      'Medical Notes: $medicalNotes'),

                const SizedBox(height: 12),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.white.withOpacity(0.9), size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'No evaluation yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildWaterEvaluationCard(
      BuildContext context, QueryDocumentSnapshot doc) {
    final name = doc['name'] ?? 'Unknown';
    final level = doc['level'] ?? 'N/A';
    final score = doc['score'] ?? 0;
    final notes = doc['notes'] ?? '';
    final date = doc['date'] ?? '';
    final trainingOptions = doc['trainingDays'] ?? 'Not specified';
    final subsStatus = doc[AppFields.subscriptionStatus] ?? 'Not specified';
    final passedStatus = doc['passed'] ?? 'Not specified';

    Color statusColor = _getStatusColor(passedStatus);

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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                            color: Colors.white.withOpacity(0.8)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(context, doc);
                          } else if (value == 'delete') {
                            _confirmDelete(context, doc.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue[300]),
                                const SizedBox(width: 8),
                                const Text('Edit',
                                    style: TextStyle(fontFamily: 'SF Pro')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red[300]),
                                const SizedBox(width: 8),
                                const Text('Delete',
                                    style: TextStyle(fontFamily: 'SF Pro')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info Rows
                _buildWaterInfoRow(Icons.pool_rounded, 'Level: $level'),
                _buildWaterInfoRow(
                    Icons.schedule_rounded, 'Training Days: $trainingOptions'),
                _buildWaterInfoRow(
                    Icons.credit_card_rounded, 'Subscription: $subsStatus'),
                _buildWaterInfoRow(Icons.flag_rounded, 'Status: $passedStatus'),
                _buildWaterInfoRow(Icons.score_rounded, 'Score: $score/10'),
                if (notes.isNotEmpty)
                  _buildWaterInfoRow(Icons.notes_rounded, 'Notes: $notes'),

                const SizedBox(height: 12),

                // Date Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Date: ${_formatDate(date)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                      fontFamily: 'SF Pro',
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

  Widget _buildErrorWidget(String message) {
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
          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'SF Pro',
            ),
            textAlign: TextAlign.center,
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

  Widget _buildEmptyState({required IconData icon, required String message}) {
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
            icon,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'SF Pro',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'yes':
      case 'active':
        return const Color(0xFF4CAF50);
      case 'no':
      case 'expired':
        return const Color(0xFFF44336);
      case 'pending':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(date.toDate());
    } else if (date is String) {
      return date.length >= 10 ? date.substring(0, 10) : date;
    }
    return 'Unknown date';
  }

  // ✏️ Edit Dialog
  void _showEditDialog(BuildContext context, QueryDocumentSnapshot doc) {
    String? passedValue = doc['passed']?.toString();
    String? subsValue = doc[AppFields.subscriptionStatus]?.toString();
    final trainingController =
        TextEditingController(text: doc['trainingDays']?.toString() ?? '');
    final scoreController =
        TextEditingController(text: doc['score']?.toString() ?? '0');
    final notesController =
        TextEditingController(text: doc['notes']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Evaluation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Passed Status Dropdown
              DropdownButtonFormField<String>(
                value: passedValue,
                decoration: const InputDecoration(
                  labelText: 'Passed Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                  DropdownMenuItem(value: 'No', child: Text('No')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  passedValue = value;
                },
              ),
              const SizedBox(height: 12),

              // Subscription Status Dropdown
              DropdownButtonFormField<String>(
                value: subsValue,
                decoration: const InputDecoration(
                  labelText: 'Subscription Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: AppStatuses.active, child: Text('Active')),
                  DropdownMenuItem(
                      value: AppStatuses.expired, child: Text('Expired')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  subsValue = value;
                },
              ),
              const SizedBox(height: 12),

              // Training Days TextField
              TextField(
                controller: trainingController,
                decoration: const InputDecoration(
                  labelText: 'Training Days',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: scoreController,
                decoration: const InputDecoration(
                  labelText: 'Score (0-10)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection(AppCollections.evaluations)
                    .doc(doc.id)
                    .update({
                  'passed': passedValue,
                  AppFields.subscriptionStatus: subsValue,
                  'trainingDays': trainingController.text,
                  'score': int.tryParse(scoreController.text) ?? 0,
                  'notes': notesController.text,
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Evaluation updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ➕ دالة علشان تضيف تقييم لسباح محدد
  void _showAddEvaluationForSwimmer(
      BuildContext context, QueryDocumentSnapshot swimmer) {
    final name = swimmer['name'] ?? '';
    final level = swimmer['level'] ?? '';

    String? passedValue;
    String? subsValue;
    final trainingController = TextEditingController();
    final scoreController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Evaluation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blueAccent),
                title: Text('Name: $name'),
                subtitle: Text('Level: $level'),
              ),
              const Divider(),

              // Passed Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Passed Status *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                  DropdownMenuItem(value: 'No', child: Text('No')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  passedValue = value;
                },
              ),
              const SizedBox(height: 12),

              // Subscription Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Subscription Status *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: AppStatuses.active, child: Text('Active')),
                  DropdownMenuItem(
                      value: AppStatuses.expired, child: Text('Expired')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  subsValue = value;
                },
              ),
              const SizedBox(height: 12),

              // Training Days TextField
              TextField(
                controller: trainingController,
                decoration: const InputDecoration(
                  labelText: 'Training Days *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: scoreController,
                decoration: const InputDecoration(
                  labelText: 'Score (0-10)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passedValue == null ||
                  subsValue == null ||
                  trainingController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection(AppCollections.evaluations)
                    .add({
                  'name': name,
                  'level': level,
                  'passed': passedValue,
                  AppFields.subscriptionStatus: subsValue,
                  'trainingDays': trainingController.text,
                  'score': int.tryParse(scoreController.text) ?? 0,
                  'notes': notesController.text,
                  'date': FieldValue.serverTimestamp(),
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Evaluation added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text(
              'Add Evaluation',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ➕ Add Evaluation Dialog الأصلية
  void _showAddEvaluationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final levelController = TextEditingController();
    String? passedValue;
    String? subsValue;
    final trainingController = TextEditingController();
    final scoreController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Evaluation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Swimmer Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: levelController,
                decoration: const InputDecoration(
                  labelText: 'Level *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Passed Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Passed Status *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                  DropdownMenuItem(value: 'No', child: Text('No')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  passedValue = value;
                },
              ),
              const SizedBox(height: 12),

              // Subscription Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Subscription Status *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: AppStatuses.active, child: Text('Active')),
                  DropdownMenuItem(
                      value: AppStatuses.expired, child: Text('Expired')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  subsValue = value;
                },
              ),
              const SizedBox(height: 12),

              // Training Days TextField
              TextField(
                controller: trainingController,
                decoration: const InputDecoration(
                  labelText: 'Training Days *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: scoreController,
                decoration: const InputDecoration(
                  labelText: 'Score (0-10)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  levelController.text.isEmpty ||
                  passedValue == null ||
                  subsValue == null ||
                  trainingController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection(AppCollections.evaluations)
                    .add({
                  'name': nameController.text,
                  'level': levelController.text,
                  'passed': passedValue,
                  AppFields.subscriptionStatus: subsValue,
                  'trainingDays': trainingController.text,
                  'score': int.tryParse(scoreController.text) ?? 0,
                  'notes': notesController.text,
                  'date': FieldValue.serverTimestamp(),
                });

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Evaluation added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text(
              'Add Evaluation',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🗑️ Confirm Delete
  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Evaluation'),
        content: const Text(
            'Are you sure you want to delete this evaluation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection(AppCollections.evaluations)
                    .doc(docId)
                    .delete();

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Evaluation deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
