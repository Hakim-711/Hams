import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import 'package:hams/core/network/api_service.dart';
import 'package:hams/presentation/blocs/auth/auth_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_event.dart';

class RestoreAccountScreen extends StatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  State<RestoreAccountScreen> createState() => _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends State<RestoreAccountScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();

  bool _isLoading = false;

  Future<void> _restoreAccount() async {
    final username = _usernameController.text.trim();
    final passcode = _passcodeController.text.trim();

    if (username.isEmpty || passcode.isEmpty) {
      _showError('يرجى تعبئة جميع الحقول');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.post('auth/restore', data: {
        'username': username,
        'passcode': passcode,
      });

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'الرجاء التحقق بالبصمة لاستعادة الحساب',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (!didAuthenticate) {
        _showError('فشلت المصادقة بالبصمة');
        return;
      }

      if (!mounted) return;
      final userId = result['userId'] as String?;
      if (userId == null || userId.isEmpty) {
        _showError('فشل الاستعادة: بيانات المستخدم غير مكتملة');
        return;
      }

      context.read<AuthBloc>().add(AuthLoginRequested(userId, passcode));
    } catch (e) {
      _showError('فشل الاستعادة: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استعادة الحساب')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passcodeController,
              decoration: const InputDecoration(labelText: 'رمز الدخول'),
              obscureText: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _restoreAccount,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('استعادة الحساب'),
            ),
          ],
        ),
      ),
    );
  }
}
