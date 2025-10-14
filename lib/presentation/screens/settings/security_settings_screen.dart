import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool biometricEnabled = false;

  Future<void> _checkBiometrics() async {
    final available = await auth.canCheckBiometrics;
    final supported = await auth.isDeviceSupported();
    final biometrics = await auth.getAvailableBiometrics();

    setState(() {
      biometricEnabled = available && supported && biometrics.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إعدادات الأمان")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text("استخدام البصمة"),
              trailing: Switch(
                value: biometricEnabled,
                onChanged: (val) async {
                  if (val) {
                    final success = await auth.authenticate(
                      localizedReason: "تفعيل البصمة",
                      options: const AuthenticationOptions(biometricOnly: true),
                    );
                    if (success) {
                      setState(() => biometricEnabled = true);
                    }
                  } else {
                    setState(() => biometricEnabled = false);
                  }
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text("حذف الحساب نهائيًا"),
              onTap: () {
                // مستقبلاً: تنفيذ حذف الحساب من SQLite
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("سيتم تنفيذ لاحقًا")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
