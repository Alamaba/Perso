import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Services
import 'services/auth_service.dart';
import 'services/local_storage_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'services/export_service.dart';
import 'services/security_service.dart';

// Controllers
import 'controllers/debt_credit_controller.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/settings_screen.dart';

// Models
import 'models/debt_credit_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialiser Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialisé avec succès');

    // Initialiser Hive
    await Hive.initFlutter();
    print('✅ Hive initialisé avec succès');

    // Initialiser les services
    await _initializeServices();

    runApp(MyApp());
  } catch (e) {
    print('❌ Erreur d\'initialisation: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> _initializeServices() async {
  try {
    // Services de base (ordre important)
    Get.put(AuthService(), permanent: true);

    // Initialiser LocalStorageService avec sa méthode init()
    final localStorage = LocalStorageService();
    await localStorage.init();
    Get.put(localStorage, permanent: true);

    Get.put(FirestoreService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(ExportService(), permanent: true);
    Get.put(SecurityService(), permanent: true);

    // Contrôleurs (après que tous les services soient initialisés)
    Get.put(DebtCreditController(), permanent: true);

    print('✅ Services GetX initialisés avec succès');
  } catch (e) {
    print('❌ Erreur d\'initialisation des services: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gestion de Dettes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue.shade700,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade700,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
        ),
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/auth', page: () => const AuthScreen()),
        GetPage(
            name: '/pin-setup',
            page: () => const PinSetupScreen(isFirstSetup: true)),
        GetPage(name: '/settings', page: () => SettingsScreen()),
      ],
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('fr', 'FR'),
      unknownRoute: GetPage(
        name: '/notfound',
        page: () =>
            const Scaffold(body: Center(child: Text('Page non trouvée'))),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erreur d\'initialisation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    main();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
