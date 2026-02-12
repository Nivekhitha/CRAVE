import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class AvoidIngredientsScreen extends StatefulWidget {
  const AvoidIngredientsScreen({super.key});

  @override
  State<AvoidIngredientsScreen> createState() =>
      _AvoidIngredientsScreenState();
}

class _AvoidIngredientsScreenState extends State<AvoidIngredientsScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _selectedIngredients = [];
  final List<String> _customIngredients = [];
  final TextEditingController _otherController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _ingredientsToAvoid = [
    'Mushroom',
    'Celery',
    'Onion',
    'Broccoli',
    'Olives',
    'Cilantro',
    'Tomato',
    'Cheese',
    'Beef',
    'Pork',
    'Chili Pepper',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _otherController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  void _showAddOtherDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add ingredient to avoid'),
        content: TextField(
          controller: _otherController,
          decoration: InputDecoration(
            hintText: 'Enter ingredient name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _otherController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_otherController.text.trim().isNotEmpty) {
                setState(() {
                  _customIngredients.add(_otherController.text.trim());
                });
                _otherController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCustomIngredient(String ingredient) {
    setState(() {
      _customIngredients.remove(ingredient);
    });
  }

  Future<void> _handleGetStarted() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final allAvoidIngredients = [
      ..._selectedIngredients,
      ..._customIngredients,
    ];

    // Save preferences to Firestore
    try {
      final authService = context.read<AuthService>();
      final firestoreService = FirestoreService();

      if (authService.userId != null) {
        await firestoreService.updateUserProfile({
          'dietaryPreference': args?['diet'] ?? 'None',
          'allergies': args?['allergies'] ?? <String>[],
          'appPurposes': args?['purposes'] ?? <String>[],
          'ingredientsToAvoid': allAvoidIngredients,
          'onboardingCompleted': true,
        });
      }
    } catch (e) {
      debugPrint('Error saving onboarding preferences: $e');
    }

    // Navigate to main navigation screen
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  Future<void> _handleSkip() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    try {
      final authService = context.read<AuthService>();
      final firestoreService = FirestoreService();

      if (authService.userId != null) {
        await firestoreService.updateUserProfile({
          'dietaryPreference': args?['diet'] ?? 'None',
          'allergies': args?['allergies'] ?? <String>[],
          'appPurposes': args?['purposes'] ?? <String>[],
          'ingredientsToAvoid': <String>[],
          'onboardingCompleted': true,
        });
      }
    } catch (e) {
      debugPrint('Error saving onboarding preferences: $e');
    }

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What ingredients do you\nprefer to avoid?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3D351B),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select all that apply',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Ingredients grid
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ..._ingredientsToAvoid.map((ingredient) {
                              final isSelected =
                                  _selectedIngredients.contains(ingredient);
                              return GestureDetector(
                                onTap: () => _toggleIngredient(ingredient),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFC0392B)
                                            .withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFC0392B)
                                          : Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    ingredient,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFFC0392B)
                                          : const Color(0xFF3D351B),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Other button
                            GestureDetector(
                              onTap: _showAddOtherDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 16,
                                      color: const Color(0xFF3D351B),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Other',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF3D351B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Custom ingredients section
                        if (_customIngredients.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          const Text(
                            'Added by you:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3D351B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _customIngredients.map((ingredient) {
                              return Container(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                  top: 10,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9B4),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: const Color(0xFFD79F90),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ingredient,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF3D351B),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          _removeCustomIngredient(ingredient),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Color(0xFFC0392B),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFFC0392B),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFC0392B),
                  ),
                  minHeight: 4,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleSkip,
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 6,
            shadowColor: const Color(0xFFC0392B).withOpacity(0.3),
          ),
          child: const Text(
            'Get started',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
