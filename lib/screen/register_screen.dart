import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/state_card.dart';
import 'login_screen.dart' show AuthUiState;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  AuthUiState _state = AuthUiState.idle;
  bool _showAccounts = false; // false = Register tab, true = Accounts tab

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_state == AuthUiState.loading) return; // prevent duplicates
    if (!_formKey.currentState!.validate()) return;

    setState(() => _state = AuthUiState.loading);
    final ok = await AuthService.register(
        _nameCtrl.text, _emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _state = ok ? AuthUiState.success : AuthUiState.error);
  }

  void _backToForm() => setState(() => _state = AuthUiState.idle);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: false,
                        label: Text('Register'),
                        icon: Icon(Icons.person_add)),
                    ButtonSegment(
                        value: true,
                        label: Text('Accounts'),
                        icon: Icon(Icons.people)),
                  ],
                  selected: {_showAccounts},
                  onSelectionChanged: (s) =>
                      setState(() => _showAccounts = s.first),
                ),
                const SizedBox(height: 16),
                _showAccounts ? _accountsView() : _buildBody(),
              ],
            ),
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
          title: 'Account Created',
          message: 'Your account was created (simulated, not saved to a database).',
          note: 'SUCCESS: confirms the result and gives a next step.',
          actions: [
            AppButton(
              label: 'Go to Login',
              icon: Icons.login,
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        );
      case AuthUiState.error:
        return StateCard(
          icon: Icons.error,
          color: Colors.red,
          title: 'Registration Failed',
          message: 'This email is already registered. Use another email or login.',
          note: 'ERROR: explains the failure and provides Retry or correction.',
          actions: [
            AppButton(
              label: 'Change Email',
              icon: Icons.edit,
              onPressed: _backToForm,
            ),
            AppButton(
              label: 'Go to Login',
              outlined: true,
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
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
            label: 'Full Name',
            controller: _nameCtrl,
            enabled: !loading,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
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
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Confirm Password',
            controller: _confirmCtrl,
            obscureText: true,
            enabled: !loading,
            validator: (v) =>
                v != _passCtrl.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Create Account',
            icon: Icons.person_add,
            isLoading: loading,
            onPressed: _register,
          ),
          if (loading) ...[
            const SizedBox(height: 12),
            const StateCard(
              loading: true,
              color: Colors.blue,
              title: 'Creating account...',
              message: 'Please wait while we set up your account (simulated).',
              note: 'LOADING: shows progress and blocks duplicate actions.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _accountsView() {
    final users = AuthService.users;
    if (users.isEmpty) {
      return StateCard(
        icon: Icons.group_off,
        color: Colors.orange,
        title: 'No Accounts Yet',
        message: 'No account has been registered so far.',
        note: 'EMPTY: no data exists. This is not an error; offer an action.',
        actions: [
          AppButton(
            label: 'Create an Account',
            icon: Icons.add,
            onPressed: () => setState(() => _showAccounts = false),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final u in users)
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(u.name),
              subtitle: Text(u.email),
            ),
          ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Clear All Accounts',
          outlined: true,
          icon: Icons.delete_outline,
          onPressed: () => setState(() => AuthService.users.clear()),
        ),
      ],
    );
  }
}