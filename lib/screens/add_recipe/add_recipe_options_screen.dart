import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'video_link_screen.dart';
import 'cookbook_upload_screen.dart';
import 'add_recipe_screen.dart';

class AddRecipeOptionsScreen extends StatelessWidget {
  const AddRecipeOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Add Recipe',
          style: AppTextStyles.titleLarge.copyWith(
            color: const Color(0xFF3D351B), // Dark brown text
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFC0392B)), // Red close icon
              onPressed: () => Navigator.pop(context),
            )
          : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'How would you like to add your recipe?',
              style: AppTextStyles.titleMedium.copyWith(
                color: const Color(0xFF6B6B6B), // Gray text
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Video Link Option
            _OptionCard(
              icon: Icons.link,
              title: 'Add via Video Link',
              subtitle: 'Paste a YouTube or Instagram Reel link to extract ingredients and steps.',
              color: Colors.blue.shade50,
              iconColor: Colors.blue,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoLinkScreen()));
              },
            ),
            const SizedBox(height: 16),

            // Digital Cookbook Option
            _OptionCard(
              icon: Icons.menu_book,
              title: 'Add via Digital Cookbook',
              subtitle: 'Upload a PDF or photo of a cookbook page to extract recipes.',
              color: Colors.orange.shade50,
              iconColor: Colors.orange,
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const CookbookUploadScreen()));
              },
            ),
            const SizedBox(height: 16),

            // Manual Entry Option
            _OptionCard(
              icon: Icons.edit_note,
              title: 'Enter Manually',
              subtitle: 'Type in ingredients and instructions yourself.',
              color: AppColors.surface,
              iconColor: AppColors.primary,
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecipeScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC0392B).withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF3D351B), // Dark brown text
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF6B6B6B), // Gray text
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6B6B6B), // Gray arrow
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
