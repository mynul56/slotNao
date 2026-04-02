import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> extra;
  const PaymentPage({super.key, required this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.dark800,
      ),
      body: const Center(
        child: Text(
          'Payment gateway integration coming soon.\n\nbKash / Nagad SDK will be integrated here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.neutralGrey, fontSize: 15, height: 1.6),
        ),
      ),
    );
  }
}
