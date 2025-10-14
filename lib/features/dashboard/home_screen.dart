import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hams/presentation/screens/auth/login_register.dart';
import 'package:hams/presentation/screens/rooms/vibe_rooms_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _username;
  String? _userID;
  String? _imagePath;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'مستخدم';
      _userID = prefs.getString('userID') ?? 'ID';
      _imagePath = prefs.getString('userImagePath');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginRegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
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
          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
          // Main content
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
                      backgroundImage: _imagePath != null
                          ? Image.file(File(_imagePath!)).image
                          : const AssetImage('assets/user_placeholder.png')
                              as ImageProvider,
                      backgroundColor: Colors.white10,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _username ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#$_userID',
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
