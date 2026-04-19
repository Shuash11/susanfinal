
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';
import 'user_repository.dart';
import 'homescreen.dart';
import 'spash_screen.dart';
import 'chatmodel.dart';

// ── SignupScreen ──────────────────────────────────────────────
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {

 
  final UserRepository _repository = UserRepository();

  
  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController  = TextEditingController();
  final GlobalKey<FormState>  _formKey            = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;


  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

 
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _repository.signUp(
        _nameController.text,
        _passwordController.text,
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        _showSuccessDialog();
      } else {
        _showError(result.errorMessage ?? 'Sign up failed. Please try again.');
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
            Text('Account Created!', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Text(
          'Welcome to StudyBuddy! Taking you to home...',
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
          child:  const HomeScreen(),
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
        content:         Text(message),
        backgroundColor: AppColors.error,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeader(
                      icon:     Icons.person_add_rounded,
                      title:    'Create Account',
                      subtitle: 'Join StudyBuddy and start learning',
                    ),

                    const SizedBox(height: 36),

                    const FieldLabel(label: 'Full Name'),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller: _nameController,
                      hint:       'Your full name',
                      icon:       Icons.person_outline_rounded,
                      validator:  UserRepository.validateUsername,
                    ),

                    const SizedBox(height: 18),

                    const FieldLabel(label: 'Password'),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller:  _passwordController,
                      hint:        '••••••••',
                      icon:        Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon:  _PasswordToggle(
                        isObscured: _obscurePassword,
                        onToggle:   () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: UserRepository.validatePassword,
                    ),

                    const SizedBox(height: 18),

                    const FieldLabel(label: 'Confirm Password'),
                    const SizedBox(height: 8),
                    AppInputField(
                      controller:  _confirmController,
                      hint:        '••••••••',
                      icon:        Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      suffixIcon:  _PasswordToggle(
                        isObscured: _obscureConfirm,
                        onToggle:   () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
   
                      validator: (val) => UserRepository.validateConfirmPassword(
                        val,
                        _passwordController.text,
                      ),
                    ),

                    const SizedBox(height: 32),

                    PrimaryButton(
                      label:     'Create Account',
                      isLoading: _isLoading,
                      onTap:     _handleSignUp,
                    ),

                    const SizedBox(height: 24),

                    AuthFooterLink(
                      prefixText: 'Already have an account? ',
                      linkText:   'Sign In',
                      onTap:      () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 32),
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
  final bool         isObscured;
  final VoidCallback onToggle;

  const _PasswordToggle({required this.isObscured, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
        size:  20,
      ),
      onPressed: onToggle,
    );
  }
}
