import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/demo_media.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/input_field.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneCtrl.text.trim();
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameCtrl.text.trim(),
        phone: phone.isEmpty ? null : phone,
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful. Please verify your email.')));
          context.push(AppRoutes.verifyOtp, extra: _emailCtrl.text.trim());
        }
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.dark900,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(CupertinoIcons.back), onPressed: () => context.pop()),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(imageUrl: DemoMedia.turfImages[1], fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.dark900.withValues(alpha: 0.35), AppTheme.dark900.withValues(alpha: 0.96)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join SlotNao — book turfs instantly',
                        style: TextStyle(fontSize: 15, color: AppTheme.neutralGrey),
                      ),
                      const SizedBox(height: 36),
                      InputField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'John Doe',
                        icon: CupertinoIcons.person_fill,
                        validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _phoneCtrl,
                        label: 'Phone Number (optional)',
                        hint: '01XXXXXXXXX',
                        icon: CupertinoIcons.phone_fill,
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty && !val.trim().isValidBangladeshPhone) {
                            return 'Enter valid BD number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: CupertinoIcons.mail_solid,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!val.trim().isValidEmail) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        hint: '••••••••',
                        icon: CupertinoIcons.lock_fill,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                            color: AppTheme.neutralGrey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password is required';
                          if (!val.isValidPassword) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: _confirmPasswordCtrl,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        icon: CupertinoIcons.lock,
                        obscureText: _obscurePassword,
                        validator: (val) {
                          if (val != _passwordCtrl.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return CustomButton(
                            onPressed: state is AuthLoading ? null : _onRegister,
                            label: 'Create Account',
                            icon: CupertinoIcons.paperplane_fill,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Already have an account? ', style: TextStyle(color: AppTheme.neutralGrey)),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
