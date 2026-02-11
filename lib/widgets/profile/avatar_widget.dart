import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/premium_service.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final double size;
  final bool showEditButton;
  final VoidCallback? onEditTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.displayName,
    this.size = 80,
    this.showEditButton = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.read<PremiumService>().isPremium,
      builder: (context, isPremium, _) {
        return Stack(
          children: [
            // Avatar
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: imageUrl == null
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: imageUrl == null
                  ? Center(
                      child: Text(
                        _getInitials(displayName),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),

            // Premium badge
            if (isPremium)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: size * 0.15,
                  ),
                ),
              ),

            // Edit button
            if (showEditButton)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditTap ?? () => _showAvatarOptions(context),
                  child: Container(
                    width: size * 0.25,
                    height: size * 0.25,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.primary,
                      size: size * 0.12,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Get initials from display name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }

  /// Show avatar customization options
  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Customize Avatar',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Avatar options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  context,
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(context);
                  },
                ),
                _buildAvatarOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery(context);
                  },
                ),
                _buildAvatarOption(
                  context,
                  icon: Icons.palette,
                  label: 'Generate',
                  onTap: () {
                    Navigator.pop(context);
                    _generateAvatar(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _takePhoto(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📸 Camera feature coming soon!')),
    );
  }

  void _pickFromGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🖼️ Gallery picker coming soon!')),
    );
  }

  void _generateAvatar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎨 Avatar generator coming soon!')),
    );
  }
}