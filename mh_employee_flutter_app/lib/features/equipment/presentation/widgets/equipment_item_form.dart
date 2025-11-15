import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mh_employee_app/core/theme/app_colors.dart';
import 'package:mh_employee_app/shared/widgets/modern_glass_card.dart';
import 'package:mh_employee_app/features/equipment/data/models/equipment_request_model.dart';
import 'quantity_field.dart';

class EquipmentItemForm<T> extends StatefulWidget {
  final T item;
  final int itemNumber;
  final VoidCallback onRemove;
  final List<String> justificationOptions;

  const EquipmentItemForm({
    Key? key,
    required this.item,
    required this.itemNumber,
    required this.onRemove,
    this.justificationOptions = const ['New', 'Replaced', 'Other'],
  }) : super(key: key);

  @override
  _EquipmentItemFormState createState() => _EquipmentItemFormState();
}

class _EquipmentItemFormState extends State<EquipmentItemForm> {
  late String _currentJustification;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _currentJustification = (widget.item as EquipmentItem).justification ?? widget.justificationOptions[0];
    _titleController = TextEditingController(text: (widget.item as dynamic).title ?? '');
    _descriptionController = TextEditingController(text: (widget.item as dynamic).description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setJustification(String? value) {
    if (value == null) return;
    setState(() {
      _currentJustification = value;
      (widget.item as EquipmentItem).justification = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernGlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16),
      gradient: AppColors.gradientPurple.map((c) => c.withOpacity(0.05)).toList(),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientPurple.map((c) => c.withOpacity(0.1)).toList(),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientPurple),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Item #${widget.itemNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                  onPressed: widget.onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Title Field
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    hintText: 'Enter equipment title',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                    prefixIcon: Icon(
                      Icons.inventory_2_rounded,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => (widget.item as dynamic).title = value,
                ),

                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    hintText: 'Enter equipment description',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                    prefixIcon: Icon(
                      Icons.description_rounded,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) => (widget.item as dynamic).description = value,
                ),

                const SizedBox(height: 16),

                // Quantity and Justification Row
                Row(
                  children: [
                    Expanded(
                      child: QuantityField(
                        initialValue: (widget.item as dynamic).quantity ?? 1,
                        onChanged: (value) => (widget.item as dynamic).quantity = value,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentJustification,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                            items: widget.justificationOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.label_rounded,
                                      size: 16,
                                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      value,
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: _setJustification,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
