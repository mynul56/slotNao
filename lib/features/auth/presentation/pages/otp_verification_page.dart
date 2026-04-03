import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/responsive/app_responsive.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/input_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthVerifyOtpRequested(email: widget.email, otp: _otpCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppResponsive.horizontalPadding(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account verified successfully!')));
          context.go(AppRoutes.login);
        } else if (state is AuthFailureState) {
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
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: AppResponsive.scaleText(context, 28),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: AppResponsive.scaleText(context, 15), color: AppTheme.neutralGrey),
                        children: [
                          const TextSpan(text: 'We sent a 6-digit verification code to '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: '. Enter it below to activate your account.'),
                        ],
                      ),
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
                            controller: _otpCtrl,
                            label: 'Verification Code',
                            hint: '123456',
                            icon: Icons.verified_user_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Code is required';
                              }
                              final normalized = val.trim();
                              if (normalized.length != 6 || int.tryParse(normalized) == null)
                                return 'Enter a valid 6-digit code';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                onPressed: state is AuthLoading ? null : _onVerify,
                                label: 'Verify Account',
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
