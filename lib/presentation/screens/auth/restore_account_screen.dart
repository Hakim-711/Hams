// 📁 lib/presentation/screens/auth/restore_account_screen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hams/core/network/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RestoreAccountScreen extends StatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  State<RestoreAccountScreen> createState() => _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends State<RestoreAccountScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();
  bool isLoading = false;

  Future<void> restoreAccount() async {
    if (_usernameController.text.isEmpty || _passcodeController.text.isEmpty) {
      _showError("يرجى تعبئة جميع الحقول");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.post('auth/restore', data: {
        'username': _usernameController.text.trim(),
        'passcode': _passcodeController.text.trim(),
      });

      bool authenticated = await auth.authenticate(
        localizedReason: 'الرجاء التحقق بالبصمة لاستعادة الحساب',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (!authenticated) {
        _showError("فشلت المصادقة بالبصمة");
        return;
      }

      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(
        key: 'userId',
        value: result['userId'],
      );

      context.read<AuthBloc>().add(AuthLoginRequested(
          result['userId'], _passcodeController.text.trim()));
    } catch (e) {
      _showError('فشل الاستعادة: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
              onPressed: restoreAccount,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('استعادة الحساب'),
            ),
          ],
        ),
      ),
    );
  }
}
