import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/recipe_extraction_service.dart';
import '../../models/extraction_result.dart';
import '../../widgets/extraction/extraction_progress_widget.dart';
import 'cookbook_results_screen.dart';

class CookbookUploadScreen extends StatefulWidget {
  const CookbookUploadScreen({super.key});

  @override
  State<CookbookUploadScreen> createState() => _CookbookUploadScreenState();
}

class _CookbookUploadScreenState extends State<CookbookUploadScreen> {
  final RecipeExtractionService _extractionService = RecipeExtractionService();
  bool _isExtracting = false;
  String _currentStep = '';
  List<String> _completedSteps = [];
  List<String> _warnings = [];
  int? _recipesFound;
  bool _isComplete = false;

  Future<void> _pickAndProcessFile() async {
    if (_isExtracting) return;

    try {
      // 1. Pick PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        return; // User canceled
      }

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      // Check file exists
      if (!await file.exists()) {
        _showErrorDialog('Selected file not found. Please try again.');
        return;
      }

      setState(() {
        _isExtracting = true;
        _currentStep = 'Preparing extraction...';
        _completedSteps = [];
        _warnings = [];
        _recipesFound = null;
        _isComplete = false;
      });

      // 2. Extract with robust system
      final extractionResult = await _extractionService.extractRecipe(
        pdfPath: file.path,
        onProgress: (step) {
          if (mounted) {
            setState(() {
              // Move current step to completed if it's not the first step
              if (_currentStep.isNotEmpty && !_currentStep.contains('Preparing')) {
                _completedSteps.add(_currentStep);
              }
              _currentStep = step;
              
              // Update recipe count if found
              if (step.contains('recipe') && step.contains('found')) {
                final match = RegExp(r'(\d+) recipe').firstMatch(step);
                if (match != null) {
                  _recipesFound = int.tryParse(match.group(1) ?? '0');
                }
              }
            });
          }
        },
      );
      
      if (!mounted) return;

      // Handle result
      setState(() {
        _isComplete = true;
        _warnings = extractionResult.warnings;
        _recipesFound = extractionResult.recipeCount;
        
        if (extractionResult.hasRecipes) {
          _currentStep = 'Extraction complete! Found ${extractionResult.recipeCount} recipe${extractionResult.recipeCount == 1 ? '' : 's'}.';
        } else {
          _currentStep = 'No recipes found in this document.';
        }
      });

      // Small delay to show completion
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      if (extractionResult.hasRecipes) {
        // Navigate to results
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CookbookResultsScreen(
              recipes: extractionResult.recipes, 
              sourceFileName: fileName,
            )
          ),
        );
      } else {
        // Show helpful error message
        _showNoRecipesDialog(extractionResult.warnings);
      }

    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isExtracting = false;
        _currentStep = '';
        _isComplete = false;
      });
      
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    // Clean up error message
    String cleanMessage = message;
    if (cleanMessage.startsWith('Exception: ')) {
      cleanMessage = cleanMessage.substring(11);
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Extraction Failed'),
        content: Text(cleanMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showNoRecipesDialog(List<String> warnings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No Recipes Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Could not find any recipes in this document.'),
            const SizedBox(height: 16),
            const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Make sure the PDF contains recipe text (not just images)'),
            const Text('• Try a different page or section'),
            const Text('• Ensure the text is selectable/copyable'),
            if (warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Issues found:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...warnings.map((w) => Text('• $w', style: const TextStyle(fontSize: 12))),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isExtracting = false;
                _currentStep = '';
                _isComplete = false;
              });
            },
            child: const Text('Try Again'),
          )
        ],
      ),
    );
  }

  void _cancelExtraction() {
    setState(() {
      _isExtracting = false;
      _currentStep = '';
      _isComplete = false;
      _completedSteps = [];
      _warnings = [];
      _recipesFound = null;
    });
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
            if (_isExtracting) ...[
              const Spacer(),
              ExtractionProgressWidget(
                currentStep: _currentStep,
                completedSteps: _completedSteps,
                warnings: _warnings,
                recipesFound: _recipesFound,
                isComplete: _isComplete,
                onCancel: _isComplete ? null : _cancelExtraction,
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
                        "Works best with PDFs containing selectable text. Our robust system will retry automatically if needed.",
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.blue[800]),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isExtracting ? null : _pickAndProcessFile,
                icon: const Icon(Icons.upload_file),
                label: Text(_isExtracting ? 'Extracting...' : 'Select PDF Cookbook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: AppTextStyles.labelLarge
                ),
              ),
             ],
            ],
        ),
      ),
    );
  }
}
