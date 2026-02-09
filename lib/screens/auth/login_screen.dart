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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please filling in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (result.isSuccess) {
      if (mounted) {
         Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = result.error;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // App Logo Placeholder
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu, size: 60, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome Back',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue cooking',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
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
                ),
                const SizedBox(height: 24),

                ElevatedButton(
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
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Log In'),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                debugPrint("🟢 'Continue as Guest' pressed");
                setState(() => _isLoading = true);
                try {
                  final result = await _authService.signInAnonymously();
                  debugPrint("🟡 signInAnonymously result: success=${result.isSuccess}, error=${result.error}");
                  
                  if (result.isSuccess) {
                    if (mounted) {
                       Navigator.pushReplacementNamed(context, AppRoutes.main);
                    }
                  } else {
                    if (mounted) {
                      setState(() {
                        _isLoading = false; 
                        _errorMessage = result.error ?? 'Guest login failed';
                      });
                      
                      // Explicit Debug Dialog
                      showDialog(
                        context: context, 
                        builder: (_) => AlertDialog(
                          title: const Text("Login Error"),
                          content: Text("Error: ${result.error}"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
                          ],
                        )
                      );
                    }
                  }
                } catch (e) {
                   debugPrint("🔴 CRITICAL: Exception in Guest Login: $e");
                   if (mounted) {
                     setState(() => _isLoading = false);
                     showDialog(
                        context: context, 
                        builder: (_) => AlertDialog(
                          title: const Text("Critical Error"),
                          content: Text("Exception: $e"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
                          ],
                        )
                      );
                   }
                }
              },
              child: Text('Continue as Guest', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
} // End Class
