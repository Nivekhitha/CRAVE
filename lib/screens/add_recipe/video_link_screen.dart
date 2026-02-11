import 'package:flutter/material.dart';
import 'video_recipe_input_screen.dart';

/// Legacy screen - redirects to new VideoRecipeInputScreen
/// Kept for backward compatibility with existing navigation
class VideoLinkScreen extends StatelessWidget {
  const VideoLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to new implementation
    return const VideoRecipeInputScreen();
  }
}
