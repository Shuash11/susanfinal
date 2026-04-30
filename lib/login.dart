import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';
import 'user_repository.dart';
import 'singup.dart';
import 'forgotpass.dart';
import 'homescreen.dart';
import 'spash_screen.dart';
import 'chatmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accentColor = Color(0xFF00D4AA);
  final UserRepository _repository = UserRepository();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  // Sets up the fade + slide entrance animation played when screen opens
  void _setupAnimation() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _togglePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _repository.login(
        _usernameController.text,
        _passwordController.text,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        _showSuccessDialog();
      } else {
        _showError(result.errorMessage ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Connection failed: ${e.toString()}');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Success!', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Text(
          'Login successful! Taking you to home...',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pop();
        _goToHome();
      }
    });
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChangeNotifierProvider(
          create: (_) => ChatViewModel()..initialize(),
          child: const HomeScreen(),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const ScreenHeader(
                      icon: Icons.school_rounded,
                      title: 'Welcome Back!',
                      subtitle: 'Sign in to continue studying',
                    ),
                    const SizedBox(height: 48),
                    const FieldLabel(label: 'Username'),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller: _usernameController,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      validator: UserRepository.validateUsername,
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel(label: 'Password'),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: _PasswordToggle(
                        isObscured: _obscurePassword,
                        onToggle: _togglePassword,
                      ),
                      validator: UserRepository.validatePassword,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: _accentColor, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onTap: _handleLogin,
                    ),
                    const SizedBox(height: 24),
                    const OrDivider(),
                    const SizedBox(height: 24),
                    AuthFooterLink(
                      prefixText: "Don't have an account? ",
                      linkText: 'Sign Up',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onToggle;

  const _PasswordToggle({required this.isObscured, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}
