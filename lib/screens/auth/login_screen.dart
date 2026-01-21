import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration Placeholder
              const Spacer(flex: 2),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_outline, size: 80, color: Colors.grey),
                ),
              ),
              const Spacer(),

              // Title
              Text(
                'Millions of recipes.\nGet inspired and start cooking.',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge.copyWith(height: 1.2),
              ),
              const SizedBox(height: 48),

              // Login with Email Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Log in with Email', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
              ),
              const SizedBox(height: 16),

              // Social Buttons (Mock)
              _SocialButton(
                icon: Icons.apple,
                text: 'Continue with Apple',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: Icons.g_mobiledata, // Placeholder for Google
                text: 'Continue with Google',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              _SocialButton(
                icon: Icons.facebook,
                text: 'Continue with Facebook',
                onPressed: () {},
              ),

              const Spacer(),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to Sign Up
                    },
                    child: Text(
                      'Sign up',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _SocialButton({required this.icon, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: Icon(icon, size: 24),
      label: Text(text, style: AppTextStyles.labelLarge),
    );
  }
}
