import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/booking_viewmodel.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'views/map/map_screen.dart';
import 'views/owner/owner_dashboard_screen.dart';
import 'views/owner/owner_court_list_screen.dart';
import 'views/owner/owner_calendar_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'views/admin/admin_court_approval_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

class SportHubApp extends StatelessWidget {
  const SportHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.ownerDashboard:
        return MaterialPageRoute(
          builder: (_) => const OwnerDashboardScreen(),
        );
      case AppRoutes.ownerCourts:
        return MaterialPageRoute(
          builder: (_) => const OwnerCourtListScreen(),
        );
      case AppRoutes.ownerCalendar:
        return MaterialPageRoute(
          builder: (_) => const OwnerCalendarScreen(),
        );
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );
      case AppRoutes.adminApproval:
        return MaterialPageRoute(
          builder: (_) => const AdminCourtApprovalScreen(),
        );
      case AppRoutes.map:
        return MaterialPageRoute(
          builder: (_) => const MapScreen(),
        );
      default:
        return null;
    }
  }
}

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
      return SplashScreen(
        onInitialized: () {
          setState(() => _showSplash = false);
        },
      );
    }

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.currentUser == null && !_splashHandledFinal) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() {});
          });
          _splashHandledFinal = true;
        }

        if (authViewModel.currentUser != null) {
          final user = authViewModel.currentUser!;
          if (user.isOwner) {
            return const OwnerDashboardScreen();
          }
          if (user.isAdmin) {
            return const AdminDashboardScreen();
          }
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  bool _splashHandledFinal = false;
}

class AuthAwareNavigator extends StatefulWidget {
  const AuthAwareNavigator({super.key});

  @override
  State<AuthAwareNavigator> createState() => _AuthAwareNavigatorState();
}

class _AuthAwareNavigatorState extends State<AuthAwareNavigator> {
  @override
  void initState() {
    super.initState();
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
