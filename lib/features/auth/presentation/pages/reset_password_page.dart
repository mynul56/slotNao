import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/responsive/app_responsive.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/input_field.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? email;
  const ResetPasswordPage({super.key, this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthResetPasswordRequested(
        email: _emailCtrl.text.trim(),
        token: _otpCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppResponsive.horizontalPadding(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successfully! Please login.')));
          context.go(AppRoutes.login);
        }
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.dark900,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: AppResponsive.scaleText(context, 28),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the OTP sent to your email and your new password.',
                      style: TextStyle(fontSize: AppResponsive.scaleText(context, 15), color: AppTheme.neutralGrey),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.dark700.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.dark500),
                      ),
                      child: Column(
                        children: [
                          InputField(
                            controller: _emailCtrl,
                            label: 'Email Address',
                            hint: 'you@example.com',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: widget.email != null && widget.email!.isNotEmpty,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Email is required';
                              if (!val.trim().isValidEmail) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            controller: _otpCtrl,
                            label: 'OTP Code',
                            hint: '6-digit OTP',
                            icon: Icons.sms_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'OTP is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          InputField(
                            controller: _passwordCtrl,
                            label: 'New Password',
                            hint: '••••••••',
                            icon: Icons.lock_rounded,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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
                            label: 'Confirm New Password',
                            hint: '••••••••',
                            icon: Icons.lock_rounded,
                            obscureText: _obscurePassword,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Please confirm your password';
                              if (val != _passwordCtrl.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                onPressed: state is AuthLoading ? null : _onResetPassword,
                                label: 'Change Password',
                                icon: Icons.check_circle_rounded,
                                isLoading: state is AuthLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
