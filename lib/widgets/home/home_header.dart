import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/app_text_styles.dart';
import '../../app/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good evening,',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.slate,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '$userName 👋',
                      style: AppTextStyles.displaySmall.copyWith(fontSize: 28),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.softLavender, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softLavender.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surface,
                  backgroundImage: avatarUrl.isNotEmpty 
                    ? CachedNetworkImageProvider(avatarUrl) 
                    : null,
                  child: avatarUrl.isEmpty 
                    ? const Icon(Icons.person, color: AppColors.slate) 
                    : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to cook today?',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}
