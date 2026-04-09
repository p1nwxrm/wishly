import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_models.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../utils/app_snackbars.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/avatar/avatar_picker.dart';
import '../../widgets/common/button_loading_indicator.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../core/di/injection.dart';

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
  File? _selectedImage;
  // Instance of ImagePicker to access device gallery
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image slightly for better performance
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e, st) {
      getIt<Talker>().handle(e, st, 'Error picking image from gallery');

      if (mounted) {
        AppSnackbars.showError(context, 'Failed to pick image');
      }
    }
  }

  // Handle the final registration step
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
          photoFile: _selectedImage, // Pass the selected file if any
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Sign Up - Step 2',
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to main feed on successful registration and login
            context.router.replaceAll([const RootRoute()]);
          } else if (state is AuthFailure) {
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
                          localImage: _selectedImage,
                          imageUrl: null,
                          isLoading: isLoading,
                          onTap: _pickImage,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
                          if (!validCharacters.hasMatch(value)) {
                            return 'Use only Latin letters, numbers, and _';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
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