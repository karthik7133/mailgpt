import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/token_service.dart';
import 'utils/routes.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mail_detail_screen.dart';
import 'screens/mail_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await TokenService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MailMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: Routes.splash,
      routes: {
        Routes.splash: (context) => const SplashScreen(),
        Routes.onboarding: (context) => const OnboardingScreen(),
        Routes.login: (context) => const LoginScreen(),
        Routes.home: (context) => const HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.mailDetail) {
          final mail = settings.arguments as dynamic;
          return MaterialPageRoute(
            builder: (context) => MailDetailScreen(mail: mail),
          );
        }
        if (settings.name == Routes.mailChat) {
          final mail = settings.arguments as dynamic;
          return MaterialPageRoute(
            builder: (context) => MailChatScreen(mail: mail),
          );
        }
        return null;
      },
    );
  }
}