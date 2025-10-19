// 📁 lib/presentation/screens/auth/login_register_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:hams/core/storage/session_manager.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../../domain/entities/user_entity.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool isLogin = true;
  bool isLoading = true; // ← يبدأ true للفحص التلقائي

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    autoLoginIfAvailable(); // ← تشغيل الفحص التلقائي
  }

  Future<void> autoLoginIfAvailable() async {
    try {
      final userId = await SessionManager.getBiometricUserId();

      if (userId != null) {
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'سجّل دخولك بالبصمة',
          options: const AuthenticationOptions(biometricOnly: true),
        );

        if (didAuthenticate) {
          if (!mounted) return;
          context.read<AuthBloc>().add(AuthCheckSession());
          return;
        }
      }
    } catch (e) {
      debugPrint('فشل الدخول التلقائي: $e');
    }

    // إذا لم يتم تسجيل الدخول تلقائيًا → أظهر الشاشة
    if (mounted) setState(() => isLoading = false);
  }

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      isLogin ? _controller.reverse() : _controller.forward();
    });
  }

  Future<void> authenticate() async {
    if (_usernameController.text.trim().isEmpty ||
        _passcodeController.text.trim().isEmpty) {
      showError("يرجى تعبئة كافة الحقول");
      return;
    }

    setState(() => isLoading = true);

    bool authenticated = await auth.authenticate(
      localizedReason: 'الرجاء التحقق بالبصمة',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (!mounted) return;

    if (authenticated) {
      isLogin ? await loginUser() : await registerUser();
    } else {
      showError("فشلت المصادقة");
      setState(() => isLoading = false);
    }
  }

  Future<void> registerUser() async {
    final userId = const Uuid().v4();
    final user = UserEntity(
      userId: userId,
      username: _usernameController.text.trim(),
      passcode: _passcodeController.text.trim(),
      profileImagePath: '',
      createdAt: DateTime.now(),
    );

    context.read<AuthBloc>().add(AuthRegisterRequested(user));
  }

  Future<void> loginUser() async {
    final userId = _usernameController.text.trim();
    final passcode = _passcodeController.text.trim();

    context.read<AuthBloc>().add(AuthLoginRequested(userId, passcode));
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          if (mounted) {
            setState(() => isLoading = true);
          }
        } else {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            showError(state.message);
          }
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
      },
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLogin
                            ? [Colors.blueAccent, Colors.deepPurpleAccent]
                            : [Colors.orangeAccent, Colors.deepOrangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: Text(
                              isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                              key: ValueKey<bool>(isLogin),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                TextField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'اسم المستخدم',
                                    filled: true,
                                    fillColor: Colors.white24,
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _passcodeController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'رمز الدخول (للاستعادة)',
                                    filled: true,
                                    fillColor: Colors.white24,
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: authenticate,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [Colors.white70, Colors.white24],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 10,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.fingerprint,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: authenticate,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(
                                    isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: toggleMode,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                isLogin
                                    ? 'لا تملك حساب؟ أنشئ واحدًا'
                                    : 'لديك حساب؟ سجل الدخول',
                                key: ValueKey<bool>(!isLogin),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
