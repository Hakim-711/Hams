import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_event.dart';
import 'package:hams/presentation/blocs/auth/auth_state.dart';
import 'package:hams/presentation/routes/app_routes.dart';
import '../../../domain/entities/user_entity.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _buildHome(context, state.user);
        }
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildHome(BuildContext context, UserEntity user) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("همس"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 50,
              backgroundImage: user.profileImagePath.isNotEmpty
                  ? Image.file(File(user.profileImagePath)).image
                  : const AssetImage('assets/user_placeholder.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              'أهلًا، ${user.username}',
              style: const TextStyle(fontSize: 26, color: Colors.white),
            ),
            const SizedBox(height: 40),
            _buildActionButton(
              context,
              icon: Icons.group,
              label: "الانتقال إلى غرف الهمس",
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.vibeRooms);
              },
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              icon: Icons.person_outline,
              label: "الملف الشخصي",
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.userProfile);
              },
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              icon: Icons.settings_outlined,
              label: "الإعدادات العامة",
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.LoginRegisterScreens,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("تسجيل الخروج"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white10,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
