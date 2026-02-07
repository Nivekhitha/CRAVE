import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../services/image_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String imageUrl)? onImageUploaded;
  final Function()? onImageRemoved;
  final String recipeId;
  final double? width;
  final double? height;
  final bool allowRemove;

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    this.onImageUploaded,
    this.onImageRemoved,
    required this.recipeId,
    this.width,
    this.height,
    this.allowRemove = true,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImageService _imageService = ImageService();
  final picker.ImagePicker _picker = picker.ImagePicker();
  
  String? _currentImageUrl;
  bool _isUploading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isUploading) {
      return _buildUploadingState();
    }

    if (_currentImageUrl != null || _selectedImage != null) {
      return _buildImagePreview();
    }

    return _buildUploadPrompt();
  }

  Widget _buildUploadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Uploading image...'),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        // Image
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _currentImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildUploadPrompt();
                    },
                  ),
          ),
        ),

        // Overlay with actions
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // Action buttons
        Positioned(
          bottom: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.allowRemove)
                _buildActionButton(
                  icon: Icons.delete,
                  onPressed: _removeImage,
                  backgroundColor: Colors.red.withOpacity(0.8),
                ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.edit,
                onPressed: _showImageSourceDialog,
                backgroundColor: AppColors.primary.withOpacity(0.8),
              ),
            ],
          ),
        ),

        // Upload progress indicator for selected image
        if (_selectedImage != null)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.upload, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to upload',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadPrompt() {
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: AppColors.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Recipe Photo',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to upload from camera or gallery',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add Recipe Photo',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to capture your dish'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(picker.ImageSource.camera);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select from your photo library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(picker.ImageSource.gallery);
                },
              ),
              
              if (_selectedImage != null) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cloud_upload, color: Colors.green),
                  title: const Text('Upload Selected Image'),
                  subtitle: const Text('Save the selected image'),
                  onTap: () {
                    Navigator.pop(context);
                    _uploadSelectedImage();
                  },
                ),
              ],
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(picker.ImageSource source) async {
    try {
      final picker.XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _uploadSelectedImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await _imageService.uploadUserImage(
        _selectedImage!,
        widget.recipeId,
      );

      setState(() {
        _currentImageUrl = imageUrl;
        _selectedImage = null;
        _isUploading = false;
      });

      widget.onImageUploaded?.call(imageUrl);
      
      _showSuccessSnackBar('Image uploaded successfully!');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackBar('Failed to upload image: $e');
    }
  }

  Future<void> _removeImage() async {
    final confirmed = await _showConfirmationDialog(
      'Remove Image',
      'Are you sure you want to remove this image?',
    );

    if (confirmed == true) {
      // Delete from Firebase Storage if it's a user-uploaded image
      if (_currentImageUrl != null && _currentImageUrl!.contains('firebase')) {
        try {
          await _imageService.deleteUserImage(_currentImageUrl!);
        } catch (e) {
          debugPrint('Failed to delete image from storage: $e');
        }
      }

      setState(() {
        _currentImageUrl = null;
        _selectedImage = null;
      });

      widget.onImageRemoved?.call();
      _showSuccessSnackBar('Image removed');
    }
  }

  Future<bool?> _showConfirmationDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}