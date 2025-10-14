import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_event.dart';
import 'package:hams/presentation/blocs/auth/auth_state.dart';
import 'package:hams/presentation/routes/app_routes.dart';
import 'package:hams/core/network/api_service.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("إعدادات الحساب"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("تسجيل الخروج"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.LoginRegisterScreens,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text("حذف الحساب"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("تأكيد حذف الحساب"),
                    content: const Text(
                        "هل أنت متأكد أنك تريد حذف حسابك؟ سيتم مسح جميع بياناتك."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("إلغاء"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("حذف",
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  final state = context.read<AuthBloc>().state;
                  if (state is AuthAuthenticated) {
                    final userId = state.user.userId;

                    try {
                      await ApiService.delete("auth/$userId");

                      context.read<AuthBloc>().add(AuthLogoutRequested());

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.LoginRegisterScreens,
                        (route) => false,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ تم حذف الحساب والبيانات بنجاح"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("فشل الحذف: $e")),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
