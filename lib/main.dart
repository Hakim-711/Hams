import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hams/core/theme/app_theme.dart';
import 'package:hams/presentation/blocs/auth/auth_bloc.dart';
import 'package:hams/presentation/blocs/auth/auth_event.dart';
import 'package:hams/presentation/routes/app_routes.dart';

void main() {
  runApp(const HamsApp());
}

class HamsApp extends StatelessWidget {
  const HamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AuthCheckSession()),
        ),
      ],
      child: MaterialApp(
        title: 'همس Hams',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme, // أو lightTheme حسب الإعدادات
        initialRoute: AppRoutes.splashLogic,
        routes: AppRoutes.all,
      ),
    );
  }
}