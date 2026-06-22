import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/booking_viewmodel.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

/// Application entry point.
/// Initializes Firebase, sets up Provider state management, and launches the app.

Future<void> main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Set preferred orientations (portrait only for better UX on mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SportHubApp());
}

/// Root application widget.
/// Configures theme, providers, and the authentication wrapper.

class SportHubApp extends StatelessWidget {
  const SportHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // AuthViewModel: manages user authentication state (login, register, logout)
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Wrapping the app with AuthWrapper handles automatic navigation
        // based on authentication state (splash -> login -> home)
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Authentication wrapper that manages navigation flow based on auth state.
///
/// Flow:
/// 1. App starts -> SplashScreen (2 second animation)
/// 2. Splash completes -> checks Firebase auth state
///    - If user is logged in -> HomeScreen
///    - If user is not logged in -> LoginScreen

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      // Phase 1: Show splash screen
      return SplashScreen(
        onInitialized: () {
          setState(() => _showSplash = false);
        },
      );
    }

    // Phase 2: Auth-aware navigation
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // While auth state is still being determined, show loading
        if (authViewModel.currentUser == null && !_splashHandledFinal) {
          // First check after splash, give it a moment to load user
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() {});
          });
          _splashHandledFinal = true;
        }

        if (authViewModel.currentUser != null) {
          // User is authenticated -> Show Home
          return const HomeScreen();
        } else {
          // No user -> Show Login
          return const LoginScreen();
        }
      },
    );
  }

  bool _splashHandledFinal = false;
}

/// Auth-aware home screen that listens to auth state changes
/// and navigates between screens automatically.

class AuthAwareNavigator extends StatefulWidget {
  const AuthAwareNavigator({super.key});

  @override
  State<AuthAwareNavigator> createState() => _AuthAwareNavigatorState();
}

class _AuthAwareNavigatorState extends State<AuthAwareNavigator> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.currentUser != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
