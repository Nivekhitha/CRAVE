import 'package:flutter/material.dart';

class PurposeScreen extends StatefulWidget {
  const PurposeScreen({super.key});

  @override
  State<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _selectedPurposes = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _purposeOptions = [
    {
      'id': 'discover',
      'label': 'Discover meals',
      'icon': Icons.restaurant_menu,
      'description': 'Find new recipes',
    },
    {
      'id': 'healthy',
      'label': 'Eat healthy',
      'icon': Icons.favorite,
      'description': 'Nutritious options',
    },
    {
      'id': 'cook',
      'label': 'Learn to cook',
      'icon': Icons.menu_book,
      'description': 'Step by step guides',
    },
    {
      'id': 'plan',
      'label': 'Plan better',
      'icon': Icons.calendar_today,
      'description': 'Meal planning',
    },
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
    _animationController.dispose();
    super.dispose();
  }

  void _togglePurpose(String purposeId) {
    setState(() {
      if (_selectedPurposes.contains(purposeId)) {
        _selectedPurposes.remove(purposeId);
      } else {
        _selectedPurposes.add(purposeId);
      }
    });
  }

  void _handleNext() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    Navigator.pushNamed(
      context,
      '/onboarding/avoid',
      arguments: {
        'diet': args?['diet'] ?? 'None',
        'allergies': args?['allergies'] ?? <String>[],
        'purposes': _selectedPurposes,
      },
    );
  }

  void _handleSkip() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    Navigator.pushNamed(
      context,
      '/onboarding/avoid',
      arguments: {
        'diet': args?['diet'] ?? 'None',
        'allergies': args?['allergies'] ?? <String>[],
        'purposes': <String>[],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why are you using our app?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3D351B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We'll tailor the app for your using purpose.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Purpose grid
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                            itemCount: _purposeOptions.length,
                            itemBuilder: (context, index) {
                              final purpose = _purposeOptions[index];
                              final isSelected = _selectedPurposes
                                  .contains(purpose['id']);

                              return GestureDetector(
                                onTap: () => _togglePurpose(purpose['id']),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFC0392B)
                                            .withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFC0392B)
                                          : Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? const Color(0xFFFFF9B4)
                                              : const Color(0xFFFFF9B4),
                                        ),
                                        child: Icon(
                                          purpose['icon'],
                                          size: 32,
                                          color: isSelected
                                              ? const Color(0xFFC0392B)
                                              : const Color(0xFF3D351B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        purpose['label'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFFC0392B)
                                              : const Color(0xFF3D351B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom button
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
                  value: 0.66,
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
          onPressed: _handleNext,
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
            'Next',
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
