import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_event.dart';
import 'package:hams/presentation/blocs/auth/auth_state.dart';
import 'package:hams/presentation/routes/app_routes.dart';
import 'package:hams/presentation/screens/rooms/vibe_rooms_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _logout() async {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(
              context, AppRoutes.LoginRegisterScreens);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (state is! AuthAuthenticated) {
            return const Scaffold(
              body: Center(child: Text('لا توجد جلسة مستخدم نشطة')),
            );
          }

          final user = state.user;
          final displayName =
              user.username.isNotEmpty ? user.username : 'مستخدم';
          final userTag = user.userId.isNotEmpty ? '#${user.userId}' : '#ID';
          final imagePath = user.profileImagePath;

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0F0F1A),
                        Color(0xFF1C1C2D),
                        Color(0xFF000000),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(color: Colors.black.withOpacity(0.25)),
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage: imagePath.isNotEmpty
                                ? (imagePath.startsWith('http')
                                    ? NetworkImage(imagePath)
                                    : Image.file(File(imagePath)).image)
                                : const AssetImage('assets/user_placeholder.png')
                                    as ImageProvider,
                            backgroundColor: Colors.white10,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            displayName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userTag,
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 30),
                          _buildActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: 'غرف المحادثة',
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const VibeRoomsFullScreen())),
                          ),
                          const SizedBox(height: 15),
                          _buildActionButton(
                            icon: Icons.security_rounded,
                            label: 'الإعدادات',
                            onPressed: () {},
                          ),
                          const SizedBox(height: 15),
                          _buildActionButton(
                            icon: Icons.logout_rounded,
                            label: 'تسجيل الخروج',
                            onPressed: _logout,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.white12,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
