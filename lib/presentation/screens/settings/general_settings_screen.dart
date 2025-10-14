import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hams/presentation/blocs/theme/theme_bloc.dart';
import 'package:hams/presentation/blocs/theme/theme_event.dart';
import 'package:hams/presentation/screens/settings/account_settings_screen.dart'; // 👈 إضافة

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("الإعدادات العامة"),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // ✅ قسم الحساب
          _buildSectionTitle("الحساب"),
          _buildTile(
            icon: Icons.person,
            title: "إعدادات الحساب",
            subtitle: "الملف الشخصي، حذف الحساب، تسجيل الخروج",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
              );
            },
          ),

          _buildSectionTitle("المظهر"),
          _buildThemeTile(context), // 🎨 الثيم

          _buildSectionTitle("اللغة"),
          _buildTile(
            icon: Icons.language,
            title: "تغيير اللغة",
            subtitle: "العربية / English",
            onTap: () {
               

            },
          ),

          _buildSectionTitle("النظام"),
          _buildTile(
            icon: Icons.storage,
            title: "إدارة التخزين",
            subtitle: "تنظيف الرسائل القديمة",
            onTap: () {
              // TODO: Navigate to Storage Management
            },
          ),

          _buildSectionTitle("حول التطبيق"),
          _buildTile(
            icon: Icons.share,
            title: "مشاركة التطبيق",
            onTap: () {
              Share.share('حمّل تطبيق همس: https://hams.app/download');
            },
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: "حول همس",
            subtitle: "الإصدار 1.0.0",
            onTap: () {
              // TODO: Show About Dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.white54))
          : null,
      onTap: onTap,
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final themeBloc = context.watch<ThemeBloc>();
    final mode = themeBloc.state.mode;

    AppThemeMode current = AppThemeMode.system;
    if (mode == ThemeMode.light) current = AppThemeMode.light;
    if (mode == ThemeMode.dark) current = AppThemeMode.dark;

    return ListTile(
      leading: const Icon(Icons.palette, color: Colors.white70),
      title: const Text("اختيار الثيم", style: TextStyle(color: Colors.white)),
      subtitle:
          const Text("فاتح - داكن - تلقائي", style: TextStyle(color: Colors.white54)),
      trailing: DropdownButton<AppThemeMode>(
        dropdownColor: Colors.grey[900],
        value: current,
        onChanged: (newMode) {
          if (newMode != null) {
            context.read<ThemeBloc>().add(ChangeTheme(newMode));
          }
        },
        items: const [
          DropdownMenuItem(
            value: AppThemeMode.system,
            child: Text('النظام'),
          ),
          DropdownMenuItem(
            value: AppThemeMode.light,
            child: Text('فاتح'),
          ),
          DropdownMenuItem(
            value: AppThemeMode.dark,
            child: Text('داكن'),
          ),
        ],
      ),
    );
  }
}