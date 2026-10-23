import 'package:flutter/material.dart';

import '../widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your System')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: 'Open Login',
              icon: Icons.login,
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Open Register',
              icon: Icons.person_add,
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Open Report Form',
              icon: Icons.report,
              onPressed: () => Navigator.pushNamed(context, '/report'),
            ),
          ],
        ),
      ),
    ),
  );
}