import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/gift_models.dart';
import '../../blocs/gift/gift_bloc.dart';
import '../../utils/image_picker_helper.dart';
import '../common/button_loading_indicator.dart';
import '../photo/gift_photo_picker.dart';

class AddGiftBottomSheet extends StatefulWidget {
  final int wishlistId;

  const AddGiftBottomSheet({
    super.key,
    required this.wishlistId,
  });

  @override
  State<AddGiftBottomSheet> createState() => _AddGiftBottomSheetState();
}

class _AddGiftBottomSheetState extends State<AddGiftBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkController = TextEditingController();
  final _descController = TextEditingController();

  bool _isVisible = true;
  File? _selectedPhoto;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Actions
  // --------------------------------------------------------------------------

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final priceString = _priceController.text.trim().replaceAll(',', '.');
      final price = double.tryParse(priceString) ?? 0.0;

      final createModel = GiftCreateModel(
        name: name,
        priceUsd: price,
        linkUrl: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        isVisible: _isVisible,
        wishlistId: widget.wishlistId,
      );

      context.read<GiftBloc>().add(
        CreateGift(
          createModel: createModel,
          photoFile: _selectedPhoto,
        ),
      );
    }
  }

  // Handle picking an image from the gallery
  Future<void> _pickPhoto() async {
    final file = await ImagePickerHelper.pickImageFromGallery(context);
    if (file != null) {
      setState(() {
        _selectedPhoto = file;
      });
    }
  }

  // --------------------------------------------------------------------------
  // Validators
  // --------------------------------------------------------------------------

  /// Validates the gift name input
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a gift name';
    }
    return null;
  }

  /// Validates the price input
  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a price';
    }
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomKeyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<GiftBloc, GiftState>(
      listener: (context, state) {
        if (state is GiftActionSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is GiftLoading;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: bottomKeyboardInset + 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header & Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Gift',
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 2. Photo Upload Box
                          GiftPhotoPicker(
                            localImage: _selectedPhoto,
                            isLoading: isLoading,
                            onTap: _pickPhoto,
                          ),
                          const SizedBox(height: 16),

                          // 3. Name Field (Required)
                          TextFormField(
                            controller: _nameController,
                            enabled: !isLoading,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Name *',
                              hintText: 'e.g., Wireless Headphones',
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 16),

                          // 4. Price Field (Required)
                          TextFormField(
                            controller: _priceController,
                            enabled: !isLoading,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Price (USD) *',
                              hintText: '0.00',
                              prefixText: '\$ ',
                            ),
                            validator: _validatePrice,
                          ),
                          const SizedBox(height: 16),

                          // 5. Link Field (Optional)
                          TextFormField(
                            controller: _linkController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.url,
                            decoration: const InputDecoration(
                              labelText: 'Link URL',
                              hintText: 'https://...',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 6. Description Field (Optional)
                          TextFormField(
                            controller: _descController,
                            enabled: !isLoading,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Add any details like size, color, etc.',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 7. Visibility Toggle
                          SwitchListTile(
                            title: const Text('Visible to others'),
                            subtitle: const Text('Allow friends to see this gift'),
                            value: _isVisible,
                            activeTrackColor: theme.colorScheme.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: isLoading
                                ? null
                                : (value) {
                              setState(() {
                                _isVisible = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 8. Submit Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
                    child: isLoading
                        ? const ButtonLoadingIndicator()
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}