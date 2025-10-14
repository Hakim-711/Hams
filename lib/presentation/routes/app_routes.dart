// import 'package:flutter/material.dart';
// import '../screens/dashboard/admin_dashboard.dart';
// import '../screens/dashboard/manage_users.dart';

// class AppRouter {
//   static Route<dynamic> generate(RouteSettings settings) {
//     switch (settings.name) {
//       case '/login':
//         // return MaterialPageRoute(builder: (_) => LoginScreen());
//       case '/admin':
//         return MaterialPageRoute(builder: (_) =>  AdminDashboard());
//       case '/manage-users':
//         return MaterialPageRoute(builder: (_) => const ManageUsersScreen());
//       default:
//         return MaterialPageRoute(
//             builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))));
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:hams/data/local/models/room_model.dart';
import 'package:hams/presentation/screens/auth/login_register.dart'
    show LoginRegisterScreen;
import 'package:hams/presentation/screens/profile/user_profile_screen.dart';
import 'package:hams/presentation/screens/rooms/vibe_rooms_screen.dart';
import 'package:hams/presentation/screens/settings/general_settings_screen.dart';
import 'package:hams/presentation/screens/settings/security_settings_screen.dart';
import 'package:hams/presentation/screens/splash/splash_logic_router.dart';
import '../screens/chat/chat_screen.dart' show ChatScreen;
import '../screens/rooms/vibe_chat_screen.dart' show VibeChatScreen;
import '../screens/dashboard/home_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String chat = '/chat';
  static const String home = '/home';
  static const String vibeRooms = '/vibe-rooms'; // لاحقًا
  static const String adminDashboard = '/admin-dashboard'; // لاحقًا
  static const String manageUsers = '/manage-users'; // لاحقًا
  static const String settings = '/settings'; // لاحقًا
  static const String about = '/about'; // لاحقًا
  static const String privacyPolicy = '/privacy-policy'; // لاحقًا
  static const String termsOfService = '/terms-of-service'; // لاحقًا
  static const String feedback = '/feedback'; // لاحقًا
  static const String support = '/support'; // لاحقًا
  static const String notifications = '/notifications'; // لاحقًا
  static const String chatSettings = '/chat-settings'; // لاحقًا
  static const String accountSettings = '/account-settings'; // لاحقًا
  static const String securitySettings = '/security-settings'; // لاحقًا
  static const String languageSettings = '/language-settings'; // لاحقًا
  static const String themeSettings = '/theme-settings'; // لاحقًا
  static const String dataUsageSettings = '/data-usage-settings'; // لاحقًا
  static const String backupSettings = '/backup-settings'; // لاحقًا
  static const String help = '/help'; // لاحقًا
  static const String contactUs = '/contact-us'; // لاحقًا
  static const String logout = '/logout'; // لاحقًا
  static const String deleteAccount = '/delete-account'; // لاحقًا
  static const String termsAndConditions = '/terms-and-conditions'; // لاحقًا
  static const String userProfile = '/user-profile'; // لاحقًا
  static const String vibeChat = '/vibe-chat'; // لاحقًا
  static const String secureRegister = '/secure-register';
  static const String secureLogin = '/secure-login';
  static const String generalSettings = '/general-settings';
  static const String LoginRegisterScreens = '/LoginRegister';
  static const String splashLogic = '/splash-logic-router';
  static final Map<String, WidgetBuilder> all = {
    
    securitySettings: (context) => const SecuritySettingsScreen(),
    userProfile: (context) => const UserProfileScreen(), // لاحقًا
    splash: (context) => const SplashScreen(),
    generalSettings: (context) => const GeneralSettingsScreen(),
    splashLogic: (context) => const SplashLogicRouter(),
    chat: (context) {
      final room = ModalRoute.of(context)!.settings.arguments as RoomModel;
      return ChatScreen(room: room);
    },
    home: (context) => const HomeScreen(), // لاحقًا
    vibeRooms: (context) => const VibeRoomsFullScreen(), // لاحقًا
    vibeChat: (context) => const VibeChatScreen(
          roomName: 'Hakim',
          themeColor: Color.fromARGB(223, 124, 29, 90),
        ), // لاحقًا
    // secureLogin: (context) => const SecureLoginScreen(),
    LoginRegisterScreens: (context) => const LoginRegisterScreen(),
  };
}
