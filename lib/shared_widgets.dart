

import 'package:flutter/material.dart';
import 'app_colors.dart';


class ScreenHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;

  const ScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [

          Container(
            width:  80,
            height: 80,
            decoration: BoxDecoration(
              color:  AppColors.accent.withAlpha(38),
              shape:  BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Icon(icon, size: 40, color: AppColors.accent),
          ),

          const SizedBox(height: 20),

          // Title (big bold text)
          Text(
            title,
            style: const TextStyle(
              color:      AppColors.textPrimary,
              fontSize:   28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle (smaller grey text below title)
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color:    AppColors.textSecondary,
              fontSize: 14,
              height:   1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FieldLabel ────────────────────────────────────────────────
// Small bold label displayed above each input field.
// Example: "Username", "Password", "Email Address"
class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color:       AppColors.textPrimary,
        fontSize:    13,
        fontWeight:  FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}


class AppInputField extends StatelessWidget {
  final TextEditingController   controller;
  final String                  hint;
  final IconData                icon;
  final bool                    obscureText;  
  final Widget?                 suffixIcon;   
  final TextInputType?          keyboardType;
  final String? Function(String?)? validator; 

  const AppInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText  = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscureText,
      keyboardType: keyboardType,
      validator:    validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
      decoration: InputDecoration(
        hintText:    hint,
        hintStyle:   const TextStyle(color: AppColors.textSecondary, fontSize: 14.5),
        prefixIcon:  Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon:  suffixIcon,
        filled:      true,
        fillColor:   AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

       
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: AppColors.border),
        ),
       
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: AppColors.border),
        ),
      
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: AppColors.error),
        ),
    
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),
    );
  }
}

// ── PrimaryButton ─────────────────────────────────────────────
// The big teal full-width button used on every auth screen.
// Shows a loading spinner when [isLoading] is true.
// Automatically disables itself while loading.
class PrimaryButton extends StatelessWidget {
  final String       label;
  final bool         isLoading;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap, // disabled while loading
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withAlpha(102),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width:  22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color:        Colors.white,
                  fontSize:     15,
                  fontWeight:   FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}


class AuthFooterLink extends StatelessWidget {
  final String       prefixText;
  final String       linkText;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prefixText,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: const TextStyle(
                color:      AppColors.accent,
                fontSize:   14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
