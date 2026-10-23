import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/state_card.dart';

enum AuthUiState { idle, loading, success, empty, error }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  AuthUiState _state = AuthUiState.idle;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_state == AuthUiState.loading) return; // prevent duplicates
    if (!_formKey.currentState!.validate()) return;

    setState(() => _state = AuthUiState.loading);
    final result = await AuthService.login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;

    setState(() {
      switch (result) {
        case AuthResult.success:
          _state = AuthUiState.success;
        case AuthResult.noAccount:
          _state = AuthUiState.empty;
        case AuthResult.wrongPassword:
          _state = AuthUiState.error;
      }
    });
  }

  void _backToForm() => setState(() => _state = AuthUiState.idle);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case AuthUiState.success:
        return StateCard(
          icon: Icons.check_circle,
          color: Colors.green,
          title: 'Login Successful',
          message: 'Welcome back, ${AuthService.currentUser?.name ?? 'user'}!',
          note: 'SUCCESS: confirms the result and gives a next step.',
          actions: [
            AppButton(
              label: 'Go to Home',
              icon: Icons.home,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false),
            ),
          ],
        );
      case AuthUiState.empty:
        return StateCard(
          icon: Icons.person_search,
          color: Colors.orange,
          title: 'No Account Found',
          message: 'There is no account registered with this email yet.',
          note: 'EMPTY: no data matches. This is not an error; offer an action.',
          actions: [
            AppButton(
              label: 'Create an Account',
              icon: Icons.person_add,
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
            AppButton(
              label: 'Try Another Email',
              outlined: true,
              onPressed: _backToForm,
            ),
          ],
        );
      case AuthUiState.error:
        return StateCard(
          icon: Icons.error,
          color: Colors.red,
          title: 'Login Failed',
          message: 'Incorrect password. Please check your details and try again.',
          note: 'ERROR: explains the failure and provides Retry or correction.',
          actions: [
            AppButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: () {
                setState(() => _state = AuthUiState.idle);
                // wait one frame so the Form is mounted again
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _login());
              },
            ),
            AppButton(
              label: 'Edit Details',
              outlined: true,
              onPressed: _backToForm,
            ),
          ],
        );
      default:
        return _formView(); // idle + loading
    }
  }

  Widget _formView() {
    final loading = _state == AuthUiState.loading;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email',
            controller: _emailCtrl,
            enabled: !loading,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Password',
            controller: _passCtrl,
            obscureText: true,
            enabled: !loading,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Login',
            icon: Icons.login,
            isLoading: loading,
            onPressed: _login,
          ),
          if (!loading)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('No account yet? Register'),
            ),
          if (loading) ...[
            const SizedBox(height: 12),
            const StateCard(
              loading: true,
              color: Colors.blue,
              title: 'Signing in...',
              message: 'Please wait while we verify your account (simulated).',
              note: 'LOADING: shows progress and blocks duplicate actions.',
            ),
          ],
        ],
      ),
    );
  }
}