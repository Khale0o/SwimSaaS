import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swim/core/constants/app_constants.dart';
import 'package:swim/features/auth/data/auth_repository.dart';
import 'package:swim/features/auth/data/parent_linking_service.dart';
import 'package:swim/features/auth/data/user_repository.dart';
import 'package:swim/features/auth/presentation/auth_route_resolver.dart';
import 'package:swim/screens/create_account_screen.dart';
import 'package:swim/screens/forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.checkExistingSession = true,
  });

  final bool checkExistingSession;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final ParentLinkingService _parentLinkingService = ParentLinkingService();
  final UserRepository _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _checkingAuth = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkExistingSession) {
      _checkAuthentication();
    } else {
      _checkingAuth = false;
    }
  }

  void _checkAuthentication() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _checkIfUserIsLoggedIn();
    });
  }

  Future<void> _checkIfUserIsLoggedIn() async {
    if (!mounted || _isNavigating) return;

    try {
      final user = _authRepository.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() {
            _checkingAuth = false;
          });
        }
        return;
      }

      final userProfile = await _userRepository.getUserProfileWithTimeout(
        user.uid,
        timeout: const Duration(seconds: 10),
      );

      if (!mounted || _isNavigating) return;

      if (userProfile != null) {
        final role = userProfile.role;
        final isApproved = userProfile.isApproved;
        final isActive = userProfile.isActive;

        if (role == AppRoles.coach && !isApproved) {
          _showPendingApprovalDialog();
          setState(() {
            _checkingAuth = false;
          });
          return;
        }

        if (!isActive) {
          _showInactiveAccountDialog();
          setState(() {
            _checkingAuth = false;
          });
          return;
        }

        await _linkParentSwimmersIfNeeded(role: role, user: user);
        _navigateToDashboard(role);
      } else {
        await _linkParentSwimmersIfNeeded(role: AppRoles.parent, user: user);
        _navigateToDashboard(AppRoles.parent);
      }
    } catch (e) {
      debugPrint('Error checking user: $e');
      if (mounted) {
        setState(() {
          _checkingAuth = false;
        });
      }
    }
  }

  void _navigateToDashboard(String role) {
    if (!mounted || _isNavigating) return;

    _isNavigating = true;

    final targetScreen = dashboardForRole(role);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      }
    });
  }

  Future<void> _linkParentSwimmersIfNeeded({
    required String role,
    required User user,
  }) async {
    if (role != AppRoles.parent) return;
    final email = user.email;
    if (email == null || email.trim().isEmpty) return;

    try {
      await _parentLinkingService.linkCurrentParentToSwimmers(
        parentUid: user.uid,
        parentEmail: email,
      );
    } catch (error) {
      debugPrint('Parent swimmer auto-link failed: $error');
    }
  }

  Future<void> _login() async {
    if (!mounted) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authRepository.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;

        final user = _authRepository.currentUser;
        if (user != null) {
          final userProfile = await _userRepository.getUserProfileWithTimeout(
            user.uid,
            timeout: const Duration(seconds: 10),
          );

          if (!mounted) return;

          if (userProfile != null) {
            final role = userProfile.role;
            final isApproved = userProfile.isApproved;
            final isActive = userProfile.isActive;

            if (role == AppRoles.coach && !isApproved) {
              setState(() {
                _isLoading = false;
              });
              _showPendingApprovalDialog();
              return;
            }

            if (!isActive) {
              setState(() {
                _isLoading = false;
              });
              _showInactiveAccountDialog();
              return;
            }

            await _linkParentSwimmersIfNeeded(role: role, user: user);
            _navigateToDashboard(role);
          } else {
            await _linkParentSwimmersIfNeeded(
              role: AppRoles.parent,
              user: user,
            );
            _navigateToDashboard(AppRoles.parent);
          }
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        String message = _getAuthErrorMessage(e);
        _showErrorSnackBar(message);
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        _showErrorSnackBar('An unexpected error occurred: $e');
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred during login.';
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPendingApprovalDialog() {
    if (!mounted) return;

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
              _signOut();
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
    if (!mounted) return;

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
              _signOut();
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

  Future<void> _signOut() async {
    try {
      await _authRepository.signOut();
      if (mounted) {
        setState(() {
          _checkingAuth = false;
          _isNavigating = false;
        });
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  void _handleBackButton() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit App',
          style: TextStyle(
            color: Color(0xFF42A5F5),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Color(0xFF42A5F5)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return _buildLoadingScreen();
    }

    return _buildLoginScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Stack(
        children: [
          // Wave Background Gradient
          Container(
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
          ),

          // Content
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

  Widget _buildLoginScreen() {
    return Scaffold(
      body: Stack(
        children: [
          // Wave Background Gradient
          Container(
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
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: _handleBackButton,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF42A5F5).withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.pool_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to your account',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildRememberMeAndForgotPassword(),
            const SizedBox(height: 10),
            _buildAutoLoginInfo(),
            const SizedBox(height: 30),
            _buildLoginButton(),
            const SizedBox(height: 30),
            _buildDivider(),
            const SizedBox(height: 30),
            _buildSocialLoginButtons(),
            const SizedBox(height: 40),
            _buildSignUpLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon:
            Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon:
            Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white.withOpacity(0.7),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Theme(
              data: ThemeData(
                unselectedWidgetColor: Colors.white.withOpacity(0.7),
              ),
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value!;
                  });
                },
                activeColor: Colors.white,
                checkColor: const Color(0xFF42A5F5),
              ),
            ),
            Text(
              'Keep me logged in',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgetPasswordScreen(),
              ),
            );
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoLoginInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You will stay logged in until you manually logout',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF42A5F5),
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            // TODO: Implement Google login
          },
          icon: Image.asset(
            'assets/google.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.account_circle,
                  color: Colors.white.withOpacity(0.7));
            },
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            // TODO: Implement Apple login
          },
          icon: Image.asset(
            'assets/apple.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.apple, color: Colors.white.withOpacity(0.7));
            },
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateAccountScreen(),
              ),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
