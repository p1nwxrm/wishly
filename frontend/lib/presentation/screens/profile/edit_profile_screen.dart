import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_models.dart';
import '../../blocs/user/user_bloc.dart';
import '../../widgets/common/app_snackbars.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/common/button_loading_indicator.dart';
import '../../widgets/photo/avatar_picker.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget {
  final UserBaseModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameFieldKey = GlobalKey<FormFieldState<String>>();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();

  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;

  late final FocusNode _usernameFocusNode;
  late final FocusNode _nameFocusNode;

  File? _selectedAvatar;

  static const Set<String> _reservedUsernames = {
    'me',
    'search',
    'admin',
    'api',
    'root',
    'system',
    'wishlists',
    'gifts',
  };

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initFocusNodes();
  }

  @override
  void dispose() {
    _disposeFocusNodes();
    _disposeControllers();
    super.dispose();
  }

  void _initControllers() {
    _usernameController = TextEditingController(text: widget.user.username);
    _nameController = TextEditingController(text: widget.user.name);

    _usernameController.addListener(_onFormChanged);
    _nameController.addListener(_onFormChanged);
  }

  void _disposeControllers() {
    _usernameController.removeListener(_onFormChanged);
    _nameController.removeListener(_onFormChanged);

    _usernameController.dispose();
    _nameController.dispose();
  }

  void _initFocusNodes() {
    _usernameFocusNode = FocusNode();
    _nameFocusNode = FocusNode();

    _usernameFocusNode.addListener(_onUsernameFocusChanged);
    _nameFocusNode.addListener(_onNameFocusChanged);
  }

  void _disposeFocusNodes() {
    _usernameFocusNode.removeListener(_onUsernameFocusChanged);
    _nameFocusNode.removeListener(_onNameFocusChanged);

    _usernameFocusNode.dispose();
    _nameFocusNode.dispose();
  }

  void _onUsernameFocusChanged() {
    if (!_usernameFocusNode.hasFocus) {
      _usernameFieldKey.currentState?.validate();
    }
  }

  void _onNameFocusChanged() {
    if (!_nameFocusNode.hasFocus) {
      _nameFieldKey.currentState?.validate();
    }
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _pickAvatar() async {
    final pickedImage = await ImagePickerHelper.pickImageFromGallery(context);

    if (pickedImage == null || !mounted) return;

    setState(() {
      _selectedAvatar = pickedImage;
    });
  }

  bool _hasChanges() {
    final usernameChanged =
        _usernameController.text.trim() != widget.user.username;
    final nameChanged = _nameController.text.trim() != widget.user.name;
    final avatarChanged = _selectedAvatar != null;

    return usernameChanged || nameChanged || avatarChanged;
  }

  bool _hasEmptyFields() {
    return _usernameController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty;
  }

  bool _canSubmit(bool isLoading) {
    return !isLoading && _hasChanges() && !_hasEmptyFields();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updateModel = UserUpdateModel(
      username: _usernameController.text.trim(),
      name: _nameController.text.trim(),
    );

    context.read<UserBloc>().add(
      UpdateCurrentUser(
        updateModel: updateModel,
        avatarFile: _selectedAvatar,
      ),
    );
  }

  void _handleStateChange(BuildContext context, UserState state) {
    if (state is UserActionSuccess) {
      context.router.pop(true);
    } else if (state is UserError) {
      AppSnackbars.showError(context, state.message);
    }
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';

    if (username.isEmpty) {
      return 'Please enter username';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 50) {
      return 'Username must be no more than 50 characters';
    }

    final regex = RegExp(r'^[a-z0-9_]+$');
    if (!regex.hasMatch(username)) {
      return 'Use only lowercase letters, numbers and underscore';
    }

    if (_reservedUsernames.contains(username)) {
      return 'This username is reserved by the system';
    }

    return null;
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter name';
    }

    if (name.length > 100) {
      return 'Name must be no more than 100 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<UserBloc, UserState>(
      listener: _handleStateChange,
      builder: (context, state) {
        final isLoading = state is UserLoading;
        final canSubmit = _canSubmit(isLoading);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit profile'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: AvatarPicker(
                        localImage: _selectedAvatar,
                        imageUrl: widget.user.photoUrl,
                        isLoading: isLoading,
                        onTap: _pickAvatar,
                      ),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      key: _usernameFieldKey,
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter username',
                      ),
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      key: _nameFieldKey,
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter display name',
                      ),
                      validator: _validateName,
                      onFieldSubmitted: (_) {
                        if (canSubmit) {
                          _submit();
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: canSubmit ? _submit : null,
                      child: isLoading
                          ? const ButtonLoadingIndicator()
                          : const Text('Save changes'),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Username may contain lowercase letters,\nnumbers and underscore only.',
                      maxLines: 2,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}