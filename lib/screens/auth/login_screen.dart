import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _showPasswordInput = false; // Toggle to show email/password form
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Main app stream will handle navigation, but we provide explicit replacement just in case
      if (mounted) {
         Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() async {
      if (_emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please enter your email first.'), backgroundColor: Colors.orange),
        );
        return;
      }
      try {
        await _authService.sendPasswordResetEmail(_emailController.text.trim());
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Password reset email sent!'), backgroundColor: Colors.green),
        );
      } catch(e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
  }

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
              // Illustration or Logo
              const Spacer(flex: 2),
              Container(
                height: 120,
                width: 120,
                 decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                   color: AppColors.surface,
                ),
                child: const Center(
                   // TODO: Replace with App Logo
                  child: Icon(Icons.restaurant_menu, size: 80, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge,
              ),
               Text(
                'Log in to continue cooking.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 48),

              // Error Message
               if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

              if (!_showPasswordInput) ...[
                 // Initial View: just the "Log in with Email" button that expands the form
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showPasswordInput = true;
                      });
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
              ] else ...[
                  // Expandable Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                             validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your email';
                                if (!value.contains('@')) return 'Please enter a valid email';
                                return null;
                              },
                          ),
                          const SizedBox(height: 16),
                           TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                             validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your password';
                                return null;
                              },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text('Log In', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
              
              const SizedBox(height: 24),

              const Spacer(),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                  GestureDetector(
                    onTap: () {
                       // Navigate to Sign Up
                       Navigator.pushNamed(context, AppRoutes.signup);
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
