import 'package:flutter/material.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/features/auth/data/auth_repository.dart';
import 'package:swim/features/auth/data/parent_linking_service.dart';
import 'package:swim/features/auth/data/user_repository.dart';
import 'package:swim/features/auth/presentation/auth_route_resolver.dart';
import 'package:swim/screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    AuthRepository? authRepository,
    UserRepository? userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  final AuthRepository? _authRepository;
  final UserRepository? _userRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  final ParentLinkingService _parentLinkingService = ParentLinkingService();
  late final UserRepository _userRepository =
      widget._userRepository ?? UserRepository();

  bool _isChecking = true;
  Widget? _targetScreen;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    _resolveStartupRoute();
  }

  Future<void> _resolveStartupRoute() async {
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        _finishWith(const LoginScreen(checkExistingSession: false));
        return;
      }

      final userProfile = await _userRepository.getUserProfileWithTimeout(
        user.uid,
        timeout: const Duration(seconds: 10),
      );

      if (!mounted) return;

      if (userProfile == null) {
        await _linkParentSwimmersIfNeeded(
          role: AppRoles.parent,
          parentUid: user.uid,
          parentEmail: user.email,
        );
        _finishWith(dashboardForRole(AppRoles.parent));
        return;
      }

      if (userProfile.role == AppRoles.coach && !userProfile.isApproved) {
        _finishWith(
          const LoginScreen(checkExistingSession: false),
          afterBuild: _showPendingApprovalDialog,
        );
        return;
      }

      if (!userProfile.isActive) {
        _finishWith(
          const LoginScreen(checkExistingSession: false),
          afterBuild: _showInactiveAccountDialog,
        );
        return;
      }

      await _linkParentSwimmersIfNeeded(
        role: userProfile.role,
        parentUid: user.uid,
        parentEmail: user.email,
      );
      _finishWith(dashboardForRole(userProfile.role));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _startupError = error.toString();
        _targetScreen = const LoginScreen(checkExistingSession: false);
        _isChecking = false;
      });
    }
  }

  void _finishWith(Widget screen, {VoidCallback? afterBuild}) {
    if (!mounted) return;
    setState(() {
      _targetScreen = screen;
      _isChecking = false;
    });

    if (afterBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) afterBuild();
      });
    }
  }

  Future<void> _linkParentSwimmersIfNeeded({
    required String role,
    required String parentUid,
    required String? parentEmail,
  }) async {
    if (role != AppRoles.parent) return;
    if (parentEmail == null || parentEmail.trim().isEmpty) return;

    try {
      await _parentLinkingService.linkCurrentParentToSwimmers(
        parentUid: parentUid,
        parentEmail: parentEmail,
      );
    } catch (error) {
      debugPrint('Parent swimmer auto-link failed: $error');
    }
  }

  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Pending Approval',
          style: TextStyle(
            color: Color(0xFF42A5F5),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Your coach account is pending admin approval.\n\n'
          'You will be able to access the system once your account is approved.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOutToLogin();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF42A5F5)),
            ),
          ),
        ],
      ),
    );
  }

  void _showInactiveAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Account Inactive',
          style: TextStyle(
            color: Color(0xFF42A5F5),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Your account has been deactivated. Please contact support.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOutToLogin();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF42A5F5)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOutToLogin() async {
    try {
      await _authRepository.signOut();
    } finally {
      if (mounted) {
        setState(() {
          _targetScreen = const LoginScreen(checkExistingSession: false);
          _startupError = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const _AuthGateLoadingScreen();
    }

    final screen =
        _targetScreen ?? const LoginScreen(checkExistingSession: false);
    if (_startupError == null) return screen;

    return Stack(
      children: [
        screen,
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Startup check failed. Please try signing in again.\n$_startupError',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthGateLoadingScreen extends StatelessWidget {
  const _AuthGateLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF004E92), Color(0xFF000428)],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.pool_rounded,
                    size: 40,
                    color: Color(0xFF42A5F5),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'EasySwim',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Checking authentication...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
