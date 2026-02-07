import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                AppColors.surface,
                AppColors.surface.withOpacity(0.5),
                AppColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsets? padding;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 120,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: 16,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            width: 120,
            height: 14,
            borderRadius: BorderRadius.circular(7),
          ),
          const Spacer(),
          Row(
            children: [
              SkeletonLoader(
                width: 60,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const Spacer(),
              SkeletonLoader(
                width: 40,
                height: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          if (hasLeading) ...[
            SkeletonLoader(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(24),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 150,
                  height: 14,
                  borderRadius: BorderRadius.circular(7),
                ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16),
            SkeletonLoader(
              width: 24,
              height: 24,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ],
      ),
    );
  }
}

class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}