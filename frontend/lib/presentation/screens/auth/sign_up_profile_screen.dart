import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_models.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/app_snackbars.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/photo/avatar_picker.dart';
import '../../widgets/common/button_loading_indicator.dart';

@RoutePage()
class SignUpProfileScreen extends StatefulWidget {
  final String email;
  final String password;

  const SignUpProfileScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<SignUpProfileScreen> createState() => _SignUpProfileScreenState();
}

class _SignUpProfileScreenState extends State<SignUpProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  // Variable to store the selected profile photo
  File? _selectedPhoto;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Actions & Callbacks
  // --------------------------------------------------------------------------

  /// Handles picking a profile photo from the device gallery
  Future<void> _pickPhoto() async {
    final file = await ImagePickerHelper.pickImageFromGallery(context);
    if (file != null) {
      setState(() {
        _selectedPhoto = file;
      });
    }
  }

  /// Handles the final registration step
  void _onCompleteRegistration() {
    if (_formKey.currentState?.validate() ?? false) {
      // Create the user model using data from both Step 1 and Step 2
      final userModel = UserCreateModel(
        email: widget.email, // Passed from previous screen
        password: widget.password, // Passed from previous screen
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
      );

      // Dispatch registration event to the bloc
      context.read<AuthBloc>().add(
        RegisterRequested(
          userModel: userModel,
          avatarFile: _selectedPhoto,
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // Validators
  // --------------------------------------------------------------------------

  /// Validates the username input
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validCharacters.hasMatch(value)) {
      return 'Use only Latin letters, numbers, and _';
    }
    return null;
  }

  /// Validates the display name input
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // Build Method
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up - Step 2'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            AppSnackbars.showError(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Set Up Your Profile',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Avatar Picker Widget
                      Center(
                        child: AvatarPicker(
                          localImage: _selectedPhoto,
                          imageUrl: null,
                          isLoading: isLoading,
                          onTap: _pickPhoto,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Username input field
                      TextFormField(
                        controller: _usernameController,
                        enabled: !isLoading,
                        // Force lowercase for username convention
                        textCapitalization: TextCapitalization.none,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'e.g., cool_user_123',
                          // Helper text guides the user
                          helperText: 'Only Latin letters, numbers, and underscores',
                        ),
                        validator: _validateUsername,
                      ),
                      const SizedBox(height: 16),

                      // Display Name input field
                      TextFormField(
                        controller: _nameController,
                        enabled: !isLoading,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your name',
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 32),

                      // Complete Registration button
                      ElevatedButton(
                        onPressed: isLoading ? null : _onCompleteRegistration,
                        child: isLoading
                            ? const ButtonLoadingIndicator()
                            : const Text('Complete Registration'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}