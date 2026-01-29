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

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploading = true;
          _statusMessage = 'Reading PDF file (v7)...';
          _progressValue = 0.3;
        });

        File file = File(result.files.single.path!);

        // 2. Extract & Analyze
        // Small delay to show UI update
        await Future.delayed(const Duration(milliseconds: 500));
        
        setState(() {
          _statusMessage = 'Sending to AI for analysis...\nThis may take a moment.';
           _progressValue = null; // Indeterminate for API call
        });

        List<Recipe> recipes = await _extractionService.extractRecipes(file);
        
        if (!mounted) return;

        setState(() {
          _statusMessage = 'Success!';
          _isUploading = false;
        });

        // 3. Navigate to Results
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CookbookResultsScreen(
              recipes: recipes, 
              sourceFileName: result.files.single.name
            )
          ),
        );

      } else {
        // User canceled
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _statusMessage = '';
      });
      _showErrorDialog(e.toString());
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
                 child: Container(
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
                   child: const CircularProgressIndicator(strokeWidth: 3),
                 ),
               ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
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
              
              // Key Warning (Temporary)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3))
                ),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key, size: 20, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Requires Gemini API Key configured in service.",
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.amber[800]),
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
