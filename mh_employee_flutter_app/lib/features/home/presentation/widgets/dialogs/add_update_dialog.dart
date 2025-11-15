import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_decorations.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/buttons/modern_button.dart';

/// Modern Add Update Dialog
class AddUpdateDialog extends StatefulWidget {
  final Function(String title, String content) onSubmit;

  const AddUpdateDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddUpdateDialog> createState() => _AddUpdateDialogState();
}

class _AddUpdateDialogState extends State<AddUpdateDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(
        _titleController.text.trim(),
        _contentController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: AppDecorations.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Icon(
                      Icons.post_add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Add New Update',
                    style: AppTextStyles.heading2.copyWith(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: AppDecorations.inputDecoration(
                  label: 'Title',
                  hint: 'Enter update title...',
                  prefix: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Content Field
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: AppDecorations.inputDecoration(
                  label: 'Content',
                  hint: 'Enter update content...',
                  prefix: const Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Cancel',
                      variant: ModernButtonVariant.outlined,
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernButton(
                      text: 'Add Update',
                      icon: Icons.add,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleSubmit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
