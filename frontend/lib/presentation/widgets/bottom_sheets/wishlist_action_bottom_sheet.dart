import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/wishlist_models.dart';
import '../../blocs/wishlist/wishlist_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../common/button_loading_indicator.dart';

class WishlistActionBottomSheet extends StatefulWidget {
  // If provided, the sheet operates in 'Edit' mode instead of 'Create' mode
  final WishlistBaseModel? wishlist;

  const WishlistActionBottomSheet({
    super.key,
    this.wishlist,
  });

  @override
  State<WishlistActionBottomSheet> createState() => _WishlistActionBottomSheetState();
}

class _WishlistActionBottomSheetState extends State<WishlistActionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isVisible = true;

  // Check if the current mode is editing
  bool get _isEditMode => widget.wishlist != null;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if we are editing an existing wishlist
    if (_isEditMode) {
      _titleController.text = widget.wishlist!.title;
      _isVisible = widget.wishlist!.isVisible;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final userState = context.read<UserBloc>().state;

      if (userState is UserLoaded) {
        if (_isEditMode) {
          final updateModel = WishlistUpdateModel(
            title: _titleController.text.trim(),
            isVisible: _isVisible,
          );
          context.read<WishlistBloc>().add(
            UpdateWishlist(
              wishlistId: widget.wishlist!.id,
              updateModel: updateModel,
            ),
          );
        } else {
          final createModel = WishlistCreateModel(
            title: _titleController.text.trim(),
            isVisible: _isVisible,
          );
          context.read<WishlistBloc>().add(
            CreateWishlist(createModel: createModel),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomKeyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess) {
          // Close the bottom sheet automatically upon successful action
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is WishlistLoading;

        return Padding(
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
                // 1. Dynamic Header based on mode
                Text(
                  _isEditMode ? 'Edit Wishlist' : 'Create New Wishlist',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 2. Title Input Field
                TextFormField(
                  controller: _titleController,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'E.g., Birthday 2026',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 3. Visibility Toggle
                SwitchListTile(
                  title: const Text('Visible to others'),
                  subtitle: const Text('Allow friends to see this wishlist'),
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

                // 4. Dynamic Submit Button text/action
                ElevatedButton(
                  onPressed: isLoading ? null : _onSubmit,
                  child: isLoading
                      ? const ButtonLoadingIndicator()
                      : Text(_isEditMode ? 'Save' : 'Create'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}