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
  static const String _demoEmail = 'demo@slotnao.com';
  static const String _demoPassword = 'Demo@12345';

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = _demoEmail;
    _passwordCtrl.text = _demoPassword;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthPasswordLoginRequested(email: _emailCtrl.text.trim(), password: _passwordCtrl.text));
  }

  void _onSocialLogin(String provider) {
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.trim().isValidEmail) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email for social login')));
      return;
    }
    final providerToken = '${provider}_${DateTime.now().millisecondsSinceEpoch}_${_emailCtrl.text.trim().toLowerCase()}';
    context.read<AuthBloc>().add(
      AuthSocialLoginRequested(provider: provider, providerToken: providerToken, email: _emailCtrl.text.trim(), name: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    final horizontalPadding = AppResponsive.horizontalPadding(context);
    final headerTopSpacing = isTablet ? 36.0 : 60.0;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
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
                                      controller: _emailCtrl,
                                      label: 'Email Address',
                                      hint: 'you@example.com',
                                      icon: Icons.email_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) return 'Email is required';
                                        if (!val.trim().isValidEmail) return 'Enter a valid email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    InputField(
                                      controller: _passwordCtrl,
                                      label: 'Password',
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
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.dark600.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.dark500),
                                      ),
                                      child: const Text(
                                        'Demo login: demo@slotnao.com / Demo@12345',
                                        style: TextStyle(color: AppTheme.lightGrey, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => context.push(AppRoutes.forgotPassword),
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontSize: AppResponsive.scaleText(context, 14),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        return CustomButton(
                                          onPressed: state is AuthLoading ? null : _onLogin,
                                          label: 'Login',
                                          icon: Icons.login_rounded,
                                          isLoading: state is AuthLoading,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isTablet ? 20 : 24),
                              _buildDivider(),
                              SizedBox(height: isTablet ? 20 : 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.dark700.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.dark500),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _onSocialLogin('google'),
                                        icon: const Icon(Icons.g_mobiledata_rounded),
                                        label: const Text('Google'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _onSocialLogin('facebook'),
                                        icon: const Icon(Icons.facebook_rounded),
                                        label: const Text('Facebook'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
          'Login with email & password or social',
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
