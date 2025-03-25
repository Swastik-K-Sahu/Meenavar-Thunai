import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meenavar_thunai/firebase_options.dart';
import 'package:meenavar_thunai/presentation/viewmodels/maps_viewmodel.dart';
import 'package:provider/provider.dart';
import '../app/routes.dart';
import '../app/locator.dart';
import '../theme/app_themes.dart';
import '/presentation/viewmodels/auth_viewmodel.dart';
import '/presentation/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup service locator
  await setupLocator();

  // Load .env file for API keys
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => MapsViewModel()),
      ],
      child: MaterialApp(
        title: 'Meenavar-Thunai',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        home: const SplashScreen(),
      ),
    );
  }
}
