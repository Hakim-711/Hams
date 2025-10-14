import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hams/presentation/routes/app_routes.dart';
import 'package:hams/presentation/screens/splash/splash_screen.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class SplashLogicRouter extends StatefulWidget {
  const SplashLogicRouter({super.key});

  @override
  State<SplashLogicRouter> createState() => _SplashLogicRouterState();
}

class _SplashLogicRouterState extends State<SplashLogicRouter> {
  @override
  void initState() {
    super.initState();

    // التحقق من الجلسة (سيتم معالجتها داخل Bloc)
    context.read<AuthBloc>().add(AuthCheckSession());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          // اجعل شاشة Splash تظهر على الأقل 2 ثانية
          return const SplashScreen();
        } else if (state is AuthAuthenticated) {
          // تأخير الانتقال بعد Splash
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          });
          return const SplashScreen();
        } else {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pushReplacementNamed(
                context, AppRoutes.LoginRegisterScreens);
          });
          return const SplashScreen();
        }
      },
    );
  }
}
