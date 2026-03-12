import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'shared_widgets.dart';
import 'user_repository.dart';
import 'login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

// ─
enum _Step { username, newPassword, success }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // ── Dependencies ─────────────────────────────────────────────
  final UserRepository _repository = UserRepository();

  // ── Controllers ──────────────────────────────────────────────
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ── State ────────────────────────────────────────────────────
  _Step _currentStep = _Step.username; // always start on step 1
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // ── Animation ────────────────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

  IconData get _headerIcon => switch (_currentStep) {
        _Step.username => Icons.lock_reset_rounded,
        _Step.newPassword => Icons.vpn_key_outlined,
        _Step.success => Icons.check_circle_rounded,
      };

  String get _headerTitle => switch (_currentStep) {
        _Step.username => 'Forgot Password?',
        _Step.newPassword => 'Set New Password',
        _Step.success => 'Password Reset!',
      };

  String get _headerSubtitle => switch (_currentStep) {
        _Step.username => 'Enter your username to\nverify your account',
        _Step.newPassword => 'Create a strong new password\nfor your account',
        _Step.success => 'Your password has been\nupdated successfully',
      };

  Future<void> _handleVerifyUsername() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _repository.verifyUsername(_usernameController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _goToStep(_Step.newPassword);
    } else {
      _showError(result.errorMessage!);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _repository.resetPassword(
      _usernameController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _goToStep(_Step.success);
    } else {
      _showError(result.errorMessage!);
    }
  }

  void _goToStep(_Step step) {
    setState(() => _currentStep = step);
    _animController
      ..reset()
      ..forward();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _BackButton(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()))),
                  const SizedBox(height: 36),
                  ScreenHeader(
                    icon: _headerIcon,
                    title: _headerTitle,
                    subtitle: _headerSubtitle,
                  ),
                  const SizedBox(height: 48),
                  _buildCurrentStep(),
                  const SizedBox(height: 32),
                  const OrDivider(),
                  const SizedBox(height: 24),
                  AuthFooterLink(
                    prefixText: 'Remember your password? ',
                    linkText: 'Sign In',
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns the correct form widget based on the current step
  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      _Step.username => _UsernameStep(
          formKey: _formKey,
          controller: _usernameController,
          isLoading: _isLoading,
          onSubmit: _handleVerifyUsername,
        ),
      _Step.newPassword => _NewPasswordStep(
          formKey: _formKey,
          newPasswordController: _newPasswordController,
          confirmController: _confirmController,
          obscureNew: _obscureNew,
          obscureConfirm: _obscureConfirm,
          isLoading: _isLoading,
          onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
          onToggleConfirm: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          onSubmit: _handleResetPassword,
        ),
      _Step.success => _SuccessStep(
          username: _usernameController.text.trim(),
          onBackToLogin: () => Navigator.pop(context),
        ),
    };
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int current;
  final int total;
  final String label;

  const _StepBadge({
    required this.current,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(total, (i) {
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current
                      ? AppColors.accent
                      : AppColors.accent.withAlpha(50),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          Text(
            'Step $current of $total · $label',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsernameStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _UsernameStep({
    required this.formKey,
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepBadge(current: 1, total: 2, label: 'Verify Account'),
          const SizedBox(height: 20),
          const FieldLabel(label: 'Username'),
          const SizedBox(height: 8),
          AppInputField(
            controller: controller,
            hint: 'Enter your registered username',
            icon: Icons.person_outline_rounded,
            validator: UserRepository.validateUsername,
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.info_outline_rounded,
                  size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Use the username you registered with',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Verify Account',
            isLoading: isLoading,
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _NewPasswordStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordController;
  final TextEditingController confirmController;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool isLoading;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  const _NewPasswordStep({
    required this.formKey,
    required this.newPasswordController,
    required this.confirmController,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.isLoading,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepBadge(current: 2, total: 2, label: 'Set New Password'),
          const SizedBox(height: 20),
          const FieldLabel(label: 'New Password'),
          const SizedBox(height: 8),
          AppInputField(
            controller: newPasswordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: obscureNew,
            suffixIcon: IconButton(
              icon: Icon(
                obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggleNew,
            ),
            validator: UserRepository.validateNewPassword,
          ),
          const SizedBox(height: 18),
          const FieldLabel(label: 'Confirm New Password'),
          const SizedBox(height: 8),
          AppInputField(
            controller: confirmController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggleConfirm,
            ),
            validator: (val) => UserRepository.validateConfirmPassword(
              val,
              newPasswordController.text,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Reset Password',
            isLoading: isLoading,
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SuccessStep extends StatelessWidget {
  final String username;
  final VoidCallback onBackToLogin;

  const _SuccessStep({required this.username, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withAlpha(80)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                'Password updated for:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                username,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),
              const Text(
                'You can now sign in using your new password. Keep it safe!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Back to Sign In',
          isLoading: false,
          onTap: onBackToLogin,
        ),
      ],
    );
  }
}
