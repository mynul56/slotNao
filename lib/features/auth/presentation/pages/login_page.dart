import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/demo_media.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/responsive/app_responsive.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/input_field.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpRequested = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _onRequestOtp() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRequestOtpRequested(phone: _phoneCtrl.text.trim()));
  }

  void _onVerifyOtp() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(phone: _phoneCtrl.text.trim(), otp: _otpCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    final horizontalPadding = AppResponsive.horizontalPadding(context);
    final headerTopSpacing = isTablet ? 36.0 : 60.0;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go(AppRoutes.roleHub);
        if (state is AuthOtpRequested) {
          setState(() => _otpRequested = true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.dark900,
        body: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(imageUrl: DemoMedia.stadiumImages.last, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.dark900.withValues(alpha: 0.35), AppTheme.dark900.withValues(alpha: 0.95)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardMaxWidth = isTablet ? 560.0 : constraints.maxWidth;
                      final topGap = constraints.maxHeight < 700 ? 20.0 : headerTopSpacing;

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: topGap),
                              _buildHeader(),
                              SizedBox(height: isTablet ? 28 : 24),
                              Container(
                                padding: EdgeInsets.all(isTablet ? 24 : 18),
                                decoration: BoxDecoration(
                                  color: AppTheme.dark700.withValues(alpha: 0.68),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.dark500),
                                ),
                                child: Column(
                                  children: [
                                    InputField(
                                      controller: _phoneCtrl,
                                      label: 'Phone Number',
                                      hint: '01XXXXXXXXX',
                                      icon: Icons.phone_rounded,
                                      keyboardType: TextInputType.phone,
                                      readOnly: _otpRequested,
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Phone is required';
                                        if (!val.isValidBangladeshPhone) {
                                          return 'Enter a valid BD phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    if (_otpRequested)
                                      InputField(
                                        controller: _otpCtrl,
                                        label: 'OTP Code',
                                        hint: '6-digit OTP',
                                        icon: Icons.sms_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (val) {
                                          if (!_otpRequested) return null;
                                          if (val == null || val.trim().isEmpty) return 'OTP is required';
                                          if (!RegExp(r'^\d{6}4').hasMatch(val.trim())) return 'OTP must be 6 digits';
                                          return null;
                                        },
                                      ),
                                    const SizedBox(height: 24),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        return CustomButton(
                                          onPressed: state is AuthLoading ? null : (_otpRequested ? _onVerifyOtp : _onRequestOtp),
                                          label: _otpRequested ? 'Verify OTP & Login' : 'Send OTP',
                                          icon: _otpRequested ? Icons.verified_user_rounded : Icons.send_rounded,
                                          isLoading: state is AuthLoading,
                                        );
                                      },
                                    ),
                                    if (_otpRequested)
                                      TextButton(
                                        onPressed: () {
                                          _otpCtrl.clear();
                                          _onRequestOtp();
                                        },
                                        child: Text(
                                          'Resend OTP',
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontSize: AppResponsive.scaleText(context, 14),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isTablet ? 20 : 24),
                              _buildDivider(),
                              SizedBox(height: isTablet ? 20 : 24),
                              _buildRegisterLink(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)],
          ),
          child: const Icon(Icons.sports_soccer_rounded, color: AppTheme.dark900, size: 30),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back! 👋',
          style: TextStyle(
            fontSize: AppResponsive.scaleText(context, 28),
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in with your phone OTP to book your turf slot',
          style: TextStyle(fontSize: AppResponsive.scaleText(context, 15), color: AppTheme.neutralGrey),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.dark500)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: TextStyle(color: AppTheme.neutralGrey.withValues(alpha: 0.7), fontSize: 13)),
        ),
        const Expanded(child: Divider(color: AppTheme.dark500)),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Don't have an account? ", style: TextStyle(color: AppTheme.neutralGrey)),
          GestureDetector(
            onTap: () => context.push(AppRoutes.register),
            child: const Text(
              'Register',
              style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
