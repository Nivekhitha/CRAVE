import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'cookbook_results_screen.dart';

class CookbookUploadScreen extends StatefulWidget {
  const CookbookUploadScreen({super.key});

  @override
  State<CookbookUploadScreen> createState() => _CookbookUploadScreenState();
}

class _CookbookUploadScreenState extends State<CookbookUploadScreen> {
  bool _isLoading = false;
  bool _fileSelected = false;

  void _uploadAndExtract() {
    if (!_fileSelected) return;

    setState(() => _isLoading = true);

    // Simulate Processing
    Timer(const Duration(seconds: 3), () {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const CookbookResultsScreen())
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add via Cookbook'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             Text(
              'Upload a cookbook page',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We will extract all recipes found on the page',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Upload Area
            GestureDetector(
              onTap: () {
                setState(() => _fileSelected = true);
              },
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _fileSelected ? Colors.green.shade50 : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _fileSelected ? Colors.green : Colors.grey.shade300, 
                    style: BorderStyle.solid, 
                    width: 2
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _fileSelected ? Icons.check_circle : Icons.cloud_upload_outlined, 
                      size: 60, 
                      color: _fileSelected ? Colors.green : AppColors.textSecondary
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _fileSelected ? 'cookbook_page_001.pdf' : 'Tap to Upload PDF or Image',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fileSelected && !_isLoading ? _uploadAndExtract : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Extract Recipes', style: AppTextStyles.labelLarge),
              ),
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
