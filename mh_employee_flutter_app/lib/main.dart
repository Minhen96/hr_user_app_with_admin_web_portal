import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Core
import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';

// Features - Auth
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen_new.dart';
import 'features/home/presentation/screens/home_screen_new.dart';

// Note: Uncomment these as features are migrated and imports are fixed
// import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;
  bool _showSplashScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicRefresh();

    // Show splash screen for configured duration
    Future.delayed(AppConstants.splashDuration, () {
      if (mounted) {
        setState(() {
          _showSplashScreen = false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndRefreshToken();
    }
  }

  void _startPeriodicRefresh() {
    // Attempt to refresh token at configured interval
    _refreshTimer =
        Timer.periodic(AppConstants.tokenRefreshInterval, (_) {
      _checkAndRefreshToken();
    });
  }

  Future<void> _checkAndRefreshToken() async {
    final authProvider = di.sl<AuthProvider>();

    // Only attempt refresh if authenticated
    if (authProvider.isAuthenticated) {
      try {
        // Prevent too frequent refresh attempts
        if (_lastRefreshTime == null ||
            DateTime.now().difference(_lastRefreshTime!).inMinutes >= 15) {
          await authProvider.refreshUserData();
          _lastRefreshTime = DateTime.now();
        }
      } catch (e) {
        print('Token refresh failed: $e');
        // Logout user if refresh fails
        await authProvider.logout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => di.sl<ThemeProvider>(),
        ),

        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>()..checkAuthStatus(),
        ),

        // TODO: Add other feature providers here as they are migrated
        // ChangeNotifierProvider(create: (_) => di.sl<EquipmentProvider>()),
        // ChangeNotifierProvider(create: (_) => di.sl<DocumentsProvider>()),
        // etc.
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: _showSplashScreen
                ? const SplashScreen()
                : const AuthenticationWrapper(),
          );
        },
      ),
    );
  }
}

/// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your app logo here
            const FlutterLogo(size: 100),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Authentication Wrapper - Routes to appropriate screen based on auth state
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth status
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Route based on authentication status
        if (authProvider.isAuthenticated) {
          // Modern redesigned home screen
          return const HomeScreenNew();
          // return Scaffold(
          //   appBar: AppBar(
          //     title: const Text('Home'),
          //     actions: [
          //       IconButton(
          //         icon: const Icon(Icons.logout),
          //         onPressed: () async {
          //           await authProvider.logout();
          //         },
          //       ),
          //     ],
          //   ),
          //   body: Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const Text(
          //           'Welcome!',
          //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          //         ),
          //         const SizedBox(height: 16),
          //         Text(
          //           'User: ${authProvider.user?.name ?? "Unknown"}',
          //           style: const TextStyle(fontSize: 16),
          //         ),
          //         const SizedBox(height: 8),
          //         Text(
          //           'Email: ${authProvider.user?.email ?? "Unknown"}',
          //           style: const TextStyle(fontSize: 16),
          //         ),
          //         const SizedBox(height: 32),
          //         const Text(
          //           'Home screen will be available after import fixes',
          //           style: TextStyle(fontStyle: FontStyle.italic),
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        }

        // Show login screen if not authenticated
        return const LoginScreenNew();
      },
    );
  }
}

