import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/cookbook_extraction_service.dart';
import '../../models/recipe.dart';
import 'cookbook_results_screen.dart'; // Will create next

class CookbookUploadScreen extends StatefulWidget {
  const CookbookUploadScreen({super.key});

  @override
  State<CookbookUploadScreen> createState() => _CookbookUploadScreenState();
}

class _CookbookUploadScreenState extends State<CookbookUploadScreen> {
  final CookbookExtractionService _extractionService = CookbookExtractionService();
  bool _isUploading = false;
  String _statusMessage = '';
  double? _progressValue;

  Future<void> _pickAndProcessFile() async {
    try {
      // 1. Pick PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        // User canceled - silently return
        return;
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Check file exists
      if (!await file.exists()) {
        _showErrorDialog('Selected file not found. Please try again.');
        return;
      }

      setState(() {
        _isUploading = true;
        _statusMessage = 'Reading PDF file...';
        _progressValue = 0.2;
      });

      // 2. Extract & Analyze with progress callbacks
      List<Recipe> recipes = await _extractionService.extractRecipes(
        file,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _statusMessage = progress;
              if (progress.contains('complete')) {
                _progressValue = 1.0;
              } else if (progress.contains('Analyzing')) {
                _progressValue = null; // Indeterminate
              }
            });
          }
        },
      );
      
      if (!mounted) return;

      if (recipes.isEmpty) {
        setState(() {
          _statusMessage = 'Analysis Complete';
          _isUploading = false;
        });
        _showErrorDialog(
          "No recipes found in this PDF.\n\n"
          "Tips:\n"
          "• Make sure the PDF contains recipe text (not just images)\n"
          "• Try a different page or section\n"
          "• Ensure the text is selectable/copyable",
        );
        return;
      }

      // Small delay to show success message
      setState(() {
        _statusMessage = 'Success! Found ${recipes.length} recipe${recipes.length > 1 ? 's' : ''}.';
        _progressValue = 1.0;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // 3. Navigate to Results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CookbookResultsScreen(
            recipes: recipes, 
            sourceFileName: fileName,
          )
        ),
      );

    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isUploading = false;
        _statusMessage = '';
        _progressValue = null;
      });
      
      // Extract user-friendly error message
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      
      _showErrorDialog(errorMsg);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Extraction Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Cookbook'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        titleTextStyle: AppTextStyles.titleMedium,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isUploading) ...[
              const Spacer(),
               Center(
                 child: Column(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(32),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         boxShadow: [
                           BoxShadow(
                             color: AppColors.primary.withOpacity(0.1),
                             blurRadius: 20,
                             spreadRadius: 5
                           )
                         ]
                       ),
                       child: _progressValue != null
                           ? CircularProgressIndicator(
                               value: _progressValue,
                               strokeWidth: 3,
                               valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                             )
                           : const CircularProgressIndicator(strokeWidth: 3),
                     ),
                     const SizedBox(height: 24),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       decoration: BoxDecoration(
                         color: AppColors.surface,
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Text(
                         _statusMessage,
                         textAlign: TextAlign.center,
                         style: AppTextStyles.bodyMedium.copyWith(
                           color: AppColors.textPrimary,
                           height: 1.5,
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
              const Spacer(),
            ] else ...[
              const Spacer(),
              // Hero Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Digital Cookbook Import',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Upload your PDF cookbooks and let our AI magically extract recipes, ingredients, and instructions for you.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              
              // Info Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Works best with PDFs containing selectable text. Image-only PDFs may not work.",
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.blue[800]),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _pickAndProcessFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDF Cookbook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: AppTextStyles.labelLarge
                ),
              ),
              const SizedBox(height: 16),
            ]
          ],
        ),
      ),
    );
  }
}
