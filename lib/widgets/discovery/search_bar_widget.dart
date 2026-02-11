import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasFocus ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search recipes, ingredients...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _hasFocus ? AppColors.primary : AppColors.textSecondary,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: AppTextStyles.bodyMedium,
        textInputAction: TextInputAction.search,
        onTap: () {
          setState(() {
            _hasFocus = true;
          });
        },
        onTapOutside: (_) {
          setState(() {
            _hasFocus = false;
          });
        },
      ),
    );
  }
}