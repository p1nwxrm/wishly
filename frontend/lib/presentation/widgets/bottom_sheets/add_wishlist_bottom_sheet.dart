import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/wishlist_models.dart';
import '../../blocs/wishlist/wishlist_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../common/button_loading_indicator.dart';

class AddWishlistBottomSheet extends StatefulWidget {
  const AddWishlistBottomSheet({super.key});

  @override
  State<AddWishlistBottomSheet> createState() => _AddWishlistBottomSheetState();
}

class _AddWishlistBottomSheetState extends State<AddWishlistBottomSheet> {
  // Key for form validation
  final _formKey = GlobalKey<FormState>();

  // Controller to read the title input
  final _titleController = TextEditingController();

  // Default state for the visibility toggle
  bool _isVisible = true;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    // Validate the text field before proceeding
    if (_formKey.currentState?.validate() ?? false) {
      // Retrieve the current user's ID to set as the owner
      final userState = context.read<UserBloc>().state;

      if (userState is UserLoaded) {
        // Construct the payload model
        final createModel = WishlistCreateModel(
          title: _titleController.text.trim(),
          isVisible: _isVisible,
          ownerId: userState.user.id,
        );

        // Dispatch the creation event
        context.read<WishlistBloc>().add(CreateWishlist(createModel: createModel));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Crucial for bottom sheets with text fields: gets the keyboard height
    // so the sheet can be pushed up and avoid hiding the text input.
    final bottomKeyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state is WishlistActionSuccess) {
          // Close the bottom sheet automatically when the wishlist is created
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is WishlistLoading;

        return Padding(
          // Apply dynamic padding based on the keyboard presence
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: bottomKeyboardInset + 24.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content tightly
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header
                Text(
                  'Create New Wishlist',
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
                      ? null // Disable the switch while loading
                      : (value) {
                    setState(() {
                      _isVisible = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 4. Submit Button
                ElevatedButton(
                  onPressed: isLoading ? null : _onSubmit,
                  child: isLoading
                      ? const ButtonLoadingIndicator()
                      : const Text('Create'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}