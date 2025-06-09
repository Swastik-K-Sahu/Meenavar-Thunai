import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meenavar_thunai/core/services/hotspot_prediction_service.dart';
import 'package:meenavar_thunai/core/utils/firebase_options.dart';
import 'package:meenavar_thunai/presentation/viewmodels/hotspot_viewmodel.dart';
import 'package:meenavar_thunai/presentation/viewmodels/maps_viewmodel.dart';
import 'package:meenavar_thunai/secrets.dart';
import 'package:provider/provider.dart';
import '../app/routes.dart';
import '../app/locator.dart';
import '../theme/app_themes.dart';
import '/presentation/viewmodels/auth_viewmodel.dart';
import '/presentation/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import '/presentation/viewmodels/fish_catch_viewmodel.dart';
import '/providers/chat_provider.dart';

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
        ChangeNotifierProvider(create: (context) => FishCatchViewModel()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
          create:
              (_) => HotspotViewModel(
                predictionService: HotspotPredictionService(
                  geminiApiKey:
                      AppSecrets.geminiApiKey, // Gemini API key from secrets
                  weatherApiUrl: 'https://api.open-meteo.com/v1/forecast',
                  oceanApiUrl: 'https://marine-api.open-meteo.com/v1/marine',
                ),
              ),
        ),
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
